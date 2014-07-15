//
//  RVAnimation.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 25.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(void);

typedef NS_ENUM(NSInteger, RVAnimationCurve) {
    RVAnimationCurveEaseInOut,
    RVAnimationCurveEaseIn,
    RVAnimationCurveEaseOut,
    RVAnimationCurveQuartEaseOut,
    RVAnimationCurveQuinticEaseInOut,
    RVAnimationCurveElasticEaseOut,
    RVAnimationCurveJumpEaseIn,
    RVAnimationCurveJumpEaseOut,
    RVAnimationCurveJelly,
    RVAnimationCurveLinear
};



@interface RVAnimation : NSObject

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) NSTimeInterval time; // don't touch unless you know what you're doing

@property (nonatomic) RVAnimationCurve animationCurve;

@property (nonatomic, copy) CompletionBlock completionBlock;

@end
