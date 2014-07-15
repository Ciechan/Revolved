//
//  LineShader.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 07.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVLineShader.h"

@implementation RVLineShader

- (void)bindAttributeLocations
{
    glBindAttribLocation(self.program, VertexAttribPosition, "position");
    glBindAttribLocation(self.program, VertexAttribColor, "color");
}

- (void)getUniformLocations
{
    self.viewProjectionMatrixUniform = glGetUniformLocation(self.program, "viewProjectionMatrix");
}

- (NSString *)shaderName
{
    return @"RVLineShader";
}


@end
