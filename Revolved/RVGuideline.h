//
//  RVGuideline.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 11.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVGuideline : NSObject

@property (nonatomic) BOOL enabled;

@property (nonatomic) GLKVector2 start;
@property (nonatomic) GLKVector2 end;

@property (nonatomic) GLKVector2 direction;
@property (nonatomic) float length;

@end
