//
//  RVGuidlineDotMeshController.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 04.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVMeshController.h"

@interface RVGuidlineDotMeshController : RVMeshController

@property (nonatomic) float dotSize;

- (void)updateBuffersWithGuidelineDotSprites:(NSArray *)dotSprites;


@end
