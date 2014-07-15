//
//  Segment.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVPoint.h"
#import "RVSegmentConnection.h"

#import "SegmentEnd.h"

typedef struct SegmentTesselation {
    GLKVector2 p;
    GLKVector2 n;
} SegmentTesselation;


typedef SegmentTesselation (^SegmentTesselator)(float t);


@class RVEndPoint, RVControlPoint, RVAnchorPoint;

@interface RVSegment : NSObject

@property (nonatomic) NSUInteger colorIndex;

- (RVEndPoint *)endPointAtSegmentEnd:(SegmentEnd)segmentEnd;
- (RVControlPoint *)controlPointAtSegmentEnd:(SegmentEnd)segmentEnd;
- (RVAnchorPoint *)anchorPointAtSegmentEnd:(SegmentEnd)segmentEnd;

- (RVSegmentConnection *)connectionAtSegmentEnd:(SegmentEnd)segmentEnd;
- (void)setConnection:(RVSegmentConnection *)conncetion atSegmentEnd:(SegmentEnd)segmentEnd;

- (NSUInteger)modelTesselationSegments;
- (NSUInteger)lineTesselationSegments;
- (SegmentTesselator)tesselator;


- (void)adjustAnchorPoints;

- (float)hitSquareDistance:(GLKVector2)point;

- (NSArray *)endPoints;
- (NSArray *)controlPoints;
- (NSArray *)anchorPoints;

- (NSSet *)draggablePoints;

- (NSSet *)allPoints;

@end
