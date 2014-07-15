//
//  RVRenderingController.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 08.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVModelMeshController.h"
#import "RVAxisMeshController.h"
#import "RVGuidlineDotMeshController.h"
#import "RVLineMeshController.h"
#import "RVPointMeshController.h"

#import "CameraController.h"
#import "Renderer.h"

@interface RVRenderingController : NSObject

@property (nonatomic, strong) Renderer *renderer;
@property (nonatomic, strong) CameraController *cameraController;

@property (nonatomic, strong) RVModelMeshController *modelController;
@property (nonatomic, strong) RVAxisMeshController *axisController;
@property (nonatomic, strong) RVGuidlineDotMeshController *guidelineController;
@property (nonatomic, strong) RVLineMeshController *lineController;
@property (nonatomic, strong) RVPointMeshController *pointController;

- (void)setupOpenGL;

@end
