//
//  RVModelSprite.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 24.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVModelSprite.h"
#import "RVQuaternionAnimation.h"

@implementation RVModelSprite

- (id)init
{
    self = [super init];
    if (self) {
        _scaleVector = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _quaternion = BaseQuaternion;
        _modelScaleVector = GLKVector3Make(1.0f, 1.0f, 1.0f);
    }
    return self;
}

@end
