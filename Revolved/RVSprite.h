//
//  RVSprite.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 19.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RVAnimation;
@interface RVSprite : NSObject

@property (nonatomic) GLuint indiciesOffset;
@property (nonatomic) GLuint indiciesCount;

- (void)addAnimation:(RVAnimation *)animation forKey:(NSString *)key;
- (RVAnimation *)animationForKey:(NSString *)key;
- (void)removeAnimationForKey:(NSString *)key;


@end
