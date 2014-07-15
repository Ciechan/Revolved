//
//  PatternShader.m
//  Patterns
//
//  Created by Bartosz Ciechanowski on 25.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVModelShader.h"

@implementation RVModelShader

- (void)bindAttributeLocations
{
    glBindAttribLocation(self.program, VertexAttribPosition, "position");
    glBindAttribLocation(self.program, VertexAttribNormal, "normal");
    glBindAttribLocation(self.program, VertexAttribColor, "color");
    glBindAttribLocation(self.program, VertexAttribTexCoord, "texCoord");

}

- (void)getUniformLocations
{
    self.viewProjectionModelMatrixUniform = glGetUniformLocation(self.program, "viewProjectionModelMatrix");
    self.normalModelMatrixUniform = glGetUniformLocation(self.program, "normalModelMatrix");
    self.texSamplerUniform = glGetUniformLocation(self.program, "texSampler");
    self.trigonometryUniform = glGetUniformLocation(self.program, "trig");
}

- (NSString *)shaderName
{
    return @"RVModelShader";
}

@end
