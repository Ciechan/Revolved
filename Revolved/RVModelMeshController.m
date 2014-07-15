//
//  MeshController.m
//  Patterns
//
//  Created by Bartosz Ciechanowski on 24.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVModelMeshController.h"
#import "RVMeshController_Private.h"
#import "RVColorProvider.h"
#import "BCShader.h"
#import "RVSegment.h"
#import "RVModelSprite.h"

#import "Vertex.h"
#import "Constants.h"

static const NSUInteger VertexLimit = USHRT_MAX;
static const NSUInteger IndexLimit = VertexLimit * 4;

static const float LengthTexScale = 2.0f;
static const float RotTexScale = 2.0f;

@interface RVModelMeshController()
{
    GLKMatrix4 _rotationMatrix;
}

@end

@implementation RVModelMeshController


- (id)init
{
    self = [super init];
    if (self) {
        _rotationMatrix = GLKMatrix4MakeRotation(2.0 * M_PI / (Spans * StripesPerSpan), 0.0, 1.0, 0.0);
    }
    return self;
}

- (void)setupVAO
{
    glGenVertexArraysOES(1, &_VAO);
    glBindVertexArrayOES(_VAO);
    
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, VertexLimit * sizeof(Vertex), NULL, GL_DYNAMIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, IndexLimit * sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(VertexAttribPosition);
    glVertexAttribPointer(VertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, p));
    
    glEnableVertexAttribArray(VertexAttribNormal);
    glVertexAttribPointer(VertexAttribNormal,   3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, n));
    
    glEnableVertexAttribArray(VertexAttribColor);
    glVertexAttribPointer(VertexAttribColor,    3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, color));

    glEnableVertexAttribArray(VertexAttribTexCoord);
    glVertexAttribPointer(VertexAttribTexCoord, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, uv));
    
    glBindVertexArrayOES(0);
}

- (void)updateBuffersWithModelSprites:(NSArray *)modelSprites
{
    _sprites = modelSprites;
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    Vertex *vertexData = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    GLushort *indexData = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    
    GLuint totalIndicies = 0;
    GLuint totalVertices = 0;
    
    BOOL hasOverflownBuffer = NO;
    
    for (RVModelSprite *sprite in modelSprites) {
        NSUInteger verticesCount = 0;
        NSUInteger indiciesCount = 0;
        
        if (!hasOverflownBuffer && ![self tessellateSegments:sprite.drawnSegments vertexData:vertexData indexData:indexData startVertex:totalVertices verticesCount:&verticesCount indiciesCount:&indiciesCount]) {
            hasOverflownBuffer = YES;
        }
        
        sprite.indiciesCount = (GLuint)indiciesCount;
        sprite.indiciesOffset = totalIndicies * sizeof(GLushort);
        
        totalIndicies += indiciesCount;
        totalVertices += verticesCount;
        
        vertexData += verticesCount;
        indexData += indiciesCount;
    }
    
    _indiciesCount = totalIndicies;
    
    
    glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
    glUnmapBufferOES(GL_ARRAY_BUFFER);
}


- (BOOL)tessellateSegments:(NSArray *)segments
                vertexData:(Vertex *)vertexData
                 indexData:(GLushort *)indexData
               startVertex:(NSUInteger)startVertex
             verticesCount:(out NSUInteger *)verticesCount
             indiciesCount:(out NSUInteger *)indiciesCount
{
    const NSUInteger VerticesInRow = StripesPerSpan + 1;
    const NSUInteger IndiciesInRow = StripesPerSpan * 6; // one quad has 2 triangles, each has 3 vertices
    
    Vertex vertexRow[VerticesInRow];
    GLushort indexSpan[IndiciesInRow];
    
    NSUInteger totalIndicies = 0;
    NSUInteger totalVertices = 0;
    
    for (RVSegment *segment in segments) {
        
        GLKVector3 color = [RVColorProvider vectorForColorIndex:segment.colorIndex];
        for (int col = 0; col < VerticesInRow; col++) {
            vertexRow[col].color = color;
        }
        
        NSUInteger tesselationSegments = [segment modelTesselationSegments];
        SegmentTesselator tessalator = segment.tesselator;
        
        if (startVertex + (tesselationSegments + 1) * VerticesInRow > VertexLimit) {
            return NO;
        }
        
        GLKVector2 previousP = tessalator(0.0).p;
        float v = 0.0f;
        for (int seg = 0; seg < tesselationSegments + 1; seg++) {
            
            SegmentTesselation tess = tessalator((double)seg/(double)tesselationSegments);
            vertexRow[0].p = GLKVector3Make(tess.p.x, tess.p.y, 0.0);
            vertexRow[0].n = GLKVector3Make(tess.n.x, tess.n.y, 0.0);
            
            v += LengthTexScale * GLKVector2Distance(tess.p, previousP);
            previousP = tess.p;
            
            vertexRow[0].uv = GLKVector2Make(0.0f, v);
            for (int col = 0; col < StripesPerSpan; col++) {
                vertexRow[col + 1].p = GLKMatrix4MultiplyVector3(_rotationMatrix, vertexRow[col].p);
                vertexRow[col + 1].n = GLKMatrix4MultiplyVector3(_rotationMatrix, vertexRow[col].n);
                vertexRow[col + 1].uv = GLKVector2Make(RotTexScale * (col + 1.0f)/StripesPerSpan, v);
            }
            
            memcpy(vertexData, vertexRow, sizeof(vertexRow));
            vertexData += VerticesInRow;
            totalVertices += VerticesInRow;
        }
        
        for (int seg = 0; seg < tesselationSegments; seg++) {
            
            
            for (int col = 0; col < StripesPerSpan; col++) {
                indexSpan[col * 6 + 0] = startVertex + col + 0;
                indexSpan[col * 6 + 1] = startVertex + col + VerticesInRow;
                indexSpan[col * 6 + 2] = startVertex + col + 1;
                
                indexSpan[col * 6 + 3] = startVertex + col + 1;
                indexSpan[col * 6 + 4] = startVertex + col + VerticesInRow;
                indexSpan[col * 6 + 5] = startVertex + col + VerticesInRow + 1;
            }
            
            memcpy(indexData, indexSpan, sizeof(indexSpan));
            indexData += IndiciesInRow;
            totalIndicies += IndiciesInRow;
            startVertex += VerticesInRow;
        }
        startVertex += VerticesInRow;
    }
    
    *verticesCount = totalVertices;
    *indiciesCount = totalIndicies;

    return YES;
}



@end
