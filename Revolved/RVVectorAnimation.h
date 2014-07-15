//
//  RVColorAnimation.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 25.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVAnimation.h"

@interface RVVectorAnimation : RVAnimation

@property (nonatomic) GLKVector3 from;
@property (nonatomic) GLKVector3 to;

- (GLKVector3)valueForProgress:(float)progress;
+ (RVVectorAnimation *)vectorAnimationFromValue:(GLKVector3)fromValue toValue:(GLKVector3)toValue withDuration:(NSTimeInterval)duration;

@end
