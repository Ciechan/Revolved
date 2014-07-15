//
//  UIView+RotationAnimation.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 28.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVAnimation;
@interface UIView (RotationAnimation)

- (void)rv_setRotation:(float)rotation;
- (float)rv_Rotation;

- (void)rv_addAnimation:(RVAnimation *)animation forKey:(NSString *)key;

@end
