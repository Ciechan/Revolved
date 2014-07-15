//
//  RVColorProvider.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 18.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSUInteger ColorCount;

@interface RVColorProvider : NSObject

+ (UIColor *)colorForColorIndex:(NSUInteger)colorIndex;
+ (GLKVector3)vectorForColorIndex:(NSUInteger)colorIndex;
+ (GLKVector3)vectorForDesaturatedColorIndex:(NSUInteger)colorIndex;

+ (GLKVector3)vectorForBackgroundColor;
+ (GLKVector3)vectorForAxisColor;

+ (NSString *)mtlString;

@end
