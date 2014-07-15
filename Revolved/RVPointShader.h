//
//  RVPointShader.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 15.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "BCShader.h"

@interface RVPointShader : BCShader

@property (nonatomic) GLint viewProjectionMatrixUniform;
@property (nonatomic) GLint texSamplerUniform;


@end
