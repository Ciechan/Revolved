//
//  RVFloatAnimation.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 25.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVFloatAnimation.h"

@implementation RVFloatAnimation

- (float)valueForProgress:(float)progress
{
    return _from + (_to - _from) * progress;
}

+ (RVFloatAnimation *)floatAnimationFromValue:(float)fromValue toValue:(float)toValue withDuration:(NSTimeInterval)duration
{
    RVFloatAnimation *floatAnimation = [RVFloatAnimation new];
    floatAnimation.from = fromValue;
    floatAnimation.to = toValue;
    floatAnimation.duration = duration;
    
    return floatAnimation;
}



@end
