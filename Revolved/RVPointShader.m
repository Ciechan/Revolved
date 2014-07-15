//
//  RVPointShader.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 15.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVPointShader.h"

@implementation RVPointShader

- (void)bindAttributeLocations
{
    glBindAttribLocation(self.program, VertexAttribPosition, "position");
    glBindAttribLocation(self.program, VertexAttribTexCoord, "texCoord");
    glBindAttribLocation(self.program, VertexAttribAlpha, "alpha");
}

- (void)getUniformLocations
{
    self.viewProjectionMatrixUniform = glGetUniformLocation(self.program, "viewProjectionMatrix");
    self.texSamplerUniform = glGetUniformLocation(self.program, "texSampler");

}

- (NSString *)shaderName
{
    return @"RVPointShader";
}


@end
