//
//  LineController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 07.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVLineMeshController.h"
#import "RVMeshController_Private.h"
#import "RVColorProvider.h"
#import "BCShader.h"
#import "RVSegment.h"

#import "LineVertex.h"
#import "RVLineSprite.h"

static const NSUInteger VertexLimit = USHRT_MAX;
static const NSUInteger IndexLimit = VertexLimit * 4;


static const NSUInteger VerticesInSegment = 2;
static const NSUInteger IndiciesInSegment = 6;

@interface RVLineMeshController()
@end

@implementation RVLineMeshController



- (void)setupVAO
{
    glGenVertexArraysOES(1, &_VAO);
    glBindVertexArrayOES(_VAO);
    
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, VertexLimit * sizeof(LineVertex), NULL, GL_DYNAMIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, IndexLimit * sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(VertexAttribPosition);
    glVertexAttribPointer(VertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(LineVertex), (void *)offsetof(LineVertex, p));
    
    glEnableVertexAttribArray(VertexAttribColor);
    glVertexAttribPointer(VertexAttribColor,    3, GL_FLOAT, GL_FALSE, sizeof(LineVertex), (void *)offsetof(LineVertex, color));
    
    glBindVertexArrayOES(0);
}

- (void)updateBuffersWithLineSprites:(NSArray *)lineSprites
{
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    LineVertex *vertexData = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    GLushort *indexData = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    
    GLuint totalIndicies = 0;
    GLuint totalVertices = 0;
    
    for (RVLineSprite *sprite in lineSprites) {
        NSUInteger verticesCount;
        NSUInteger indiciesCount;
        
        BOOL hasFilledAll = [self tessellateSprite:sprite vertexData:vertexData indexData:indexData startVertexIndex:totalVertices verticesCount:&verticesCount indiciesCount:&indiciesCount];
        
        if (!hasFilledAll) {
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
              vertexData:(LineVertex *)vertexData
               indexData:(GLushort *)indexData
        startVertexIndex:(NSUInteger)startVertex
           verticesCount:(out NSUInteger *)verticesCount
           indiciesCount:(out NSUInteger *)indiciesCount
{
    LineVertex v[VerticesInSegment];
    GLushort i[IndiciesInSegment];
    
    NSUInteger totalIndicies = 0;
    NSUInteger totalVertices = 0;
    
    GLKVector3 color = sprite.color;
    v[0].color = v[1].color = color;
    
    NSUInteger tesselationSegments = sprite.tesselationSegments;
    SegmentTesselator tessalator = sprite.tesselator;
    
    float burnout = sprite.burnout;
    float widthMultiplier = sprite.widthMultiplier;
    
    if (startVertex + (tesselationSegments + 1) * VerticesInSegment > VertexLimit) {
        return NO;
    }
    
    for (int seg = 0; seg < tesselationSegments + 1; seg++) {
        
        SegmentTesselation tess = tessalator(burnout/2.0 + ((double)seg/(double)tesselationSegments) * (1.0 - burnout));
        v[0].p = GLKVector2Add(tess.p, GLKVector2MultiplyScalar(tess.n, +_lineSize * widthMultiplier /2.0f));
        v[1].p = GLKVector2Add(tess.p, GLKVector2MultiplyScalar(tess.n, -_lineSize * widthMultiplier/2.0f));
        
        memcpy(vertexData, v, sizeof(v));
        vertexData += VerticesInSegment;
        totalVertices += VerticesInSegment;
    }
    
    for (int seg = 0; seg < tesselationSegments; seg++) {
        
        i[0] = startVertex + 0;
        i[1] = startVertex + 2;
        i[2] = startVertex + 1;
        
        i[3] = startVertex + 1;
        i[4] = startVertex + 2;
        i[5] = startVertex + 3;
        
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
