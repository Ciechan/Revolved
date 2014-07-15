//
//  BCShader.h
//
//  Created by Bartosz Ciechanowski on 23.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

typedef enum {
    VertexAttribPosition,
    VertexAttribNormal,
    VertexAttribColor,
    VertexAttribTexCoord,
    VertexAttribAlpha,
} VertexAttrib;

#import <Foundation/Foundation.h>

@interface BCShader : NSObject
@property (nonatomic, readonly) GLuint program;

- (BOOL)loadProgram;

@end
