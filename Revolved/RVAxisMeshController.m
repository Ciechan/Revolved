//
//  RVAxisMeshController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 02.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVAxisMeshController.h"
#import "RVMeshController_Private.h"

#import "RVLineSprite.h"
#import "AxisVertex.h"
#import "BCShader.h"

static const NSUInteger VertexLimit = 512;
static const NSUInteger IndexLimit = VertexLimit * 4;


static const NSUInteger VerticesInSegment = 1;
static const NSUInteger IndiciesInSegment = 2;

@implementation RVAxisMeshController

- (void)setupVAO
{
    glGenVertexArraysOES(1, &_VAO);
    glBindVertexArrayOES(_VAO);
    
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, VertexLimit * sizeof(AxisVertex), NULL, GL_DYNAMIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, IndexLimit * sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(VertexAttribPosition);
    glVertexAttribPointer(VertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(AxisVertex), (void *)offsetof(AxisVertex, p));
    
    glEnableVertexAttribArray(VertexAttribColor);
    glVertexAttribPointer(VertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(AxisVertex), (void *)offsetof(AxisVertex, color));
    
    
    glBindVertexArrayOES(0);
}


- (void)updateBuffersWithLineSprites:(NSArray *)lineSprites
{
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    AxisVertex *vertexData = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    GLushort *indexData = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    
    GLuint totalIndicies = 0;
    GLuint totalVertices = 0;
    
    for (RVLineSprite *sprite in lineSprites) {
        NSUInteger verticesCount;
        NSUInteger indiciesCount;
        
        if (![self tessellateSprite:sprite vertexData:vertexData indexData:indexData startVertexIndex:totalVertices verticesCount:&verticesCount indiciesCount:&indiciesCount]) {
            break;
        }
        
        sprite.indiciesCount = (GLuint)indiciesCount;
        sprite.indiciesOffset = totalIndicies;
        
        totalIndicies += indiciesCount;
        totalVertices += verticesCount;
        
        vertexData += verticesCount;
        indexData += indiciesCount;
    }
    
    
    _indiciesCount = totalIndicies;
    
    glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
    glUnmapBufferOES(GL_ARRAY_BUFFER);
}

- (BOOL)tessellateSprite:(RVLineSprite *)sprite
              vertexData:(AxisVertex *)vertexData
               indexData:(GLushort *)indexData
        startVertexIndex:(NSUInteger)startVertex
           verticesCount:(out NSUInteger *)verticesCount
           indiciesCount:(out NSUInteger *)indiciesCount
{
    AxisVertex v[VerticesInSegment];
    GLushort i[IndiciesInSegment];
    
    NSUInteger totalIndicies = 0;
    NSUInteger totalVertices = 0;
    
    GLKVector3 color = sprite.color;
    v[0].color = GLKVector4Make(0.0, 0.0, 0.0, MIN(1.0f, 1.1f - color.r));
    
    NSUInteger tesselationSegments = sprite.tesselationSegments;
    SegmentTesselator tessalator = sprite.tesselator;
    
    if (startVertex + (tesselationSegments + 1) * VerticesInSegment > VertexLimit) {
        return NO;
    }
    
    for (int seg = 0; seg < tesselationSegments + 1; seg++) {
        
        SegmentTesselation tess = tessalator((double)seg/(double)tesselationSegments);
        v[0].p = GLKVector3Make(tess.p.x, tess.p.y, 0.0f);
        
        memcpy(vertexData, v, sizeof(v));
        vertexData += VerticesInSegment;
        totalVertices += VerticesInSegment;
    }
    
    for (int seg = 0; seg < tesselationSegments; seg++) {
        
        i[0] = startVertex + 0;
        i[1] = startVertex + 1;
        
        memcpy(indexData, i, sizeof(i));
        indexData += IndiciesInSegment;
        totalIndicies += IndiciesInSegment;
        
        startVertex += VerticesInSegment;
    }
    
    *verticesCount = totalVertices;
    *indiciesCount = totalIndicies;
    
    return YES;
}


@end
