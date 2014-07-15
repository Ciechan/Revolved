//
//  RVAnimator.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 25.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RVAnimation;
@interface RVAnimator : NSObject

+ (instancetype)sharedAnimator;

- (void)addAnimation:(RVAnimation *)animation forKey:(NSString *)key toTarget:(id)target;
- (RVAnimation *)animationforKey:(NSString *)key forTarget:(id)target;
- (void)removeAnimationForKey:(NSString *)key fromTarget:(id)target;

- (void)tick:(NSTimeInterval)dt;

@end
