//
//  RVModelsViewController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 20.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "RVModelsViewController.h"
#import "RVCreditsViewController.h"
#import "RVTutorialViewController.h"

#import "RVModelCell.h"
#import "RVModelSprite.h"

#import "RVModel.h"
#import "RVRenderingController.h"
#import "RVVectorAnimation.h"
#import "DrawGestureRecognizer.h"
#import "RVQuaternionAnimation.h"
#import "RVFloatAnimation.h"

#import "RVAddProgressView.h"
#import "RVModelButtonsView.h"
#import "RVSettingsButtonsView.h"

#import "NSArray+Functional.h"
#import "UIView+RotationAnimation.h"

static NSString * const CellIdentifier = @"Cell";

static const CGSize CellSize = {288.0f * 1.25, 384.0f * 1.25};
static const CGFloat TableInset = 100.0f;
static const CGFloat OverInset = 288.0f * 1.25 / 2.0f;


static const float ZOffsetActive =  0.4;
static const float ZOffsetPassive = -0.5;

@interface RVModelsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *editContainer;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIView *startOverlay;

@property (weak, nonatomic) IBOutlet RVAddProgressView *progressView;
@property (strong, nonatomic) RVSettingsButtonsView *settingsView;

@property (nonatomic, strong) RVCreditsViewController *creditsViewController;

@property (nonatomic, strong) NSIndexPath *centerIndexPath;
@property (nonatomic, strong) NSMapTable *modelToModelSpriteMap;

@property (nonatomic) BOOL needsRetesellation;
@property (nonatomic) BOOL editMode;

@property (nonatomic, strong) UILongPressGestureRecognizer *dragPressRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic) BOOL inAddButtonTapMode;

@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic) CGFloat dragCenterOffset;
@property (nonatomic) BOOL drags;

@end

@implementation RVModelsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _creditsViewController = [[RVCreditsViewController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = nil;
    self.modelToModelSpriteMap = [NSMapTable strongToStrongObjectsMapTable];
    
    self.editButton.exclusiveTouch = YES;
    
    [self.progressView.plus addTarget:self action:@selector(addButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.backgroundColor = nil;
    self.tableView.clipsToBounds = NO;
    self.tableView.rowHeight = CellSize.width;
    [self.tableView registerClass:[RVModelCell class] forCellReuseIdentifier:CellIdentifier];
    
    self.settingsView = [[NSBundle mainBundle] loadNibNamed:@"RVSettingsButtonsView" owner:self options:nil][0];
    self.settingsView.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height);
    [self.settingsView.tutorialButton addTarget:self action:@selector(tutorialButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingsView.creditsButton addTarget:self action:@selector(creditsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingsView.rateMeButton addTarget:self action:@selector(rateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.settingsView atIndex:0];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.tapRecognizer.delegate = self;
    self.tapRecognizer.enabled = NO;
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    self.dragPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dragPressRecognized:)];
    self.dragPressRecognizer.delegate = self;
    self.dragPressRecognizer.minimumPressDuration = 0.3;
    self.dragPressRecognizer.enabled = NO;
    [self.view addGestureRecognizer:self.dragPressRecognizer];
    
    
    [self addChildViewController:self.creditsViewController];
    [self.view addSubview:self.creditsViewController.view];
    [self.creditsViewController didMoveToParentViewController:self];
    
    self.startOverlay.backgroundColor = [UIColor colorWithWhite:0.93f alpha:1.0];
    
    [self updateHeaderPosition];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateSpritesPositions];
    
    for (RVModelSprite *modelSprite in self.modelToModelSpriteMap.objectEnumerator.allObjects) {
        modelSprite.extraTranslationVector = GLKVector3Make(1.5f, 0.0f, 0.0f);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateSpritesPositions];
    
    NSTimeInterval Delay = 1.1;
    NSTimeInterval Duration = 0.5;
    
    for (RVModelSprite *modelSprite in self.modelToModelSpriteMap.objectEnumerator.allObjects) {
        RVVectorAnimation *translationAnimation = [RVVectorAnimation vectorAnimationFromValue:modelSprite.extraTranslationVector toValue:GLKVector3Make(0.0f, 0.0f, 0.0f) withDuration:Duration];
        translationAnimation.animationCurve = RVAnimationCurveQuartEaseOut;
        translationAnimation.delay = Delay;
        [modelSprite addAnimation:translationAnimation forKey:@"extraTranslationVector"];
    }
    
    [UIView animateWithDuration:Duration/2 delay:Delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.startOverlay.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES; // dirty hack for import animation...
        self.startOverlay.hidden = YES;

    }];
}

- (void)viewDidLayoutSubviews
{
    CGRect bounds = self.view.bounds;
    
    self.tableView.transform = CGAffineTransformIdentity;
    self.tableView.frame = CGRectMake(0, 0, CellSize.height, bounds.size.width + 2.0f * OverInset);
    self.tableView.contentInset = UIEdgeInsetsMake(TableInset + OverInset, 0.0f, TableInset + OverInset, 0.0f);
    self.tableView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) - 10.0f);
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    [self updateSpritesPositions];
    [self retesselateModels];
}



#pragma mark - Coordinate Systems

- (GLKVector3)screenVectorForPoint:(CGPoint)point
{
    CGSize viewSize = self.view.bounds.size;
    
    return GLKVector3Make(point.x * 2.0f / viewSize.width - 1.0f, 1.0f - point.y * 2.0f / viewSize.height, 0.0f);
}


- (GLKVector3)defaultModelScaleVector
{
    CGSize viewSize = self.view.bounds.size;
    
    return GLKVector3Make(CellSize.width / viewSize.width, CellSize.height / viewSize.height, 0.3f);
}

#pragma mark - Ticks

- (void)tick
{
    if (self.needsRetesellation) {
        self.needsRetesellation = NO;
        [self retesselateModels];
    }
    
    if (self.drags) {
        
        const float StartNorm = 0.8f;
        const float Magnitude = 20.0f;
        
        GLKVector3 screenPoint = [self screenVectorForPoint:[self.dragPressRecognizer locationInView:self.view]];
        float sign = screenPoint.x > 0.0f ? 1.0f : -1.0f;
        float speed =  Magnitude * sign * MAX(0.0f, (fabsf(screenPoint.x) - StartNorm)/(1.0f - StartNorm));
        
        CGPoint contentOffset = self.tableView.contentOffset;
        contentOffset.y += speed;
        contentOffset.y = MIN(MAX(- self.tableView.contentInset.top, contentOffset.y), self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.bounds.size.height);
        self.tableView.contentOffset = contentOffset;
    }
}

- (void)retesselateModels
{
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    
    if (self.drags && ! [visibleIndexPaths containsObject:self.draggedIndexPath]) {
        visibleIndexPaths = [visibleIndexPaths arrayByAddingObject:self.draggedIndexPath];
        
    }
    
    NSArray *sprites = [visibleIndexPaths mapObjectsUsingBlock:^id(NSIndexPath *indexPath, NSUInteger idx) {
        NSUInteger modelIndex = [self modelIndexForIndexPath:indexPath];
        RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:modelIndex];
        RVModelSprite *sprite = [self.modelToModelSpriteMap objectForKey:model];
        
        return sprite;
    }];
    
    [self.renderingController.modelController updateBuffersWithModelSprites:sprites];
}

- (void)updateSpritesPositions
{
    NSInteger count = [self.dataSource modelsViewControllerNumberOfModels:self];
    for (int modelIndex = 0; modelIndex < count; modelIndex++) {
        RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:modelIndex];
        RVModelSprite *sprite = [self.modelToModelSpriteMap objectForKey:model];
        
        CGPoint center = [self centerForCellAtModelIndex:modelIndex];
        
        sprite.translationVector = [self screenVectorForPoint:center];
    }
    
    if (self.drags) {
        NSUInteger modelIndex = [self modelIndexForIndexPath:self.draggedIndexPath];
        RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:modelIndex];
        RVModelSprite *sprite = [self.modelToModelSpriteMap objectForKey:model];
        
        GLKVector3 translation = [self screenVectorForPoint:[self.dragPressRecognizer locationInView:self.view]];
        translation.x -= self.dragCenterOffset * 2.0f/self.view.bounds.size.width;
        translation.y = [self screenVectorForPoint:[self centerForCellAtModelIndex:0]].y;
        
        sprite.translationVector = translation;
    }
}



#pragma mark - Data mapping

- (void)reloadData
{
    NSUInteger count = [self.dataSource modelsViewControllerNumberOfModels:self];
    
    [self.modelToModelSpriteMap removeAllObjects];
    for (int i = 0; i < count; i++) {
        [self createNewSpriteForModelAtIndex:i];
    }
    
    [self updateSpritesPositions];
    [self retesselateModels];
}

- (RVModelSprite *)createNewSpriteForModelAtIndex:(NSInteger)modelIndex
{
    RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:modelIndex];
    
    RVModelSprite *sprite = [RVModelSprite new];
    sprite.drawnSegments = model.segments.array;
    sprite.scaleVector = [self defaultModelScaleVector];
    sprite.translationVector = [self screenVectorForPoint:[self centerForCellAtModelIndex:modelIndex]];
    
    [self.modelToModelSpriteMap setObject:sprite forKey:model];
    
    return sprite;
}

- (void)addNewModelSpriteForModelAtIndex:(NSInteger)modelIndex;
{
    NSInteger count = [self.dataSource modelsViewControllerNumberOfModels:self];
    GLKVector3 offset = GLKVector3Make(2.0f * (-CellSize.width - self.tableView.contentOffset.y - TableInset - OverInset)/self.view.bounds.size.width, 0.0f, 0.0f);
    
    for (int i = 0; i < count; i++) {
        RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:i];
        RVModelSprite *sprite = [self.modelToModelSpriteMap objectForKey:model];
        
        sprite.extraTranslationVector = offset;
    }
    
    [self createNewSpriteForModelAtIndex:modelIndex];
    NSIndexPath *path = [self indexPathForModelIndex:modelIndex];
    [self.tableView reloadData];
    [self zoomInToCellAtIndexPath:path];
}

- (void)importModelSpriteForModelAtIndex:(NSInteger)modelIndex
{
    [self createNewSpriteForModelAtIndex:modelIndex];
    self.tableView.contentOffset = CGPointMake(0.0f, -OverInset - TableInset);
    [self setEditMode:NO];
    [self.tableView insertRowsAtIndexPaths:@[[self indexPathForModelIndex:modelIndex]] withRowAnimation:UITableViewRowAnimationFade];
    [self animateModelPositionsUsingExtra];
    
    [self animateImportAnimation];
}

- (void)removeModelSpriteForModel:(RVModel *)model
{
    [self.modelToModelSpriteMap removeObjectForKey:model];
}

#pragma mark - Header

- (void)updateHeaderPosition
{
    self.progressView.alpha = [self currentAlphaProgress];
    [self.progressView setProgress:[self currentAddProgress] allowingFull:self.tableView.tracking || self.inAddButtonTapMode];
}

- (float)currentAlphaProgress
{
    const CGFloat FullDrag = 35.0f;
    const CGFloat Surplus = 35.0f;
    
    CGFloat edgePosition = -(self.tableView.contentOffset.y + TableInset + OverInset) + Surplus;
    CGFloat percent = edgePosition/FullDrag;
    
    return MIN(MAX(0.0f, percent), 1.0f);
}

- (float)currentAddProgress
{
    const CGFloat FullDrag = 240.0f;
    const CGFloat Surplus = 5.0f;
    
    CGFloat edgePosition = -(self.tableView.contentOffset.y + TableInset + OverInset + Surplus);
    CGFloat percent = edgePosition/FullDrag;
    
    return MIN(MAX(0.0f, percent), 1.0f);
}



#pragma mark - Helpers

- (NSUInteger)modelIndexForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row;
}

- (NSIndexPath *)indexPathForModelIndex:(NSUInteger)modelIndex
{
    return [NSIndexPath indexPathForRow:modelIndex inSection:0];
}

- (CGPoint)centerForCellAtModelIndex:(NSInteger)modelIndex
{
    CGFloat offset = self.tableView.contentOffset.y + OverInset;
    CGFloat y = self.tableView.center.y - 5.0f;
    
    CGPoint center = CGPointMake(-offset + (modelIndex + 0.5f)*CellSize.width, y);
    
    return center;
}


- (void)zoomInToCellAtIndexPath:(NSIndexPath *)centerPath
{
    const NSTimeInterval ZoomDuration = 0.3;
    
    self.view.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:ZoomDuration animations:^{
        self.view.alpha = 0.0f;
    }];
    
    self.centerIndexPath = centerPath;
    
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    NSInteger centerIndex = [indexPaths indexOfObject:centerPath];
    NSAssert(centerIndex != NSNotFound, @"");
    
    CGSize viewSize = self.view.bounds.size;
    
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        
        NSUInteger modelIndex = [self modelIndexForIndexPath:indexPath];
        RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:[self modelIndexForIndexPath:indexPath]];
        RVModelSprite *sprite = [self.modelToModelSpriteMap objectForKey:model];
        
        GLKVector3 currentTranslation = sprite.extraTranslationVector;
        GLKVector3 targetTranslation = currentTranslation;
        targetTranslation.x += 2.0f * (idx > centerIndex ? 1.0f : -1.0f);
        
        
        RVVectorAnimation *translationAnimation = [RVVectorAnimation vectorAnimationFromValue:currentTranslation toValue:targetTranslation withDuration:ZoomDuration];
        
        if (idx == centerIndex) {
            CGRect targetRect = [self.dataSource modelsViewControllerDestinationRectForSelectedModel:self];
            
            GLKVector3 currentScale = sprite.scaleVector;
            GLKVector3 targetScale = GLKVector3Make( targetRect.size.width/viewSize.width, targetRect.size.height/viewSize.height, 1.0f);
            targetTranslation = GLKVector3Subtract([self screenVectorForPoint:CGPointMake(CGRectGetMidX(targetRect), CGRectGetMidY(targetRect))], sprite.translationVector);
            
            translationAnimation.to = targetTranslation;
            translationAnimation.completionBlock = ^{
                [self.delegate modelsViewController:self didZoomInToModelAtIndex:modelIndex];
            };
            
            RVVectorAnimation *scaleAnimation = [RVVectorAnimation vectorAnimationFromValue:currentScale toValue:targetScale withDuration:ZoomDuration];
            [sprite addAnimation:scaleAnimation forKey:@"scaleVector"];
        }
        
        [sprite addAnimation:translationAnimation forKey:@"extraTranslationVector"];
    }];
}

- (void)zoomOut
{
    const NSTimeInterval ZoomDuration = 0.3;
    
    [self retesselateModels];
    GLKVector3 defaultScaleVector = [self defaultModelScaleVector];
    
    NSInteger centerIndex = [self modelIndexForIndexPath:self.centerIndexPath];
    
    [UIView animateWithDuration:ZoomDuration animations:^{
        self.view.alpha = 1.0f;
    }];
    
    NSInteger count = [self.dataSource modelsViewControllerNumberOfModels:self];
    
    for (NSInteger i = 0; i < count; i++) {
        RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:i];
        RVModelSprite *sprite = [self.modelToModelSpriteMap objectForKey:model];
        NSInteger indexDiff = (NSInteger)labs((NSInteger)i - (NSInteger)centerIndex);
        RVVectorAnimation *translationAnimation = [RVVectorAnimation vectorAnimationFromValue:sprite.extraTranslationVector
                                                                                      toValue:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                                                 withDuration:ZoomDuration];
        RVVectorAnimation *scaleAnimation = [RVVectorAnimation vectorAnimationFromValue:sprite.scaleVector toValue:defaultScaleVector withDuration:ZoomDuration];
        translationAnimation.delay = indexDiff * 0.1;
        
        if (i == centerIndex) {
            translationAnimation.completionBlock = ^{
                self.view.userInteractionEnabled = YES;
                [self.delegate modelsViewControllerDidZoomOut:self];
            };
        } else {
            scaleAnimation.completionBlock = ^{
                const float ScaleEps = 0.025;
                
                RVVectorAnimation *modelScaleAnimation = [RVVectorAnimation vectorAnimationFromValue:GLKVector3Make(1.0 - ScaleEps, 1.0 + ScaleEps, 1.0 - ScaleEps)
                                                                                             toValue:GLKVector3Make(1.0 + ScaleEps, 1.0 - ScaleEps, 1.0 + ScaleEps)
                                                                                        withDuration:0.8];
                modelScaleAnimation.animationCurve = RVAnimationCurveJelly;
                [sprite addAnimation:modelScaleAnimation forKey:@"modelScaleVector"];
            };
        }
        
        [sprite addAnimation:translationAnimation forKey:@"extraTranslationVector"];
        [sprite addAnimation:scaleAnimation forKey:@"scaleVector"];
    }
    
    
    self.centerIndexPath = nil;
}


#pragma mark - Button actions

- (void)addButtonTapped:(UIButton *)sender
{
    self.view.userInteractionEnabled = NO;
    self.inAddButtonTapMode = YES;
    [self.tableView setContentOffset:CGPointMake(0.0, -250.0f - TableInset - OverInset) animated:YES];
}

- (IBAction)editButtonTapped:(UIButton *)sender
{
    [self setEditMode:!self.editMode];
}


- (void)creditsButtonTapped:(UIButton *)sender
{
    [self.creditsViewController present];
}


- (void)tutorialButtonTapped:(UIButton *)sender
{
    [self.delegate modelsViewControllerDidRequestTutorial:self];
}

- (void)rateButtonTapped:(UIButton *)sender
{
    NSNumber *appID = @(689658680); //Revolved
    
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    [storeViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:appID} completionBlock:nil];
    storeViewController.delegate = self;
    
    [self presentViewController:storeViewController animated:YES completion:^{
        
        if ([storeViewController.view.subviews count] == 0) {
            return;
        }
        /*
         Flirting with the view hierarchy to plug in the review prompt
         */
        UIView *targetView = [storeViewController.view subviews][0];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ReviewBegger"]];
        image.frame = CGRectMake(835, 272, 170, 68);

        image.transform = CGAffineTransformMakeTranslation(300.0f, 0.0f);
        [targetView addSubview:image];
        
        [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            image.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
                    image.transform = CGAffineTransformMakeTranslation(11.0, 0.0);
                } completion:NULL];
            }
        }];
    }];
}

- (void)cloneButtonTapped:(UIButton *)sender
{
    CGPoint tableViewLocation = [sender.superview convertPoint:sender.center toView:self.tableView];
    NSInteger modelIndex = [self modelIndexForIndexPath:[self.tableView indexPathForRowAtPoint:tableViewLocation]];
    
    [self animateCloneModelAtIndex:modelIndex];
}

- (void)shareButtonTapped:(UIButton *)sender
{
    CGPoint tableViewLocation = [sender.superview convertPoint:sender.center toView:self.tableView];
    NSInteger modelIndex = [self modelIndexForIndexPath:[self.tableView indexPathForRowAtPoint:tableViewLocation]];
    
    [self.delegate modelsViewController:self didShareModelAtIndex:modelIndex];
}

- (void)confirmButtonTapped:(UIButton *)sender
{
    CGPoint tableViewLocation = [sender.superview convertPoint:sender.center toView:self.tableView];
    NSInteger modelIndex = [self modelIndexForIndexPath:[self.tableView indexPathForRowAtPoint:tableViewLocation]];
    
    [self animateDeleteModelAtIndex:modelIndex];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Animations

- (void)animateDeleteModelAtIndex:(NSInteger)modelIndex
{
    const float Scale = 0.03f;
    
    NSTimeInterval Duration = 0.5;
    
    self.view.userInteractionEnabled = NO;
    
    RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:modelIndex];
    RVModelSprite *deletedSprite = [self.modelToModelSpriteMap objectForKey:model];
    if (deletedSprite.drawnSegments.count == 0) {
        Duration = 0.0;
    }
    
    RVVectorAnimation *scaleAnimation = [RVVectorAnimation vectorAnimationFromValue:deletedSprite.modelScaleVector
                                                                            toValue:GLKVector3Make(Scale, Scale, Scale)
                                                                       withDuration:Duration];
    
    GLKVector3 start = deletedSprite.extraTranslationVector;
    GLKVector3 end = start;
    end.y = -0.543;
    RVVectorAnimation *translationAnimation = [RVVectorAnimation vectorAnimationFromValue:start
                                                                                  toValue:end
                                                                             withDuration:Duration];
    translationAnimation.animationCurve = RVAnimationCurveJumpEaseIn;
    translationAnimation.completionBlock = ^{
        self.view.userInteractionEnabled = YES;
        [self.modelToModelSpriteMap removeObjectForKey:model];
        self.needsRetesellation = YES;
        [self.delegate modelsViewController:self didDeleteModelAtIndex:modelIndex];
        
        [self.tableView deleteRowsAtIndexPaths:@[[self indexPathForModelIndex:modelIndex]]
                              withRowAnimation:UITableViewRowAnimationLeft];
        
        
        [self animateModelPositionsUsingExtra];
        if ([self.dataSource modelsViewControllerNumberOfModels:self] == 0) {
            [self setEditMode:NO];
        }
        
    };
    [deletedSprite addAnimation:translationAnimation forKey:@"extraTranslationVector"];
    
    [deletedSprite addAnimation:scaleAnimation forKey:@"modelScaleVector"];
}

- (void)animateCloneModelAtIndex:(NSInteger)modelIndex
{
    self.view.userInteractionEnabled = NO;
    
    NSTimeInterval Duration = 0.3;
    NSTimeInterval ShakeOffDuration = 0.2;
    float Scale = 0.4;
    
    RVModel *sourceModel = [self.dataSource modelsViewController:self modelAtIndex:modelIndex];
    RVModelSprite *sourceSprite = [self.modelToModelSpriteMap objectForKey:sourceModel];
    
    self.needsRetesellation = YES;
    [self.delegate modelsViewController:self didCloneModelAtIndex:modelIndex];
    NSIndexPath *path = [self indexPathForModelIndex:modelIndex];
    [self.tableView insertRowsAtIndexPaths:@[path]
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self animateModelPositionsUsingExtra];
    
    
    RVModelSprite *clonedSprite = [self createNewSpriteForModelAtIndex:modelIndex + 1];
    clonedSprite.extraTranslationVector = GLKVector3Make(0.0, 20.0, 1.0);
    clonedSprite.translationVector = [self screenVectorForPoint:[self centerForCellAtModelIndex:modelIndex + 1]];
    
    
    
    GLKVector3 offsetVector = GLKVector3MultiplyScalar(GLKVector3Subtract(clonedSprite.translationVector, sourceSprite.translationVector), 0.5f);
    
    GLKVector3 defaultScale = [self defaultModelScaleVector];
    GLKVector3 shrunkScale = GLKVector3MultiplyScalar(defaultScale, Scale);
    
    
    
    RVVectorAnimation *scaleAnimation = [RVVectorAnimation vectorAnimationFromValue:sourceSprite.scaleVector toValue:shrunkScale withDuration:Duration];
    [sourceSprite addAnimation:scaleAnimation forKey:@"scaleVector"];
    
    RVQuaternionAnimation *quaternionAnimation = [RVQuaternionAnimation quaternionAnimationFromValue:sourceSprite.quaternion
                                                                                             toValue:BaseQuaternion
                                                                                        withDuration:ShakeOffDuration];
    
    [sourceSprite addAnimation:quaternionAnimation forKey:@"quaternion"];
    
    
    RVVectorAnimation *translationAnimation = [RVVectorAnimation vectorAnimationFromValue:sourceSprite.extraTranslationVector toValue:offsetVector withDuration:Duration];
    translationAnimation.completionBlock = ^{
        
        clonedSprite.extraTranslationVector = GLKVector3Negate(sourceSprite.extraTranslationVector);
        clonedSprite.scaleVector = sourceSprite.scaleVector;
        
        CGRect fullRect = CGRectMake(-1.0f, -1.0f, 2.0f, 2.0f);
        CGRect leftRect, rightRect;
        CGRectDivide(fullRect, &leftRect, &rightRect, 1.0f + (sourceSprite.translationVector.x + sourceSprite.extraTranslationVector.x), CGRectMinXEdge);
        
        sourceSprite.hasScissors = YES;
        sourceSprite.scissorsRect = leftRect;
        clonedSprite.hasScissors = YES;
        clonedSprite.scissorsRect = rightRect;
        
        RVVectorAnimation *parentTranslationAnimation = [RVVectorAnimation vectorAnimationFromValue:sourceSprite.extraTranslationVector toValue:GLKVector3Make(0, 0, 0) withDuration:Duration];
        parentTranslationAnimation.completionBlock = ^{
            sourceSprite.hasScissors = NO;
            clonedSprite.hasScissors = NO;
            [sourceSprite addAnimation:randomQuaternionAnimationForSprite(sourceSprite, -1.0f) forKey:@"quaternion"];
            [clonedSprite addAnimation:randomQuaternionAnimationForSprite(clonedSprite, 1.0f) forKey:@"quaternion"];
            
            self.view.userInteractionEnabled = YES;
        };
        [sourceSprite addAnimation:parentTranslationAnimation forKey:@"extraTranslationVector"];
        RVVectorAnimation *childTranslationAnimation = [RVVectorAnimation vectorAnimationFromValue:clonedSprite.extraTranslationVector toValue:GLKVector3Make(0, 0, 0) withDuration:Duration];
        [clonedSprite addAnimation:childTranslationAnimation forKey:@"extraTranslationVector"];
        
        
        RVVectorAnimation *parentScaleAnimation = [RVVectorAnimation vectorAnimationFromValue:sourceSprite.scaleVector toValue:defaultScale withDuration:Duration];
        [sourceSprite addAnimation:parentScaleAnimation forKey:@"scaleVector"];
        
        RVVectorAnimation *childScaleAnimation = [RVVectorAnimation vectorAnimationFromValue:clonedSprite.scaleVector toValue:defaultScale withDuration:Duration];
        [clonedSprite addAnimation:childScaleAnimation forKey:@"scaleVector"];
    };
    [sourceSprite addAnimation:translationAnimation forKey:@"extraTranslationVector"];
}

- (void)animateImportAnimation
{
    NSTimeInterval Duration = 0.8;
    
    NSInteger count = [self.dataSource modelsViewControllerNumberOfModels:self];
    
    if (count == 0) {
        return;
    }
    self.view.userInteractionEnabled = NO;
    
    RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:0];
    RVModelSprite *sprite = [self.modelToModelSpriteMap objectForKey:model];
    
    GLKVector3 start = sprite.extraTranslationVector;
    GLKVector3 end = start;
    end.y -= 2.0f;
    
    RVVectorAnimation *translationAnimation = [RVVectorAnimation vectorAnimationFromValue:end
                                                                                  toValue:start
                                                                             withDuration:Duration];
    translationAnimation.completionBlock = ^{
        self.view.userInteractionEnabled = YES;
    };
    [sprite addAnimation:translationAnimation forKey:@"extraTranslationVector"];
}

- (void)animateModelPositionsUsingExtra
{
    NSTimeInterval AnimationDuration = 0.2;
    
    NSInteger count = [self.dataSource modelsViewControllerNumberOfModels:self];
    
    for (int i = 0; i < count; i++) {
        RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:i];
        RVModelSprite *sprite = [self.modelToModelSpriteMap objectForKey:model];
        
        CGPoint center = [self centerForCellAtModelIndex:i];
        GLKVector3 targetTranslation = [self screenVectorForPoint:center];
        GLKVector3 currentTranslation = sprite.translationVector;
        
        GLKVector3 start = GLKVector3Subtract(currentTranslation, targetTranslation);
        sprite.extraTranslationVector = start;
        RVVectorAnimation *translationAnimation = [RVVectorAnimation vectorAnimationFromValue:start
                                                                                      toValue:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                                                 withDuration:AnimationDuration];
        [sprite addAnimation:translationAnimation forKey:@"extraTranslationVector"];
    }
    
    [self updateSpritesPositions];
}


#pragma mark - Scroll View

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.drags) {
        [self reorderDraggedObjectIfNeeded];
    }
    [self updateSpritesPositions];
    [self updateHeaderPosition];
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!self.editMode && scrollView.tracking && [self currentAddProgress] == 1.0f) {
        [self.delegate modelsViewControllerDidAddModel:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.inAddButtonTapMode) {
        self.view.userInteractionEnabled = YES;
        self.inAddButtonTapMode = NO;
        [self.delegate modelsViewControllerDidAddModel:self];
    }
}




#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource modelsViewControllerNumberOfModels:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RVModelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.buttonsView setTrashCanMode:NO animated:NO];
    [cell.buttonsView.cloneButton addTarget:self action:@selector(cloneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.buttonsView.shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.buttonsView.confirmTrashButton addTarget:self action:@selector(confirmButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.buttonsContainerView.alpha = self.drags ? 0.0f : 1.0f;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate modelsViewController:self didSelectModelAtIndex:[self modelIndexForIndexPath:indexPath]];
    [self zoomInToCellAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = nil;
    self.needsRetesellation = YES;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    self.needsRetesellation = YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Editing

RVQuaternionAnimation *randomQuaternionAnimationForSprite(RVModelSprite *sprite, float sign)
{
    float Radians = M_PI_2/20.0f;
    float Duration = 0.08;
    GLKVector3 axis = GLKVector3Normalize(GLKVector3Make(0.0f, 0.0f, sign * 1.0f));
    
    GLKQuaternion targetQuaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(Radians, axis),
                                                           BaseQuaternion);
    RVQuaternionAnimation *quaternionAnimation = [RVQuaternionAnimation quaternionAnimationFromValue:sprite.quaternion
                                                                                             toValue:targetQuaternion
                                                                                        withDuration:Duration];
    
    quaternionAnimation.completionBlock = ^{
        [sprite addAnimation:randomQuaternionAnimationForSprite(sprite, -sign) forKey:@"quaternion"];
    };
    
    return quaternionAnimation;
}

RVFloatAnimation *rotationFloatAnimationForView(UIView *view, float sign)
{
    float Radians = M_PI_2/20.0f;
    float Duration = 0.08;
    
    RVFloatAnimation *animation = [RVFloatAnimation floatAnimationFromValue:[view rv_Rotation] toValue:sign * Radians withDuration:Duration];
    
    animation.completionBlock = ^{
        [view rv_addAnimation:rotationFloatAnimationForView(view, -sign) forKey:@"rotation"];
    };
    
    return animation;
}


static double frand()
{
    return drand48() * 2.0 - 1.0;
}


- (void)setEditMode:(BOOL)editMode
{
    _editMode = editMode;
    self.tableView.editing = editMode;
    self.editButton.selected = editMode;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.settingsView.alpha = editMode ? 0.0f : 1.0f;
    }];
    
    if (editMode) {
        for (RVModelSprite *modelSprite in self.modelToModelSpriteMap.objectEnumerator.allObjects) {
            RVQuaternionAnimation *animation = randomQuaternionAnimationForSprite(modelSprite, 1.0f);
            [modelSprite addAnimation:animation forKey:@"quaternion"];
        }
        
        RVFloatAnimation *animation = rotationFloatAnimationForView(self.editButton, 1.0f);
        [self.editButton rv_addAnimation:animation forKey:@"rotation"];
        
        
    } else {
        for (RVModelSprite *modelSprite in self.modelToModelSpriteMap.objectEnumerator.allObjects) {
            RVQuaternionAnimation *animation = (RVQuaternionAnimation *)[modelSprite animationForKey:@"quaternion"];
            
            animation.completionBlock = ^{
                RVQuaternionAnimation *quaternionAnimation = [RVQuaternionAnimation quaternionAnimationFromValue:modelSprite.quaternion
                                                                                                         toValue:BaseQuaternion
                                                                                                    withDuration:0.1];
                
                [modelSprite addAnimation:quaternionAnimation forKey:@"quaternion"];
            };
        }
        
        RVFloatAnimation *animation = [RVFloatAnimation floatAnimationFromValue:self.editButton.rv_Rotation toValue:0.0f withDuration:0.1];
        [self.editButton rv_addAnimation:animation forKey:@"rotation"];
    }
    
    self.tapRecognizer.enabled = editMode;
    self.dragPressRecognizer.enabled = editMode;
    self.progressView.hidden = editMode;
}


- (void)reorderDraggedObjectIfNeeded
{
    const NSTimeInterval AnimationDuration = 0.2;
    
    CGPoint draggedModelCenter = CGPointMake(0.0f, [self.dragPressRecognizer locationInView:self.tableView].y - self.dragCenterOffset);
    NSIndexPath *nextIndexPath = [self.tableView indexPathForRowAtPoint:draggedModelCenter];
    if (nextIndexPath == nil || nextIndexPath.row == self.draggedIndexPath.row) {
        return;
    }
    
    
    NSInteger startIndex, endIndex;
    float direction;
    
    if (nextIndexPath.row > self.draggedIndexPath.row) {
        startIndex = [self modelIndexForIndexPath:self.draggedIndexPath] + 1;
        endIndex = [self modelIndexForIndexPath:nextIndexPath];
        direction = 1.0f;
    } else {
        startIndex = [self modelIndexForIndexPath:nextIndexPath];
        endIndex = [self modelIndexForIndexPath:self.draggedIndexPath] - 1;
        direction = -1.0f;
    }
    
    for (NSInteger i = startIndex; i <= endIndex; i++) {
        RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:i];
        RVModelSprite *sprite = [self.modelToModelSpriteMap objectForKey:model];
        float offset = direction * CellSize.width * 2.0f /self.view.bounds.size.width;
        
        RVVectorAnimation *translationAnimation = [RVVectorAnimation vectorAnimationFromValue:GLKVector3Make(offset, 0.0f, -ZOffsetPassive)
                                                                                      toValue:GLKVector3Make(0.0f, 0.0f, -ZOffsetPassive)
                                                                                 withDuration:AnimationDuration];
        [sprite addAnimation:translationAnimation forKey:@"extraTranslationVector"];
    }
    
    
    [self.delegate modelsViewController:self
                    didMoveModelAtIndex:[self modelIndexForIndexPath:self.draggedIndexPath]
                                toIndex:[self modelIndexForIndexPath:nextIndexPath]];
    
    self.draggedIndexPath = nextIndexPath;
}

- (void)animateDraggingStart
{
    NSTimeInterval AnimationDuration = 0.2;
    
    RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:[self modelIndexForIndexPath:self.draggedIndexPath]];
    RVModelSprite *draggedSprite = [self.modelToModelSpriteMap objectForKey:model];
    
    RVQuaternionAnimation *quatAnimation = [RVQuaternionAnimation quaternionAnimationFromValue:draggedSprite.quaternion toValue:BaseQuaternion withDuration:AnimationDuration];
    [draggedSprite addAnimation:quatAnimation forKey:@"quaternion"];
    
    
    for (RVModelSprite *modelSprite in self.modelToModelSpriteMap.objectEnumerator.allObjects) {
        float zOffset = (modelSprite == draggedSprite ? -ZOffsetActive : -ZOffsetPassive);
        RVVectorAnimation *translationAnimation = [RVVectorAnimation vectorAnimationFromValue:modelSprite.extraTranslationVector
                                                                                      toValue:GLKVector3Make(0.0, 0.0, zOffset)
                                                                                 withDuration:AnimationDuration];
        [modelSprite addAnimation:translationAnimation forKey:@"extraTranslationVector"];
        
        float scaleMultiplier = (modelSprite == draggedSprite ? 1.1f : 0.9f);
        RVVectorAnimation *scaleAnimation = [RVVectorAnimation vectorAnimationFromValue:modelSprite.scaleVector
                                                                                toValue:GLKVector3MultiplyScalar([self defaultModelScaleVector], scaleMultiplier)
                                                                           withDuration:AnimationDuration];
        [modelSprite addAnimation:scaleAnimation forKey:@"scaleVector"];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        for (RVModelCell *cell in self.tableView.visibleCells) {
            cell.buttonsContainerView.alpha = 0.0f;
            [cell.buttonsView setTrashCanMode:NO animated:YES];
        }
    }];
    
}

- (void)animateDraggingEnd
{
    NSTimeInterval AnimationDuration = 0.2;
    
    RVModel *model = [self.dataSource modelsViewController:self modelAtIndex:[self modelIndexForIndexPath:self.draggedIndexPath]];
    RVModelSprite *draggedSprite = [self.modelToModelSpriteMap objectForKey:model];
    
    RVQuaternionAnimation *animation = randomQuaternionAnimationForSprite(draggedSprite, 1.0f);
    [draggedSprite addAnimation:animation forKey:@"quaternion"];
    
    for (RVModelSprite *modelSprite in self.modelToModelSpriteMap.objectEnumerator.allObjects) {
        GLKVector3 startTranslation = modelSprite.extraTranslationVector;
        if (modelSprite == draggedSprite) {
            startTranslation.x = modelSprite.translationVector.x - [self screenVectorForPoint:[self centerForCellAtModelIndex:[self modelIndexForIndexPath:self.draggedIndexPath]]].x;
        }
        RVVectorAnimation *animation = [RVVectorAnimation vectorAnimationFromValue:startTranslation toValue:GLKVector3Make(0.0, 0.0, 0.0f) withDuration:AnimationDuration];
        [modelSprite addAnimation:animation forKey:@"extraTranslationVector"];
        
        RVVectorAnimation *scaleAnimation = [RVVectorAnimation vectorAnimationFromValue:modelSprite.scaleVector
                                                                                toValue:[self defaultModelScaleVector]
                                                                           withDuration:AnimationDuration];
        [modelSprite addAnimation:scaleAnimation forKey:@"scaleVector"];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        for (RVModelCell *cell in self.tableView.visibleCells) {
            cell.buttonsContainerView.alpha = 1.0f;
        }
    }];
}

#pragma mark - Gesture Recognizers

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == _dragPressRecognizer && (gestureRecognizer.numberOfTouches >= 1 || [touch.view isKindOfClass:[UIButton class]])) {
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.dragPressRecognizer && ![self.tableView pointInside:[gestureRecognizer locationInView:self.tableView] withEvent:nil]) {
        return NO;
    }
    
    if (gestureRecognizer == self.tapRecognizer  && [self.tableView pointInside:[gestureRecognizer locationInView:self.tableView] withEvent:nil]) {
        return NO;
    }
    
    return YES;
}

- (void)tap:(UITapGestureRecognizer *)sender
{
    self.editMode = NO;
}


- (void)dragPressRecognized:(UILongPressGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self.view];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            self.tableView.panGestureRecognizer.enabled = NO;
            self.drags = YES;
            self.draggedIndexPath = [self.tableView indexPathForRowAtPoint:[self.view convertPoint:location toView:self.tableView]];
            self.dragCenterOffset = location.x - [self centerForCellAtModelIndex:[self modelIndexForIndexPath:self.draggedIndexPath]].x;
            [self animateDraggingStart];
            break;
        case UIGestureRecognizerStateChanged:
            [self reorderDraggedObjectIfNeeded];
            [self updateSpritesPositions];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self animateDraggingEnd];
            self.tableView.panGestureRecognizer.enabled = YES;
            self.drags = NO;
            self.draggedIndexPath = nil;
            [self updateSpritesPositions];
            break;
        default:
            break;
    }
    
    
}

@end
