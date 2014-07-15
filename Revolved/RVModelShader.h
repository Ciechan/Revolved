//
//  PatternShader.h
//  Patterns
//
//  Created by Bartosz Ciechanowski on 25.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "BCShader.h"

@interface RVModelShader : BCShader

@property (nonatomic) GLint viewProjectionModelMatrixUniform;
@property (nonatomic) GLint normalModelMatrixUniform;
@property (nonatomic) GLint texSamplerUniform;
@property (nonatomic) GLint trigonometryUniform;

@end
