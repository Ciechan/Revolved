//
//  RootViewController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVModelViewController.h"
#import "RVPreviewViewController.h"
#import "RVDrawViewController.h"
#import "RVPictureViewController.h"

#import "RVDrawController.h"
#import "CameraController.h"

#import "RVSpaceConverter.h"
#import "RVRenderingController.h"
#import "RVUserDefaults.h"

#import "RVColorPicker.h"

#import "RVModel.h"
#import "RVModelSprite.h"
#import "RVAxisSprite.h"
#import "RVSegment.h"


static const float LineSize = 4.0f;
static const float GuidelineDotSize = 8.0f;
static const float PointSize = 64.0f;

@interface RVModelViewController () <DrawControllerDelegate, RVPreviewViewControllerDelegate>



@property (nonatomic, strong) RVDrawController *drawController;

@property (nonatomic, strong) RVDrawViewController *drawViewController;
@property (nonatomic, strong) RVPreviewViewController *previewViewController;
@property (nonatomic, strong) RVPictureViewController *pictureViewController;



@property (nonatomic, strong) RVSpaceConverter *converter;

@property (nonatomic, strong) RVModel *model;

@end

@implementation RVModelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _drawController = [[RVDrawController alloc] init];
        _drawController.delegate = self;

        _drawViewController = [[RVDrawViewController alloc] init];
        _drawViewController.drawController = _drawController;
        
        _pictureViewController = [[RVPictureViewController alloc] init];
        
        _previewViewController = [[RVPreviewViewController alloc] init];
        _previewViewController.delegate = self;
        
        _previewWidth = 576.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = nil;
    
    
    
    self.previewViewController.cameraController = self.renderingController.cameraController;
    
    [self addChildViewController:self.previewViewController];
    [self.view addSubview:self.previewViewController.view];
    [self.previewViewController didMoveToParentViewController:self];
    
    [self addChildViewController:self.drawViewController];
    [self.view addSubview:self.drawViewController.view];
    [self.drawViewController didMoveToParentViewController:self];
    
    [self addChildViewController:self.pictureViewController];
    [self.view addSubview:self.pictureViewController.view];
    [self.pictureViewController didMoveToParentViewController:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    CGRect previewFrame, drawFrame;
    CGRectDivide(bounds, &previewFrame, &drawFrame, self.previewWidth, CGRectMinXEdge);
    
    drawFrame.origin.x -= 30.0f;
    drawFrame.size.width += 30.0f;
    
    self.previewViewController.view.frame = previewFrame;
    self.drawViewController.view.frame = drawFrame;
    self.pictureViewController.view.frame = bounds;
    
    self.converter = [[RVSpaceConverter alloc] initWithViewSize:drawFrame.size];
    self.renderingController.pointController.pointSize = sqrtf([self.converter modelSquareDistanceForViewDistance:PointSize]);
    self.renderingController.guidelineController.dotSize = sqrtf([self.converter modelSquareDistanceForViewDistance:GuidelineDotSize]);
    self.renderingController.lineController.lineSize = sqrtf([self.converter modelSquareDistanceForViewDistance:LineSize]);
    self.drawViewController.converter = self.converter;
    
    GLKVector2 a = [self.converter modelPointForViewPoint:CGPointZero];
    GLKVector2 b = [self.converter modelPointForViewPoint:CGPointMake(drawFrame.size.width, drawFrame.size.height)];
    
    _drawFrame = drawFrame;
    _previewFrame = previewFrame;
    _drawMatrix = GLKMatrix4MakeOrtho(a.x, b.x, b.y, a.y, -1.0, 1.0);
}


- (void)setupModel:(RVModel *)model
{
    self.model = model;
    self.drawController.segments = model.segments;
    [self.previewViewController assignSegmentsToSprite:model.segments];
    
    [self.drawViewController addIntitialLineSpritesForSegments:model.segments.set];

}

#pragma mark - Ticks

- (void)tick
{
    [self retesselateWithModel:NO];
    [self.previewViewController tick];
}



#pragma mark -


- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


- (void)presentShareOptionsWithImage:(UIImage *)image
{
    self.pictureViewController.image = image;
    [self.pictureViewController present];
}


#pragma mark - Animation

- (void)animateIn
{
    [self retesselateWithModel:YES];

    self.view.userInteractionEnabled = YES;

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.delegate modelViewControllerDidAnimateIn:self];
    }];
    [self.previewViewController animateInWithDuration:0.3];
    [self.drawViewController animateInWithDuration:0.3];
    [CATransaction commit];

    [self retesselateWithModel:NO];
    
    
}

- (void)animateOut
{
    self.view.userInteractionEnabled = NO;
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.delegate modelViewControllerDidAnimateOut:self];
        [self.drawViewController clearAllSprites];
        [self.drawController clear];
    }];
    [self.previewViewController animateOutWithDuration:0.3];
    [self.drawViewController animateOutWithDuration:0.3];
    [CATransaction commit];
}


#pragma mark - Tesselation



- (void)retesselateWithModel:(BOOL)withModel
{
    if (withModel) {
        [self.previewViewController assignSegmentsToSprite:self.model.segments];
        [self.renderingController.modelController updateBuffersWithModelSprites:@[self.previewViewController.modelSprite]];
        [self.renderingController.axisController updateBuffersWithLineSprites:self.drawViewController.axisSprites];
    }
    
    [self.renderingController.guidelineController updateBuffersWithGuidelineDotSprites:self.drawViewController.guidelineSprites];
    [self.renderingController.lineController updateBuffersWithLineSprites:self.drawViewController.lineSprites];
    
    [self.renderingController.pointController updateBuffersWithPointSprites:self.drawViewController.pointSprites];
}


#pragma mark - RVDrawController Delegate


- (void)drawControllerDidSelectSegment:(RVSegment *)segment
{
    [self.drawViewController removeAllPointSprites];
    [self.drawViewController selectLineSpriteForSegment:segment];
    [self.drawViewController addPointSpritesForPoints:segment.allPoints];
}

- (void)drawControllerDidSelectEndPoint:(RVPoint *)endPoint
{
    
}

- (void)drawControllerDidSelectColorIndex:(NSUInteger)colorIndex
{
    [self.drawViewController setSelectedColorIndex:colorIndex];
}


- (void)drawControllerDidTryAddButReachedSegmentLimit
{
    [self.previewViewController flashSegmentLimitAlert];
}

- (void)drawControllerDidAddSegment:(RVSegment *)segment
{
    [self.drawViewController addLineSpriteForSegment:segment];
    [self retesselateWithModel:YES];
    
    [self.delegate modelViewController:self didChangeModel:self.model];
}

- (void)drawControllerDidModifySegment:(RVSegment *)segment
{
    [self.drawViewController modifyLineSpriteForSegment:segment];
    [self.drawViewController modifyPointSpritesForPoints:segment.allPoints];
    
    [self retesselateWithModel:YES];
}

- (void)drawControllerDidRemoveSegment:(RVSegment *)segment
{
    [self.drawViewController removeLineSpriteForSegment:segment];
    [self.drawViewController dropPointSpritesForPoints:segment.allPoints];
    [self retesselateWithModel:YES];
    
    [self.delegate modelViewController:self didChangeModel:self.model];
}

- (void)drawControllerDidRecolorSegment:(RVSegment *)segment
{
    [self.delegate modelViewController:self didChangeModel:self.model];
    
    [self.drawViewController modifyLineSpriteForSegment:segment];
    [self.drawViewController modifyPointSpritesForPoints:segment.allPoints];
    
    [self retesselateWithModel:YES];
}

- (void)drawControllerDidAddGuideLine:(RVGuideline *)guideline
{
    [self.drawViewController addSpritesForGuideLine:guideline];
}

- (void)drawControllerDidRemoveGuideLine:(RVGuideline *)guideline
{
    [self.drawViewController removeSpritesForGuideLine:guideline];
}

- (void)drawControllerDidStartDraggingPoint:(RVPoint *)point
{
    
}

- (void)drawControllerDidDragPoint:(RVPoint *)point
{}

- (void)drawControllerDidEndDraggingPoint:(RVPoint *)point
{
    [self.delegate modelViewController:self didChangeModel:self.model];
}


#pragma mark - RVPreviewViewControllerDelegate

- (void)previewControllerDidTapCameraButton:(RVPreviewViewController *)controller
{
    [self.delegate modelViewControllerDidRequestSharePicture:self];
}


- (void)previewControllerDidTapBackButton:(RVPreviewViewController *)controller
{
    [self.delegate modelViewControllerDidRequestBack:self];;
}


@end
