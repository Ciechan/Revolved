//
//  RVAxisShader.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 02.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVAxisShader.h"

@implementation RVAxisShader

- (void)bindAttributeLocations
{
    glBindAttribLocation(self.program, VertexAttribPosition, "position");
    glBindAttribLocation(self.program, VertexAttribColor, "color");
}

- (void)getUniformLocations
{
    self.alphaUniform = glGetUniformLocation(self.program, "axisAlpha");
    self.viewProjectionModelMatrixUniform = glGetUniformLocation(self.program, "viewProjectionModelMatrix");
}

- (NSString *)shaderName
{
    return @"RVAxisShader";
}

@end
