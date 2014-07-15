//
//  RVPointMeshController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVPointMeshController.h"
#import "RVMeshController_Private.h"
#import "BCShader.h"

#import "RVPointSprite.h"
#import "PointVertex.h"

static const NSUInteger VertexLimit = 480;
static const NSUInteger IndexLimit = VertexLimit * 2;


static GLKVector2 PointTexTypeOffset[] = {
    [PointTypeEnd]     = {0.0, 0.0},
    [PointTypeControl] = {0.5, 0.0},
    [PointTypeAnchor]  = {0.5, 0.5},
};

static GLKVector2 PointTexEndPos[2][4] = {
    [SegmentEndFirst][0] = {0.5, 0.5},
    [SegmentEndFirst][1] = {0.0, 0.5},
    [SegmentEndFirst][2] = {0.5, 0.0},
    [SegmentEndFirst][3] = {0.0, 0.0},
    
    [SegmentEndSecond][0] = {0.5, 0.0},
    [SegmentEndSecond][1] = {0.5, 0.5},
    [SegmentEndSecond][2] = {0.0, 0.0},
    [SegmentEndSecond][3] = {0.0, 0.5},
};

@implementation RVPointMeshController


- (void)setupVAO
{
    glGenVertexArraysOES(1, &_VAO);
    glBindVertexArrayOES(_VAO);
    
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, VertexLimit * sizeof(PointVertex), NULL, GL_DYNAMIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, IndexLimit * sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(VertexAttribPosition);
    glVertexAttribPointer(VertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(PointVertex), (void *)offsetof(PointVertex, p));
    
    glEnableVertexAttribArray(VertexAttribTexCoord);
    glVertexAttribPointer(VertexAttribTexCoord, 2, GL_FLOAT, GL_FALSE, sizeof(PointVertex), (void *)offsetof(PointVertex, uv));
    
    glEnableVertexAttribArray(VertexAttribAlpha);
    glVertexAttribPointer(VertexAttribAlpha,    1, GL_FLOAT, GL_FALSE, sizeof(PointVertex), (void *)offsetof(PointVertex, alpha));
    
    glBindVertexArrayOES(0);
}


- (void)updateBuffersWithPointSprites:(NSArray *)pointSprites
{
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    PointVertex *vertexData = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    GLushort *indexData = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    PointVertex v[4];
    GLushort i[6];

    GLuint totalIndicies = 0;
    GLuint totalVertices = 0;
    
    for (RVPointSprite *pointSprite in pointSprites) {
        
        if (totalVertices + 4 > VertexLimit) {
            break;
        }
        
        GLKVector2 offset = PointTexTypeOffset[pointSprite.type];
        NSInteger end = pointSprite.segmentEnd;
        float alpha = pointSprite.alpha;
        float size = pointSprite.scale * _pointSize/2.0;
        GLKVector2 center = pointSprite.position;
        GLKVector3 translation = pointSprite.extraTranslationVector;
        center.x += translation.x;
        center.y += translation.y;
        
        v[0].uv = GLKVector2Add(offset, PointTexEndPos[end][0]);
        v[1].uv = GLKVector2Add(offset, PointTexEndPos[end][1]);
        v[2].uv = GLKVector2Add(offset, PointTexEndPos[end][2]);
        v[3].uv = GLKVector2Add(offset, PointTexEndPos[end][3]);
        
        v[0].p = GLKVector2Make(center.x + size, center.y + size);
        v[1].p = GLKVector2Make(center.x - size, center.y + size);
        v[2].p = GLKVector2Make(center.x + size, center.y - size);
        v[3].p = GLKVector2Make(center.x - size, center.y - size);
        
        v[0].alpha = alpha;
        v[1].alpha = alpha;
        v[2].alpha = alpha;
        v[3].alpha = alpha;
        
        memcpy(vertexData, v, sizeof(v));
        vertexData += sizeof(v)/sizeof(v[0]);
        
        i[0] = totalVertices + 0;
        i[1] = totalVertices + 2;
        i[2] = totalVertices + 1;
        
        i[3] = totalVertices + 1;
        i[4] = totalVertices + 2;
        i[5] = totalVertices + 3;
        
        memcpy(indexData, i, sizeof(i));
        indexData += sizeof(i)/sizeof(i[0]);
        
        totalIndicies += 6;
        totalVertices += 4;
    }
    
    _indiciesCount = totalIndicies;
    
    glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
    glUnmapBufferOES(GL_ARRAY_BUFFER);
}



@end
