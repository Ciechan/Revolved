//
//  Renderer.h
//  Patterns
//
//  Created by Bartosz Ciechanowski on 23.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Camera, RVModelMeshController, RVAxisMeshController, RVLineMeshController, RVPointMeshController, RVGuidlineDotMeshController;

@interface Renderer : NSObject

@property (nonatomic, strong) Camera *camera;
@property (nonatomic, strong) RVModelMeshController *modelController;
@property (nonatomic, strong) RVAxisMeshController *axisController;
@property (nonatomic) CGRect meshViewport;


@property (nonatomic, strong) RVGuidlineDotMeshController *guidlineController;
@property (nonatomic, strong) RVLineMeshController *lineController;
@property (nonatomic, strong) RVPointMeshController *pointController;
@property (nonatomic) CGRect drawingViewport;
@property (nonatomic) GLKMatrix4 drawingTransformMatrix;

- (void)setupOpenGL;

- (void)render;
- (void)renderModelMesh;


@end
