//
//  RVAxisShader.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 02.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "BCShader.h"

@interface RVAxisShader : BCShader

@property (nonatomic) GLint alphaUniform;
@property (nonatomic) GLint viewProjectionModelMatrixUniform;

@end
