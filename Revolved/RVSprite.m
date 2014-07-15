//
//  RVSprite.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 19.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSprite.h"
#import "RVAnimator.h"
#import "RVAnimation_Private.h"

@implementation RVSprite

- (void)addAnimation:(RVAnimation *)animation forKey:(NSString *)key
{
    [[RVAnimator sharedAnimator] addAnimation:animation forKey:key toTarget:self];
}

- (RVAnimation *)animationForKey:(NSString *)key
{
    return [[RVAnimator sharedAnimator] animationforKey:key forTarget:self];
}

- (void)removeAnimationForKey:(NSString *)key
{
    [[RVAnimator sharedAnimator] removeAnimationForKey:key fromTarget:self];
}

@end
