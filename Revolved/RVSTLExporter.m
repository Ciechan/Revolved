//
//  RVSTLExporter.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.11.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSTLExporter.h"
#import "RVModel.h"
#import "RVSegment.h"

#import "Vertex.h"
#import "Constants.h"

@implementation RVSTLExporter

typedef struct FaceStruct {
    GLKVector3 normal;
    GLKVector3 v1;
    GLKVector3 v2;
    GLKVector3 v3;
    u_int16_t attrib;
} FaceStruct;

static const size_t FaceStructSize = 50;


static inline void printVertexCoords(GLKVector3 v, NSFileHandle *handle)
{
    [handle writeData:[NSData dataWithBytesNoCopy:&v length:sizeof(v) freeWhenDone:NO]];
}

static inline void fillFace(FaceStruct *face, GLKVector3 v1, GLKVector3 v2, GLKVector3 v3)
{
    face->normal = GLKVector3CrossProduct(GLKVector3Subtract(v1, v2), GLKVector3Subtract(v3, v2));
    face->v1 = v1;
    face->v2 = v2;
    face->v3 = v3;
}


- (void)appendModel:(RVModel *)model toHandle:(NSFileHandle *)handle
{
    u_int32_t totalTesselationSegments = 0;
    
    for (RVSegment *segment in model.segments) {
        totalTesselationSegments += [segment modelTesselationSegments];
    }
    
    u_int32_t totalTriangles = totalTesselationSegments * Spans * StripesPerSpan * 2;
    u_int8_t header[80] = "Model from Revolved";
    [handle writeData:[NSData dataWithBytesNoCopy:header length:sizeof(header) freeWhenDone:NO]];
    [handle writeData:[NSData dataWithBytesNoCopy:&totalTriangles length:sizeof(totalTriangles) freeWhenDone:NO]];
    
    
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(2.0 * M_PI / (Spans * StripesPerSpan), 0.0, 0.0, 1.0);
    
    u_int8_t bandFaces[2 * Spans * StripesPerSpan * FaceStructSize];
    
    FaceStruct face = {0};
    
    for (RVSegment *segment in model.segments) {
        
        NSUInteger tesselationSegments = [segment modelTesselationSegments];
        SegmentTesselator tessalator = segment.tesselator;
        SegmentTesselation previousTess = tessalator(0.0);
        
        for (int seg = 1; seg < tesselationSegments + 1; seg++) {
            
            SegmentTesselation tess = tessalator((double)seg/(double)tesselationSegments);
            
            GLKVector3 a = GLKVector3Make(0.0, previousTess.p.x, previousTess.p.y);
            GLKVector3 b = GLKVector3Make(0.0, tess.p.x, tess.p.y);
            GLKVector3 c = GLKMatrix4MultiplyVector3(rotationMatrix, b);
            GLKVector3 d = GLKMatrix4MultiplyVector3(rotationMatrix, a);
            
            for (int stripe = 0; stripe < Spans * StripesPerSpan; stripe++) {
                
                face.normal = GLKVector3CrossProduct(GLKVector3Subtract(a, b), GLKVector3Subtract(d, b));
                face.v1 = a;
                face.v2 = b;
                face.v3 = d;
                
                memcpy(&bandFaces[(2 * stripe + 0)*FaceStructSize], &face, FaceStructSize);
               
                face.normal = GLKVector3CrossProduct(GLKVector3Subtract(d, b), GLKVector3Subtract(c, b));
                face.v1 = d;
                face.v2 = b;
                face.v3 = c;
                
                memcpy(&bandFaces[(2 * stripe + 1)*FaceStructSize], &face, FaceStructSize);
                
                b = c;
                a = d;
                
                if (stripe + 1 == Spans * StripesPerSpan) {
                    c = GLKVector3Make(0.0, tess.p.x, tess.p.y);
                    d = GLKVector3Make(0.0, previousTess.p.x, previousTess.p.y);
                } else {
                    c = GLKMatrix4MultiplyVector3(rotationMatrix, c);
                    d = GLKMatrix4MultiplyVector3(rotationMatrix, d);
                }
            }
            
            [handle writeData:[NSData dataWithBytesNoCopy:&bandFaces length:sizeof(bandFaces) freeWhenDone:NO]];

            previousTess = tess;
        }
    }
}

@end
