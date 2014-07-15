//
//  RVPointMeshController.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVMeshController.h"

@interface RVPointMeshController : RVMeshController

@property (nonatomic) float pointSize;

- (void)updateBuffersWithPointSprites:(NSArray *)pointSprites;

@end
