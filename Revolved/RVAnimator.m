//
//  RVAnimator.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 25.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVAnimator.h"
#import "RVAnimation_Private.h"

#import "RVAnimation.h"
#import "RVFloatAnimation.h"
#import "RVVectorAnimation.h"
#import "RVQuaternionAnimation.h"

#import "RVLineSprite.h"
#import "RVPointSprite.h"
#import "RVModelSprite.h"

#import "UIView+RotationAnimation.h"

typedef float (^Executor)(RVAnimation *animation, float p);
typedef float (*Curve)(float time);

static NSDictionary *keyExecutorMap;


@interface RVAnimator()

@property (nonatomic, strong) NSMapTable *targetToAnimationsDictionaryMap;
@property (nonatomic, strong) NSHashTable *allAnimations;

@end

@implementation RVAnimator

+ (instancetype)sharedAnimator
{
    static RVAnimator *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[RVAnimator alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.targetToAnimationsDictionaryMap = [NSMapTable weakToStrongObjectsMapTable];
        self.allAnimations = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (NSMutableDictionary *)animationDictionaryForTarget:(id)target
{
    NSMutableDictionary *dictionary = [self.targetToAnimationsDictionaryMap objectForKey:target];
    
    if (!dictionary) {
        dictionary = [NSMutableDictionary dictionary];
        [self.targetToAnimationsDictionaryMap setObject:dictionary forKey:target];
    }
    
    return dictionary;
}

- (void)addAnimation:(RVAnimation *)animation forKey:(NSString *)key toTarget:(id)target
{
    animation.target = target;
    animation.key = key;
    animation.time = -animation.delay;
    [self animationDictionaryForTarget:target][key] = animation;
    [self.allAnimations addObject:animation];
}

- (RVAnimation *)animationforKey:(NSString *)key forTarget:(id)target
{
    return [self.targetToAnimationsDictionaryMap objectForKey:target][key];
}

- (void)removeAnimationForKey:(NSString *)key fromTarget:(id)target
{
    NSMutableDictionary *dict = [self animationDictionaryForTarget:target];
    RVAnimation *animation = [dict objectForKey:key];
    if (animation) {
        [self.allAnimations removeObject:animation];
    }

    [dict removeObjectForKey:key];
    if (dict.count == 0) {
        [self.targetToAnimationsDictionaryMap removeObjectForKey:target];
    }
}



- (void)tick:(NSTimeInterval)dt
{
    NSMutableArray *completionBlocks = [NSMutableArray array];
    for (RVAnimation *animation in self.allAnimations.allObjects) {
        animation.time += dt;
        
        Executor executor = keyExecutorMap[animation.key];
        NSAssert(executor, @"Animating non animatable property %@", animation.key);
        
        float time = animation.time/animation.duration;
        time = MIN(MAX(0.0f, time), 1.0f);

        float progress = curves[animation.animationCurve](time);
        
        executor(animation, progress);
        
        if (time >= 1.0f) {
            [self removeAnimationForKey:animation.key fromTarget:animation.target];
            if (animation.completionBlock) {
                [completionBlocks addObject:animation.completionBlock];
            }
        }
    }
    
    for (CompletionBlock block in completionBlocks) {
        block();
    }
}

- (void)setStartQuaternion:(GLKQuaternion)quaternion {}

+ (void)initialize
{
    keyExecutorMap = @{
                       @"color" : ^(RVVectorAnimation *animation, float p){
                           [(RVLineSprite *)animation.target setColor:[animation valueForProgress:p]];
                       },
                       @"burnout" : ^(RVFloatAnimation *animation, float p){
                           [(RVLineSprite *)animation.target setBurnout:[animation valueForProgress:p]];
                       },
                       @"rotation" : ^(RVFloatAnimation *animation, float p){
                           [(UIView *)animation.target rv_setRotation:[animation valueForProgress:p]];
                       },
                       @"alpha" : ^(RVFloatAnimation *animation, float p){
                           [(RVPointSprite *)animation.target setAlpha:[animation valueForProgress:p]];
                       },
                       @"axisAlpha" : ^(RVFloatAnimation *animation, float p){
                           [(RVModelSprite *)animation.target setAxisAlpha:[animation valueForProgress:p]];
                       },
                       @"scale" : ^(RVFloatAnimation *animation, float p){
                           [(RVPointSprite *)animation.target setScale:[animation valueForProgress:p]];
                       },
                       @"extraTranslationVector" : ^(RVVectorAnimation *animation, float p){
                           [(RVModelSprite *)animation.target setExtraTranslationVector:[animation valueForProgress:p]];
                       },
                       @"scaleVector" : ^(RVVectorAnimation *animation, float p){
                           [(RVModelSprite *)animation.target setScaleVector:[animation valueForProgress:p]];
                       },
                       @"modelScaleVector" : ^(RVVectorAnimation *animation, float p){
                           [(RVModelSprite *)animation.target setModelScaleVector:[animation valueForProgress:p]];
                       },
                       @"widthMultiplier" : ^(RVFloatAnimation *animation, float p){
                           [(RVLineSprite *)animation.target setWidthMultiplier:[animation valueForProgress:p]];
                       },
                       @"startQuaternion" : ^(RVQuaternionAnimation *animation, float p){
                           [(RVAnimator *)animation.target setStartQuaternion:[animation valueForProgress:p]];
                       },
                       @"quaternion" : ^(RVQuaternionAnimation *animation, float p){
                           [(RVModelSprite *)animation.target setQuaternion:[animation valueForProgress:p]];
                       },
                       @"wait" : ^(RVFloatAnimation *animation, float p){
                       },
                       };
}

#pragma mark - Animation curves

float easeOut(float time)
{
    return - time * (time - 2.0f);
}

float easeIn(float time)
{
    return time * time;
}

float linear(float time)
{
    return time;
}

float easeInOut(float time)
{
    return time * time * (3.0f - 2.0f * time);
}

float easeOutQuart(float time)
{
    float nt = 1.0f - time;
    
    return 1.0f - nt*nt*nt*nt;
}


float elasticEaseOut(float t)
{
    return 0.7*sinf(M_PI*t*4.0f)*expf(-5.0f*t) + 1.0f - expf(-14.0f*t);
}

float jumpEaseIn(float t)
{
    return t*(t - 0.2f)/0.8f;
}

float jumpEaseOut(float t)
{
    return t*t*(5.0f - 3.75f*t - 2.5*t*t + 2.25*t*t*t);
}

float quinticEaseInOut(float t)
{
    return t*t*t*(10.0f - 15.0f*t + 6.0f*t*t);
}

float jelly(float t)
{
    return (sinf(6.0f * t * (float)M_PI) * (t - 1.0f) * (t - 1.0f)) * 0.5f + 0.5f;
}


static Curve curves[] = {
    [RVAnimationCurveEaseInOut] = easeInOut,
    [RVAnimationCurveEaseIn] = easeIn,
    [RVAnimationCurveEaseOut] = easeOut,
    [RVAnimationCurveLinear] = linear,
    [RVAnimationCurveQuartEaseOut] = easeOutQuart,
    [RVAnimationCurveElasticEaseOut] = elasticEaseOut,
    [RVAnimationCurveJumpEaseIn] = jumpEaseIn,
    [RVAnimationCurveJumpEaseOut] = jumpEaseOut,
    [RVAnimationCurveQuinticEaseInOut] = quinticEaseInOut,
    [RVAnimationCurveJelly] = jelly,
    
};


@end
