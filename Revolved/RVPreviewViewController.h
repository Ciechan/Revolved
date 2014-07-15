//
//  PreviewViewController.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class RVModelSprite, RVPreviewViewController, CameraController, RVAxisSprite;


@protocol RVPreviewViewControllerDelegate <NSObject>

- (void)previewControllerDidTapCameraButton:(RVPreviewViewController *)controller;
- (void)previewControllerDidTapBackButton:(RVPreviewViewController *)controller;

@end

@interface RVPreviewViewController : UIViewController

@property (nonatomic, weak) id<RVPreviewViewControllerDelegate> delegate;
@property (nonatomic, strong) RVModelSprite *modelSprite;

@property (nonatomic, strong) CameraController *cameraController;

- (void)tick;
- (void)assignSegmentsToSprite:(NSOrderedSet *)segments;

- (void)animateInWithDuration:(NSTimeInterval)duration;
- (void)animateOutWithDuration:(NSTimeInterval)duration;

- (void)flashSegmentLimitAlert;

@end
