//
//  Segment.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSegment.h"
#import "Geometry.h"

#import "RVEndPoint.h"
#import "RVAnchorPoint.h"
#import "RVControlPoint.h"

@implementation RVSegment
{
    __strong RVEndPoint *_endPoints[2];
    __strong RVControlPoint *_controlPoints[2];
    __strong RVAnchorPoint *_anchorPoints[2];
    __strong RVSegmentConnection *_connections[2];
}

- (id)init
{
    self = [super init];
    if (self) {
        _endPoints[0] = [[RVEndPoint alloc] initWithSegment:self segmentEnd:SegmentEndFirst];
        _endPoints[1] = [[RVEndPoint alloc] initWithSegment:self segmentEnd:SegmentEndSecond];
        
        _controlPoints[0] = [[RVControlPoint alloc] initWithSegment:self segmentEnd:SegmentEndFirst];
        _controlPoints[1] = [[RVControlPoint alloc] initWithSegment:self segmentEnd:SegmentEndSecond];

        _anchorPoints[0] = [[RVAnchorPoint alloc] initWithSegment:self segmentEnd:SegmentEndFirst];
        _anchorPoints[1] = [[RVAnchorPoint alloc] initWithSegment:self segmentEnd:SegmentEndSecond];
        
        _anchorPoints[0].hasControlPoint = YES;
        _anchorPoints[1].hasControlPoint = YES;
        
        [self adjustAnchorPoints];
    }
    return self;
}

#pragma mark - Getters n Setters

- (RVEndPoint *)endPointAtSegmentEnd:(SegmentEnd)segmentEnd
{
    return _endPoints[segmentEnd];
}

- (RVControlPoint *)controlPointAtSegmentEnd:(SegmentEnd)segmentEnd
{
    return _controlPoints[segmentEnd];
}

- (RVAnchorPoint *)anchorPointAtSegmentEnd:(SegmentEnd)segmentEnd
{
    return _anchorPoints[segmentEnd];
}

- (RVSegmentConnection *)connectionAtSegmentEnd:(SegmentEnd)segmentEnd
{
    return _connections[segmentEnd];
}

- (void)setConnection:(RVSegmentConnection *)conncetion atSegmentEnd:(SegmentEnd)segmentEnd
{
    _connections[segmentEnd] = conncetion;
}


#pragma mark - Tesselation

- (float)approxLength
{
    GLKVector2 a = _endPoints[0].position;
    GLKVector2 b = _endPoints[1].position;
    GLKVector2 p1 = _controlPoints[0].position;
    GLKVector2 p2 = _controlPoints[1].position;
    
    static const float EpsSq = 0.0001f;
    
    if (SquareDistancePointSegment(a, b, p1) < EpsSq && SquareDistancePointSegment(a, b, p2) < EpsSq) {
        return 0;
    }
    
    float length = (GLKVector2Length(GLKVector2Subtract(a, p1)) +
                    GLKVector2Length(GLKVector2Subtract(p1, p2)) +
                    GLKVector2Length(GLKVector2Subtract(p2, b)));

    return length;
}

- (NSUInteger)modelTesselationSegments
{
    float segments = [self approxLength]/0.18f;
    
    return segments == 0.0f ? 1 : ceilf(sqrt(segments * segments * 0.5 + 64.0));
}

- (NSUInteger)lineTesselationSegments;
{
    float segments = [self approxLength]/0.05f;
    
    return segments == 0.0f ? 1 : ceilf(sqrt(segments * segments * 0.6 + 225.0));
}



- (SegmentTesselator)tesselator
{
    GLKVector2 a = _endPoints[0].position;
    GLKVector2 b = _endPoints[1].position;
    GLKVector2 p1 = _controlPoints[0].position;
    GLKVector2 p2 = _controlPoints[1].position;
    
    return ^(float t){
        float nt = 1.0f - t;
        
        SegmentTesselation tess;
        tess.p = GLKVector2Make(a.x * nt * nt * nt  +  3.0 * p1.x * nt * nt * t  +  3.0 * p2.x * nt * t * t  +  b.x * t * t * t,
                                a.y * nt * nt * nt  +  3.0 * p1.y * nt * nt * t  +  3.0 * p2.y * nt * t * t  +  b.y * t * t * t);
        
        tess.n = GLKVector2Make(-3.0 * a.x * nt * nt  +  3.0 * p1.x * (1.0 - 4.0 * t + 3.0 * t * t)  +  3.0 * p2.x * (2.0 * t - 3.0 * t * t) + 3.0 * b.x * t * t,
                                -3.0 * a.y * nt * nt  +  3.0 * p1.y * (1.0 - 4.0 * t + 3.0 * t * t)  +  3.0 * p2.y * (2.0 * t - 3.0 * t * t) + 3.0 * b.y * t * t);
        
        tess.n = GLKVector2Normalize(GLKVector2Make(-tess.n.y, tess.n.x));
        
        
        return tess;
    };
}



- (NSArray *)endPoints
{
    return @[_endPoints[0], _endPoints[1]];
}

- (NSArray *)controlPoints
{
    return @[_controlPoints[0], _controlPoints[1]];
}

- (NSArray *)anchorPoints
{
    return @[_anchorPoints[0], _anchorPoints[1]];
}



- (NSSet *)draggablePoints
{
    return [NSSet setWithObjects:_endPoints[0], _controlPoints[0], _controlPoints[1], _endPoints[1], nil];
}

- (NSSet *)allPoints
{
    return [NSSet setWithObjects:_endPoints[0], _controlPoints[0], _controlPoints[1], _endPoints[1], _anchorPoints[0], _anchorPoints[1], nil];
}

- (float)hitSquareDistance:(GLKVector2)point
{
    float best = INFINITY;
    const NSUInteger tesselationSegments = 6;
    SegmentTesselator tessalator = self.tesselator;
    SegmentTesselation a = tessalator(0.0);
    
    for (int seg = 1; seg < tesselationSegments + 1; seg++) {
        
        SegmentTesselation b = tessalator((double)seg/(double)tesselationSegments);
        float dist = SquareDistancePointSegment(a.p, b.p, point);
        if (dist <= best) {
            best = dist;
        }
        a = b;
    }
    
    return best;
}

- (void)adjustAnchorPoints
{
    GLKVector2 diff = GLKVector2Subtract(_endPoints[1].position, _endPoints[0].position);
    
    _anchorPoints[0].position = GLKVector2Add(_endPoints[0].position, GLKVector2MultiplyScalar(diff, 1.0/3.0));
    _anchorPoints[1].position = GLKVector2Add(_endPoints[0].position, GLKVector2MultiplyScalar(diff, 2.0/3.0));
    
    if ([_anchorPoints[0] hasControlPoint]) {
        _controlPoints[0].position = _anchorPoints[0].position;
    }

    if ([_anchorPoints[1] hasControlPoint]) {
        _controlPoints[1].position = _anchorPoints[1].position;
    }
}


@end
