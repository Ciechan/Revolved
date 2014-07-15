//
//  MeshController.h
//  Patterns
//
//  Created by Bartosz Ciechanowski on 24.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVMeshController.h"

@interface RVModelMeshController : RVMeshController

- (void)updateBuffersWithModelSprites:(NSArray *)modelSprites;

@property (nonatomic, strong, readonly) NSArray *sprites;

@end
