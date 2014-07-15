//
//  RVRenderingController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 08.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVRenderingController.h"
#import "Camera.h"

@implementation RVRenderingController

- (id)init
{
    self = [super init];
    if (self) {
        _modelController = [[RVModelMeshController alloc] init];
        _axisController = [[RVAxisMeshController alloc] init];
        _guidelineController = [[RVGuidlineDotMeshController alloc] init];
        _lineController = [[RVLineMeshController alloc] init];
        _pointController = [[RVPointMeshController alloc] init];
        _cameraController = [[CameraController alloc] init];
        
        _renderer = [[Renderer alloc] init];
        _renderer.camera = [[Camera alloc] init];
        _renderer.modelController = _modelController;
        _renderer.axisController = _axisController;
        _renderer.guidlineController = _guidelineController;
        _renderer.lineController = _lineController;
        _renderer.pointController = _pointController;
    }
    return self;
}

- (void)setupOpenGL
{
    [self.renderer setupOpenGL];
    
    [self.modelController setupOpenGL];
    [self.axisController setupOpenGL];
    [self.guidelineController setupOpenGL];
    [self.lineController setupOpenGL];
    [self.pointController setupOpenGL];
}



@end
