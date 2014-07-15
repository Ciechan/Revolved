//
//  BCCamera.h
//  Patterns
//
//  Created by Bartosz Ciechanowski on 23.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Camera : NSObject

//@property (nonatomic) GLKQuaternion rotation;
@property (nonatomic) float distance;
@property (nonatomic) float aspect;

@property (nonatomic) GLKVector3 sceneTranslation;

@property (nonatomic, readonly) GLKMatrix4 viewMatrix;
@property (nonatomic, readonly) GLKMatrix4 viewProjectionMatrix;

//@property (nonatomic, readonly) GLKMatrix4 rotationMatrix;
@property (nonatomic, readonly) GLKMatrix4 projectionMatrix;

- (void)updateMatrices;

@end
