//
//  RVPoint.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVPoint.h"
#import "Geometry.h"

@implementation RVPoint

- (id)initWithSegment:(RVSegment *)segment segmentEnd:(SegmentEnd)segmentEnd;
{
    self = [super init];
    if (self) {
        _segment = segment;
        _segmentEnd = segmentEnd;
    }
    return self;
}

- (PointType)type
{
    assert(NO);
    return PointTypeEnd;
}

- (float)hitSquareDistance:(GLKVector2)point
{
    return GLKVector2DistanceSq(_position, point);
}

@end
