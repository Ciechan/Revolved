//
//  RVRootViewController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 24.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "MFMailComposeViewController+SendIfPossible.h"

#import "RVRootViewController.h"
#import "RVModelManager.h"
#import "RVRenderingController.h"

#import "RVModelViewController.h"
#import "RVModelsViewController.h"
#import "RVExportViewController.h"
#import "RVTutorialViewController.h"

#import "RVModelSprite.h"
#import "RVOpenGLView.h"
#import "RVAnimator.h"
#import "RVUserDefaults.h"
#import "RVColorProvider.h"

#import "Camera.h"


#import "NSError+RevolvedErrors.h"


static const CGFloat PreviewWidth = 576.0f;
static const CGFloat PreviewHeight = 768.0f;

@interface RVRootViewController () <RVModelsViewControllerDelegate, RVModelsViewControllerDataSource, RVModelViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet RVOpenGLView *openGLView;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) RVRenderingController *renderingController;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) CFTimeInterval previousTimeStamp;

@property (nonatomic, strong) RVModelManager *modelManager;
@property (nonatomic, strong) RVModel *currentModel;

@property (nonatomic) BOOL showsModel;
@property (nonatomic, strong) RVModelViewController *modelViewController;
@property (nonatomic, strong) RVModelsViewController *modelsViewController;
@property (nonatomic, strong) RVExportViewController *exportViewController;
@property (nonatomic, strong) RVTutorialViewController *tutorialViewController;

@property (nonatomic) BOOL pendingImportAnimation;



@end


@implementation RVRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _modelManager = [[RVModelManager alloc] init];
        _renderingController = [[RVRenderingController alloc] init];
        _renderingController.renderer.camera = [[Camera alloc] init];
        _renderingController.renderer.camera.aspect = PreviewWidth/PreviewHeight;
        _renderingController.renderer.camera.distance = 14.6f;
        
        _modelViewController = [[RVModelViewController alloc] init];
        _modelViewController.previewWidth = PreviewWidth;
        _modelViewController.delegate = self;
        _modelViewController.renderingController = _renderingController;
        
        _modelsViewController = [[RVModelsViewController alloc] init];
        _modelsViewController.delegate = self;
        _modelsViewController.dataSource = self;
        _modelsViewController.previewSize = CGSizeMake(PreviewWidth, PreviewHeight);
        _modelsViewController.renderingController = _renderingController;

        _exportViewController = [[RVExportViewController alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDrawing) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDrawing) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [self importStartModelsIfNeeded];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor rv_backgroundColor];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext: self.context];
    self.openGLView.context = self.context;
    self.openGLView.opaque = YES;
    [self.renderingController setupOpenGL];
    
    [self addChildViewController:self.modelViewController];
    [self.view addSubview:self.modelViewController.view];
    [self.modelViewController didMoveToParentViewController:self];

    self.modelViewController.view.hidden = YES;
    
    [self addChildViewController:self.modelsViewController];
    [self.view addSubview:self.modelsViewController.view];
    [self.modelsViewController didMoveToParentViewController:self];

    self.modelsViewController.delegate = self;
    [self.modelsViewController reloadData];

    [self addChildViewController:self.exportViewController];
    [self.view addSubview:self.exportViewController.view];
    [self.exportViewController didMoveToParentViewController:self];
    
    
    self.showsModel = NO;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayLinkTick:self.displayLink];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)importStartModelsIfNeeded
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HasImportedStartModelsKey]) {
        NSError *error;
        for (int i = 1; i <=3; i++) {
            NSString *fileName = [NSString stringWithFormat:@"model%d", i];
            NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"rvlvd"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            [_modelManager importModelData:data error:&error];
        }

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HasImportedStartModelsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Rendering


- (void)update:(NSTimeInterval)dt
{
    [self.renderingController.cameraController displayTick];
    [self.renderingController.renderer.camera updateMatrices];
    
    if (self.showsModel) {
        [self.modelViewController tick];
    } else {
        [self.modelsViewController tick];
    }

    
    [[RVAnimator sharedAnimator] tick:dt];
}




- (void)displayLinkTick:(CADisplayLink *)sender
{
    CFTimeInterval timeStamp = [sender timestamp];
    CFTimeInterval dt = timeStamp - self.previousTimeStamp;
    
    if (self.previousTimeStamp == 0.0) {
        dt = 1.0/60.0;
    }
    
    self.previousTimeStamp = timeStamp;
    
    [self update:dt];

    [self.openGLView presentWithRenderingBlock:^{
        [self.renderingController.renderer render];
    }];
}

- (void)stopDrawing
{
    self.displayLink.paused = YES;
}

- (void)startDrawing
{
    self.displayLink.paused = NO;
}

- (void)setShowsModel:(BOOL)showsModel
{
    _showsModel = showsModel;
    
    self.modelViewController.view.hidden = !showsModel;
    self.modelsViewController.view.hidden = showsModel;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    if (showsModel) {
        self.renderingController.renderer.meshViewport = CGRectApplyAffineTransform(self.modelViewController.previewFrame, CGAffineTransformMakeScale(scale, scale));
        self.renderingController.renderer.drawingViewport = CGRectApplyAffineTransform(self.modelViewController.drawFrame, CGAffineTransformMakeScale(scale, scale));
        self.renderingController.renderer.drawingTransformMatrix = self.modelViewController.drawMatrix;
    } else {
        self.renderingController.renderer.meshViewport = CGRectApplyAffineTransform(self.view.bounds, CGAffineTransformMakeScale(scale, scale));
        self.renderingController.renderer.drawingViewport = CGRectZero;
    }
}

#pragma mark - RVModelViewControllerDelegate

- (NSString *)documentsPaths
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (void)modelViewControllerDidRequestBack:(RVModelViewController *)controller
{
    [self.modelViewController animateOut];
}

- (void)modelViewControllerDidAnimateOut:(RVModelViewController *)controller
{
    self.showsModel = NO;
    if (self.pendingImportAnimation) {
        self.pendingImportAnimation = NO;
        
        [self.modelsViewController importModelSpriteForModelAtIndex:0];
    }
    
    [self.modelsViewController zoomOut];
}

- (void)modelViewControllerDidAnimateIn:(RVModelViewController *)controller
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HasPlayedTutorialKey]) {
        [self showTutorial];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HasPlayedTutorialKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)modelViewController:(RVModelViewController *)controller didChangeModel:(RVModel *)model
{
    //NSDate *startMeasureDate_BC = [NSDate date];
    
    [self.modelManager saveModel:model];
    
   // NSLog(@"Measured time: %lg", [[NSDate date] timeIntervalSinceDate:startMeasureDate_BC]);
}

- (void)modelViewControllerDidRequestSharePicture:(RVModelViewController *)controller
{
    [self sharePicture];
}


- (void)showTutorial
{
    self.tutorialViewController = [[RVTutorialViewController alloc] init];
    
    __weak RVTutorialViewController *weakController = self.tutorialViewController;
    
    [self addChildViewController:self.tutorialViewController];
    [self.view addSubview:self.tutorialViewController.view];
    [self.tutorialViewController didMoveToParentViewController:self];
    
    [self.tutorialViewController presentWithPostDismissalBlock:^{
        [weakController willMoveToParentViewController:nil];
        [weakController.view removeFromSuperview];
        [weakController removeFromParentViewController];
        
        self.tutorialViewController = nil;
    }];
}

#pragma mark - RVModelsViewControllerDelegate & Data Source

- (NSUInteger)modelsViewControllerNumberOfModels:(RVModelsViewController *)controller
{
    return self.modelManager.numberOfModels;
}

- (RVModel *)modelsViewController:(RVModelsViewController *)controller modelAtIndex:(NSUInteger)modelIndex
{
    return [self.modelManager modelAtIndex:modelIndex];
}

- (CGRect)modelsViewControllerDestinationRectForSelectedModel:(RVModelsViewController *)controller
{
    return CGRectMake(0, 0, PreviewWidth, PreviewHeight);
}



- (void)modelsViewControllerDidAddModel:(RVModelsViewController *)controller
{
    RVModel *newModel = [self.modelManager createNewModel];
    [self.modelViewController setupModel:newModel];
    [controller addNewModelSpriteForModelAtIndex:0];
}

- (void)modelsViewController:(RVModelsViewController *)controller didSelectModelAtIndex:(NSUInteger)modelIndex
{
    [self.modelViewController setupModel:[self.modelManager modelAtIndex:modelIndex]];
}

- (void)modelsViewController:(RVModelsViewController *)controller didDeleteModelAtIndex:(NSUInteger)modelIndex
{
    [self.modelManager deleteModelAtIndex:modelIndex];
}

- (void)modelsViewController:(RVModelsViewController *)controller didCloneModelAtIndex:(NSUInteger)modelIndex
{
    [self.modelManager cloneModelAtIndex:modelIndex];
}

- (void)modelsViewController:(RVModelsViewController *)controller didShareModelAtIndex:(NSUInteger)modelIndex
{
    [self exportModelAtIndex:modelIndex];
}

- (void)modelsViewController:(RVModelsViewController *)controller didMoveModelAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)targetIndex
{
    [self.modelManager moveModelAtIndex:sourceIndex toIndex:targetIndex];
}


- (void)modelsViewController:(RVModelsViewController *)controller didZoomInToModelAtIndex:(NSUInteger)modelIndex
{
    self.showsModel = YES;
    [self.modelViewController animateIn];
}

- (void)modelsViewControllerDidZoomOut:(RVModelsViewController *)controller
{

}

- (void)modelsViewControllerDidRequestTutorial:(RVModelsViewController *)controller
{
    [self showTutorial];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HasPlayedTutorialKey];
}


- (void)showImportedModel
{
    if (self.showsModel) {
        self.pendingImportAnimation = YES;
        [self.modelViewController animateOut];
    } else {
        [self.modelsViewController importModelSpriteForModelAtIndex:0];
    }
}


#pragma mark - Export

- (void)exportModelAtIndex:(NSInteger)modelIndex
{
    RVModel *model = [self.modelManager modelAtIndex:modelIndex];
    
    self.exportViewController.model = model;
    [self.exportViewController present];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultFailed) {
        [MFMailComposeViewController rv_showDefaultFailAlertWithError:error];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}


- (void)sharePicture
{
    UIImage *modelImage = [self modelImage];

    [self.modelViewController presentShareOptionsWithImage:modelImage];
}


- (UIImage *)modelImage
{
    UIImage *snapshotImage = [self.openGLView snapshotWithRenderingBlock:^{
        [self.renderingController.renderer renderModelMesh];
    }];
    

    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(snapshotImage.CGImage, self.renderingController.renderer.meshViewport);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    CGImageRelease(croppedImageRef);
    
    return croppedImage;
}

#pragma mark - File Importing

- (void)handleOpeningURL:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (!data) {
        [self showAlertWithError:[NSError malformedFileError]];
        return;
    }
    
    NSError *error;
    if ([self.modelManager importModelData:data error:&error]) {
        [self showImportedModel];
    } else {
        [self showAlertWithError:error];
    }
}

- (void)showAlertWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
