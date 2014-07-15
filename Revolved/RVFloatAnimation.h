//
//  RVFloatAnimation.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 25.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVAnimation.h"

@interface RVFloatAnimation : RVAnimation

@property (nonatomic) float from;
@property (nonatomic) float to;

- (float)valueForProgress:(float)progress;
+ (RVFloatAnimation *)floatAnimationFromValue:(float)fromValue toValue:(float)toValue withDuration:(NSTimeInterval)duration;

@end
