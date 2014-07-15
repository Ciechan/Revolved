//
//  Vertex.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#ifndef Revolved_Vertex_h
#define Revolved_Vertex_h

typedef struct Vertex {
    GLKVector3 p;
    GLKVector3 n;
    GLKVector3 color;
    GLKVector2 uv;
} Vertex;

#endif
