//
//  RVQuaternionAnimation.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 08.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVAnimation.h"

extern GLKQuaternion BaseQuaternion;

@interface RVQuaternionAnimation : RVAnimation

@property (nonatomic) GLKQuaternion from;
@property (nonatomic) GLKQuaternion to;

- (GLKQuaternion)valueForProgress:(float)progress;
+ (RVQuaternionAnimation *)quaternionAnimationFromValue:(GLKQuaternion)fromValue toValue:(GLKQuaternion)toValue withDuration:(NSTimeInterval)duration;

@end
