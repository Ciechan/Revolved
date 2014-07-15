//
//  RVColorAnimation.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 25.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVVectorAnimation.h"

@implementation RVVectorAnimation

- (GLKVector3)valueForProgress:(float)progress
{
    return GLKVector3Add(GLKVector3MultiplyScalar(_to, progress), GLKVector3MultiplyScalar(_from, 1.0f - progress));
}

+ (RVVectorAnimation *)vectorAnimationFromValue:(GLKVector3)fromValue toValue:(GLKVector3)toValue withDuration:(NSTimeInterval)duration
{
    RVVectorAnimation *colorAnimation = [RVVectorAnimation new];
    colorAnimation.from = fromValue;
    colorAnimation.to = toValue;
    colorAnimation.duration = duration;
    
    return colorAnimation;
}


@end
