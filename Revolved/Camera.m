//
//  Camera.m
//  Patterns
//
//  Created by Bartosz Ciechanowski on 23.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "Camera.h"

@implementation Camera

- (id)init
{
    self = [super init];
    if (self) {
        _distance = 2.0;
        _aspect = 1.0;
    }
    return self;
}


- (void)updateMatrices
{
    GLKMatrix4 distanceTranslation = GLKMatrix4MakeTranslation(0, 0, -_distance);
    GLKMatrix4 sceneTranslation = GLKMatrix4MakeTranslation(_sceneTranslation.x, _sceneTranslation.y, _sceneTranslation.z);
    
    _viewMatrix = GLKMatrix4Multiply(sceneTranslation, distanceTranslation);
  
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(M_PI/7.0, _aspect, 11.15, 18.05);
    _projectionMatrix = projectionMatrix;
    
    _viewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, _viewMatrix);
}

@end
