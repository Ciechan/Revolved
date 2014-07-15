//
//  RVOBJExporter.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 16.11.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVOBJExporter.h"
#import "RVModel.h"
#import "RVSegment.h"

#import "Vertex.h"
#import "Constants.h"

@implementation RVOBJExporter


- (void)appendModel:(RVModel *)model toHandle:(NSFileHandle *)handle
{
    NSMutableData *data = [NSMutableData dataWithCapacity:1 << 20];
    
    [data appendData:[@"#Generated in Revolved\no RevolvedModel\ng RevolvedModel\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"mtllib RevolvedMaterials.mtl\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(2.0 * M_PI / (Spans * StripesPerSpan), 0.0, 1.0, 0.0);
    
    static char buffer[2048];
    int len = 0;
    
    for (RVSegment *segment in model.segments) {
        
        NSUInteger tesselationSegments = [segment modelTesselationSegments];
        SegmentTesselator tessalator = segment.tesselator;
        
        for (int seg = 0; seg < tesselationSegments + 1; seg++) {
            
            SegmentTesselation tess = tessalator((double)seg/(double)tesselationSegments);
            
            GLKVector3 a = GLKVector3Make(tess.p.x, tess.p.y, 0.0);
            
            for (int stripe = 0; stripe < Spans * StripesPerSpan; stripe++) {
                
                len = snprintf(buffer, sizeof(buffer), "v %f %f %f\n", a.x, a.y, a.z);
                [data appendBytes:buffer length:len];
                a = GLKMatrix4MultiplyVector3(rotationMatrix, a);
            }
        }
        
    }
    
    [data appendData:[@"\ns 1\n" dataUsingEncoding:NSUTF8StringEncoding]];


    const unsigned int VerticesInSpan = StripesPerSpan * Spans;

    unsigned int vertices = 1; // in OBJ vertices start from 1
    for (RVSegment *segment in model.segments) {
        
        len = snprintf(buffer, sizeof(buffer), "usemtl mat%d\n", (int)segment.colorIndex);
        [data appendBytes:buffer length:len];
        
        
        NSUInteger tesselationSegments = [segment modelTesselationSegments];
        
        for (int seg = 0; seg < tesselationSegments; seg++) {
            for (int stripe = 0; stripe < Spans * StripesPerSpan - 1; stripe++) {
                
                len = snprintf(buffer, sizeof(buffer), "f %u %u %u\n", vertices + 0, vertices + VerticesInSpan, vertices + 1);
                [data appendBytes:buffer length:len];

                len = snprintf(buffer, sizeof(buffer), "f %u %u %u\n", vertices + VerticesInSpan, vertices + VerticesInSpan + 1, vertices + 1);
                [data appendBytes:buffer length:len];
                
                vertices++;
            }
            len = snprintf(buffer, sizeof(buffer), "f %u %u %u\n", vertices + 0, vertices + VerticesInSpan, vertices + 1 - VerticesInSpan);
            [data appendBytes:buffer length:len];

            len = snprintf(buffer, sizeof(buffer), "f %u %u %u\n", vertices + VerticesInSpan, vertices + 1, vertices + 1 - VerticesInSpan);
            [data appendBytes:buffer length:len];

            vertices++;
        }
        
        vertices += VerticesInSpan;
    }
    
    [handle writeData:data];
}


@end
