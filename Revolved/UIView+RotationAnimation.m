//
//  UIView+RotationAnimation.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 28.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "UIView+RotationAnimation.h"
#import "RVAnimator.h"

@implementation UIView (RotationAnimation)

- (void)rv_setRotation:(float)rotation;
{
    self.transform = CGAffineTransformMakeRotation(rotation);
}

- (float)rv_Rotation
{
    float value = atan2f(self.transform.b, self.transform.a);
    
    return value;
}

- (void)rv_addAnimation:(RVAnimation *)animation forKey:(NSString *)key
{
    [[RVAnimator sharedAnimator] addAnimation:animation forKey:key toTarget:self];
}




@end
