//
//  PreviewViewController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVPreviewViewController.h"
#import "CameraController.h"
#import "Color.h"

#import "RVModelSprite.h"
#import "RVAxisSprite.h"
#import "RVFloatAnimation.h"


@interface RVPreviewViewController() <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIImageView *segmentLimitImage;

@end

@implementation RVPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _modelSprite = [RVModelSprite new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:self.cameraController.panRecognizer];
    [self.view addGestureRecognizer:self.cameraController.rotationRecognizer];
    
    self.cameraButton.exclusiveTouch = YES;
    self.backButton.exclusiveTouch = YES;
    self.segmentLimitImage.hidden = YES;
}

- (void)viewDidLayoutSubviews
{
    [self.cameraController setRenderSurfaceSize:self.view.bounds.size];
}

- (void)tick
{
    self.modelSprite.quaternion = self.cameraController.quaternion;
}

- (void)resetRecognizers
{
    self.cameraController.panRecognizer.enabled = NO;
    self.cameraController.panRecognizer.enabled = YES;
    
    self.cameraController.rotationRecognizer.enabled = NO;
    self.cameraController.rotationRecognizer.enabled = YES;
}

- (void)flashSegmentLimitAlert
{
    self.segmentLimitImage.alpha = 0.0f;
    self.segmentLimitImage.hidden = NO;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.segmentLimitImage.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:2.0 animations:^{
                self.segmentLimitImage.alpha = 0.0f;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.segmentLimitImage.hidden = YES;
                }
            }];
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.cameraController stop];
    
    RVFloatAnimation *alphaAnimation = [RVFloatAnimation floatAnimationFromValue:self.modelSprite.axisAlpha toValue:1.0 withDuration:0.3];
    alphaAnimation.delay = self.modelSprite.axisAlpha == 0.0f ? 0.1 : 0.0f;
    [self.modelSprite addAnimation:alphaAnimation forKey:@"axisAlpha"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    RVFloatAnimation *alphaAnimation = [RVFloatAnimation floatAnimationFromValue:self.modelSprite.axisAlpha toValue:0.0 withDuration:0.3];
    alphaAnimation.delay = self.modelSprite.axisAlpha == 1.0f ? 0.5 : 0.0f;
    [self.modelSprite addAnimation:alphaAnimation forKey:@"axisAlpha"];
}

- (IBAction)cameraButtonTapped:(UIButton *)sender
{
    [self resetRecognizers];
    [self.delegate previewControllerDidTapCameraButton:self];
}

- (IBAction)backButtonTapped:(UIButton *)sender
{
    [self resetRecognizers];
    [self.delegate previewControllerDidTapBackButton:self];
}

- (void)assignSegmentsToSprite:(NSOrderedSet *)segments
{
    self.cameraButton.enabled = segments.count > 0;
    self.modelSprite.drawnSegments = segments.array;
}

- (void)animateInWithDuration:(NSTimeInterval)duration
{
    self.backButton.alpha = 0.0f;
    self.cameraButton.alpha = 0.0f;
    [self.cameraController resetPosition];
    self.modelSprite.quaternion = self.cameraController.quaternion;

    [UIView animateWithDuration:duration animations:^{
        self.backButton.alpha = 1.0f;
        self.cameraButton.alpha = 1.0f;
    }];
}

- (void)animateOutWithDuration:(NSTimeInterval)duration
{
    [self.cameraController animateToStartPositionWithDuration:duration*0.9];
    
    RVFloatAnimation *alphaAnimation = [RVFloatAnimation floatAnimationFromValue:self.modelSprite.axisAlpha toValue:0.0 withDuration:duration];
    [self.modelSprite addAnimation:alphaAnimation forKey:@"axisAlpha"];
    
    [UIView animateWithDuration:duration animations:^{
        self.backButton.alpha = 0.0f;
        self.cameraButton.alpha = 0.0f;
    }];
}

@end
