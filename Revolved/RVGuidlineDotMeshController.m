//
//  RVGuidlineDotMeshController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 04.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVGuidlineDotMeshController.h"
#import "RVMeshController_Private.h"
#import "BCShader.h"

#import "RVGuidelineDotSprite.h"
#import "PointVertex.h"


static const float UVSize = 0.0625f;
static const GLKVector2 UVs[4] = {
    {0.0f + UVSize, 0.5f + UVSize},
    {0.0f         , 0.5f + UVSize},
    {0.0f + UVSize, 0.5f},
    {0.0f         , 0.5f},
};


static const NSUInteger VertexLimit = 1024;
static const NSUInteger IndexLimit = VertexLimit * 2;

@implementation RVGuidlineDotMeshController

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

- (void)updateBuffersWithGuidelineDotSprites:(NSArray *)dotSprites;
{
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    PointVertex *vertexData = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    GLushort *indexData = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    PointVertex v[4];
    v[0].uv = UVs[0];
    v[1].uv = UVs[1];
    v[2].uv = UVs[2];
    v[3].uv = UVs[3];
    
    GLushort i[6];
    
    GLuint totalIndicies = 0;
    GLuint totalVertices = 0;
    
    for (RVGuidelineDotSprite *dotSprite in dotSprites) {
        
        if (totalVertices + 4 > VertexLimit) {
            break;
        }
        
        float alpha = dotSprite.alpha;
        float size = dotSprite.scale * _dotSize/2.0;
        
        GLKVector2 center = dotSprite.position;
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
