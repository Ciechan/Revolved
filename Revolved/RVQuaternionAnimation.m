//
//  RVQuaternionAnimation.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 08.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVQuaternionAnimation.h"

GLKQuaternion BaseQuaternion;

@implementation RVQuaternionAnimation

__attribute__((constructor))
static void initializeBaseQuaternion() {
    BaseQuaternion = GLKQuaternionMakeWithAngleAndAxis(0.615479709, 1, 0, 0);
}

- (GLKQuaternion)valueForProgress:(float)progress
{
    return GLKQuaternionSlerp(_from, _to, progress);
}


+ (RVQuaternionAnimation *)quaternionAnimationFromValue:(GLKQuaternion)fromValue toValue:(GLKQuaternion)toValue withDuration:(NSTimeInterval)duration
{
    RVQuaternionAnimation *animation = [RVQuaternionAnimation new];
    animation.from = fromValue;
    animation.to = toValue;
    animation.duration = duration;
    
    return animation;
}

@end
