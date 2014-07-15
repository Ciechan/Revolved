//
//  RVSegmentConnection.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 11.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSegmentConnection.h"
#import "RVSegment.h"
#import "RVEndPoint.h"

@implementation RVSegmentConnection

- (id)init
{
    assert(NO);
}

+ (instancetype)conncetionWithSegment:(RVSegment *)segment segmentEnd:(SegmentEnd)segmentEnd otherSegment:(RVSegment *)otherSegment otherSegmentEnd:(SegmentEnd)otherSegmentEnd
{
    return [[self alloc] initWithSegment:segment segmentEnd:segmentEnd otherSegment:otherSegment otherSegmentEnd:otherSegmentEnd];
}

- (instancetype)initWithSegment:(RVSegment *)segment segmentEnd:(SegmentEnd)segmentEnd otherSegment:(RVSegment *)otherSegment otherSegmentEnd:(SegmentEnd)otherSegmentEnd
{
    self = [super init];
    if (self) {
        _a = segment;
        _aEnd = segmentEnd;
        
        _b = otherSegment;
        _bEnd = otherSegmentEnd;
    }
    return self;
}

- (BOOL)hasSegment:(RVSegment *)segment
{
    return segment == _a || segment == _b;
}

- (BOOL)hasEndPoint:(RVEndPoint *)endPoint
{
    return [_a endPointAtSegmentEnd:_aEnd] == endPoint || [_b endPointAtSegmentEnd:_bEnd] == endPoint;
}

- (RVSegment *)otherSegment:(RVSegment *)segment otherEnd:(SegmentEnd *)otherEnd
{
    assert([self hasSegment:segment]);
    
    if (otherEnd) {
        *otherEnd = segment == _a ? _bEnd : _aEnd;
    }
    
    return segment == _a ? _b : _a;
}


+ (void)connectSegment:(RVSegment *)segment bySegmentEnd:(SegmentEnd)segmentEnd toSegment:(RVSegment *)otherSegment atSegmentEnd:(SegmentEnd)otherSegmentEnd
{
    NSAssert(segment != otherSegment, @"");
    
    RVSegmentConnection *connection = [RVSegmentConnection conncetionWithSegment:segment segmentEnd:segmentEnd otherSegment:otherSegment otherSegmentEnd:otherSegmentEnd];
    
    [segment setConnection:connection atSegmentEnd:segmentEnd];
    [otherSegment setConnection:connection atSegmentEnd:otherSegmentEnd];
}

+ (void)disconnectSegment:(RVSegment *)segment atSegmentEnd:(SegmentEnd)segmentEnd
{
    RVSegmentConnection *connection = [segment connectionAtSegmentEnd:segmentEnd];
    
    if (!connection) {
        return;
    }
    
    [connection.a setConnection:nil atSegmentEnd:connection.aEnd];
    [connection.b setConnection:nil atSegmentEnd:connection.bEnd];
}

@end
