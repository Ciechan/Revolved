//
//  CameraController.h
//  Patterns
//
//  Created by Bartosz Ciechanowski on 23.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Camera;

@interface CameraController : NSObject

@property (nonatomic) CGSize renderSurfaceSize;
@property (nonatomic, readonly) GLKQuaternion quaternion;

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong, readonly) UIRotationGestureRecognizer *rotationRecognizer;

- (void)resetPosition;
- (void)stop;

- (void)displayTick;
- (void)animateToStartPositionWithDuration:(NSTimeInterval)duration;


@end
