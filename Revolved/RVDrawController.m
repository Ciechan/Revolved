//
//  DrawController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVDrawController.h"
#import "RVSegment.h"
#import "RVSegmentConnection.h"
#import "RVGuideline.h"
#import "Geometry.h"

#import "RVEndPoint.h"
#import "RVAnchorPoint.h"
#import "RVControlPoint.h"

#import "Constants.h"

@interface RVDrawController()

@property (nonatomic) NSUInteger drawingColorIndex;

@property (nonatomic, strong) RVSegment *drawnSegment;
@property (nonatomic, strong, readwrite) RVSegment *selectedSegment;

@property (nonatomic, strong) RVPoint *draggedPoint;
@property (nonatomic) GLKVector2 draggedPointOffset;
@property (nonatomic, strong) RVGuideline *currentGuideLine;

@end

@implementation RVDrawController


- (void)setSelectedSegment:(RVSegment *)selectedSegment
{
    if (_selectedSegment == selectedSegment) {
        return;
    }
    
    if (selectedSegment) {
        NSUInteger segmentIndex = [self.segments indexOfObject:selectedSegment];
        NSUInteger lastIndex = self.segments.count - 1;
        
        NSAssert(segmentIndex != NSNotFound, @"SelectedSegment not in allSegments");
        NSAssert(self.segments.count > 0, @"allSegments empty");
        
        [self.segments moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:segmentIndex] toIndex:lastIndex];
    }
    _selectedSegment = selectedSegment;
    
    [self.delegate drawControllerDidSelectSegment:selectedSegment];
    [self.delegate drawControllerDidSelectColorIndex:selectedSegment ? selectedSegment.colorIndex : self.drawingColorIndex];
}

- (void)deleteSegment:(RVSegment *)segment
{
    [RVSegmentConnection disconnectSegment:segment atSegmentEnd:SegmentEndFirst];
    [RVSegmentConnection disconnectSegment:segment atSegmentEnd:SegmentEndSecond];
    
    [self.segments removeObject:segment];
    
    if (segment == self.selectedSegment) {
        self.selectedSegment = nil;
        self.state = DrawControllerStateIdle;
    }
    
    [self.delegate drawControllerDidRemoveSegment:segment];
}

- (void)clear
{
    self.segments = nil;
    
    self.state = DrawControllerStateIdle;
    
    self.drawnSegment = nil;
    self.draggedPoint = nil;
    self.selectedSegment = nil;
}

- (RVGuideline *)guideLineForControlPoint:(RVControlPoint *)controlPoint
{
    RVSegment *segment = controlPoint.segment;
    RVSegmentConnection *connection = [segment connectionAtSegmentEnd:controlPoint.segmentEnd];
    
    if (!connection) {
        return nil;
    }
    
    SegmentEnd otherEnd;
    RVSegment *otherSegment = [connection otherSegment:segment otherEnd:&otherEnd];
    RVPoint *otherControlPoint = [otherSegment controlPointAtSegmentEnd:otherEnd];
    RVPoint *otherPoint = [otherSegment endPointAtSegmentEnd:otherEnd];
    
    GLKVector2 start = otherPoint.position;
    GLKVector2 direction = GLKVector2Normalize(GLKVector2Subtract(start, otherControlPoint.position));
    
    float t = INFINITY;
    float newT = -1.0f;
    
    newT = (self.topEdge - start.y)/direction.y;
    if (newT >= 0.0f && newT < t) {
        t = newT;
    }
    
    newT = (self.bottomEdge - start.y)/direction.y;
    if (newT >= 0.0f && newT < t) {
        t = newT;
    }
    
    newT = (-start.x)/direction.x;
    if (newT >= 0.0f && newT < t) {
        t = newT;
    }
    
    newT = (self.rightEdge - start.x)/direction.x;
    if (newT >= 0.0f && newT < t) {
        t = newT;
    }
    
    if (start.x <= 0.0f || start.y >= _rightEdge || start.y <= _bottomEdge || start.y >= _topEdge) {
        t = 0.0f;
    }
    
    
    GLKVector2 scaledDirection = GLKVector2MultiplyScalar(direction, t);
    
    
    RVGuideline *guideline = [RVGuideline new];
    guideline.start = start;
    guideline.end = GLKVector2Add(start, scaledDirection);
    guideline.direction = direction;
    guideline.length = GLKVector2Length(scaledDirection);
    
    return guideline;
}


#pragma mark - Segment connection

- (void)snapSegment:(RVSegment *)segment bySegmentEnd:(SegmentEnd)segmentEnd nearPosition:(GLKVector2)position
{
    position = [self clampedPosition:position];
    
    NSMutableSet *staticSegments = [NSMutableSet setWithSet:self.segments.set];
    [staticSegments removeObject:segment];
    
    RVEndPoint *sourcePoint = [segment endPointAtSegmentEnd:segmentEnd];
    RVEndPoint *snapPoint = [self nearestEndPointForPosition:position amongSegments:staticSegments withDistanceSq:_snapDistanceSquared];
    
    if (snapPoint) {
        RVSegmentConnection *snapPointConnection = [snapPoint.segment connectionAtSegmentEnd:snapPoint.segmentEnd];
        
        if (snapPointConnection) {
            if ([snapPointConnection hasEndPoint:sourcePoint]) {
                [sourcePoint setPosition:snapPoint.position];
            } else {
                [sourcePoint setPosition:position];
            }
        } else {
            [RVSegmentConnection disconnectSegment:segment atSegmentEnd:segmentEnd];
            [RVSegmentConnection connectSegment:segment bySegmentEnd:segmentEnd toSegment:snapPoint.segment atSegmentEnd:snapPoint.segmentEnd];
            [sourcePoint setPosition:snapPoint.position];
        }
    } else {
        [RVSegmentConnection disconnectSegment:segment atSegmentEnd:segmentEnd];
        [sourcePoint setPosition:position];
    }
    
    [segment adjustAnchorPoints];
}


#pragma mark - Event handling

- (void)handlePanBeginAtPosition:(GLKVector2)position firstTouchPosition:(GLKVector2)firstTouchPosition
{
    if (self.state == DrawControllerStateIdle) {
        if (self.segments.count > SegmentLimit) {
            [self.delegate drawControllerDidTryAddButReachedSegmentLimit];
            return;
        }
        
        self.state = DrawControllerStateDrawing;
        
        self.drawnSegment = [[RVSegment alloc] init];
        [self snapSegment:self.drawnSegment bySegmentEnd:SegmentEndFirst nearPosition:firstTouchPosition];
        RVPoint *a = [self.drawnSegment endPointAtSegmentEnd:SegmentEndFirst];
        RVPoint *b = [self.drawnSegment endPointAtSegmentEnd:SegmentEndSecond];
        b.position = a.position;
        self.drawnSegment.colorIndex = self.drawingColorIndex;
        
        [self.segments addObject:self.drawnSegment];
        
        [self.delegate drawControllerDidAddSegment:self.drawnSegment];
        return;
    }
    
    if (self.state == DrawControllerStateSelection) {
        
        RVPoint *bestPoint = [self closestPointInSet:[self.selectedSegment draggablePoints]
                                          toPosition:firstTouchPosition
                                        graceSquared:_tapDistanceSquared];
        
        if (bestPoint) {
            self.draggedPoint = bestPoint;
            self.draggedPointOffset = GLKVector2Subtract(position, bestPoint.position);
            
            self.state = DrawControllerStateDraggingPoint;
            if (bestPoint.type == PointTypeControl) {
                RVGuideline *guideline = [self guideLineForControlPoint:(RVControlPoint *)bestPoint];
                if (guideline) {
                    self.currentGuideLine = guideline;
                    [self.delegate drawControllerDidAddGuideLine:guideline];
                }
            }
            
            [self.delegate drawControllerDidStartDraggingPoint:bestPoint];
        }
        return;
    }
}

- (void)handlePanContinueAtPosition:(GLKVector2)position
{
    if (self.state == DrawControllerStateDrawing) {
        
        [self snapSegment:self.drawnSegment bySegmentEnd:SegmentEndSecond nearPosition:position];
        [self.drawnSegment adjustAnchorPoints];
        
        [self.delegate drawControllerDidModifySegment:self.drawnSegment];
        return;
    }
    
    if (self.state == DrawControllerStateDraggingPoint) {
        
        position = GLKVector2Subtract(position, self.draggedPointOffset);
        
        if (self.draggedPoint.type == PointTypeControl) {
            self.draggedPoint.position = [self snapPositionForControlPoint:(RVControlPoint *)self.draggedPoint nearPosition:position withDistanceSq:_snapDistanceSquared];
        } else if (self.draggedPoint.type == PointTypeEnd) {
            [self snapSegment:self.draggedPoint.segment bySegmentEnd:self.draggedPoint.segmentEnd nearPosition:position];
        }
        
        [self.delegate drawControllerDidDragPoint:self.draggedPoint];
        [self.delegate drawControllerDidModifySegment:self.draggedPoint.segment];
        return;
    }
}

- (void)handlePanEndAtPosition:(GLKVector2)position;
{
    if (self.state == DrawControllerStateDrawing) {
        self.state = DrawControllerStateIdle;
        self.drawnSegment = nil;
        return;
    }
    
    
    if (self.state == DrawControllerStateDraggingPoint) {
        self.state = DrawControllerStateSelection;
        [self.delegate drawControllerDidEndDraggingPoint:self.draggedPoint];
        self.draggedPoint = nil;
        
        if (self.currentGuideLine) {
            [self.delegate drawControllerDidRemoveGuideLine:self.currentGuideLine];
            self.currentGuideLine = nil;
        }
        
        return;
    }
    
}

- (void)handleTapAtPosition:(GLKVector2)position
{
    if (self.state == DrawControllerStateSelection) {
        RVPoint *hitPoint = [self closestPointInSet:[self.selectedSegment draggablePoints]
                                         toPosition:position
                                       graceSquared:_tapDistanceSquared];
        
        if (hitPoint) {
            [self.delegate drawControllerDidSelectEndPoint:hitPoint];
            return;
        }
    }
    
    float bestDist = INFINITY;
    float dist;
    RVSegment *bestSegment = nil;
    for (RVSegment *segment in self.segments) {
        if ((dist = [segment hitSquareDistance:position]) < bestDist) {
            bestDist = dist;
            bestSegment = segment;
        }
    }
    
    
    if (bestDist < _tapDistanceSquared) {
        if (self.state == DrawControllerStateSelection && bestSegment == self.selectedSegment) {
            self.state = DrawControllerStateIdle;
            self.selectedSegment = nil;
        } else {
            self.state = DrawControllerStateSelection;
            self.selectedSegment = bestSegment;
        }
    } else {
        self.state = DrawControllerStateIdle;
        self.selectedSegment = nil;
    }
    
}

- (void)handleColorSelection:(NSUInteger)selectedColorIndex
{
    if (self.state == DrawControllerStateSelection || self.state == DrawControllerStateDraggingPoint) {
        self.selectedSegment.colorIndex = selectedColorIndex;
        [self.delegate drawControllerDidRecolorSegment:self.selectedSegment];
        
    } else if (self.state == DrawControllerStateIdle) {
        self.drawingColorIndex = selectedColorIndex;
    } else if (self.state == DrawControllerStateDrawing) {
        self.drawnSegment.colorIndex = selectedColorIndex;
        self.drawingColorIndex = selectedColorIndex;
        [self.delegate drawControllerDidRecolorSegment:self.drawnSegment];

    }
}


#pragma mark - Helpers

- (GLKVector2)clampedPosition:(GLKVector2)position
{
    position.x = MIN(MAX(0.0, position.x), _rightEdge);
    position.y = MIN(MAX(_bottomEdge, position.y), _topEdge);
    
    GLKVector2 bottomDiff = GLKVector2Subtract(position, _bottomEvadeCenter);
    GLKVector2 topDiff = GLKVector2Subtract(position, _topEvadeCenter);
    
    if (GLKVector2DotProduct(bottomDiff, bottomDiff) <= _evadeSquareRadius) {
        position.y = _bottomEvadeCenter.y + sqrtf(_evadeSquareRadius - bottomDiff.x * bottomDiff.x);
    } else if (GLKVector2DotProduct(topDiff, topDiff) <= _evadeSquareRadius) {
        position.y = _topEvadeCenter.y - sqrtf(_evadeSquareRadius - topDiff.x * topDiff.x);
    }
    
    return position;
}

- (RVPoint *)closestPointInSet:(NSSet *)points toPosition:(GLKVector2)position graceSquared:(float)graceSquared
{
    float bestDist = INFINITY;
    float dist;
    RVPoint *bestPoint = nil;
    
    for (RVPoint *point in points) {
        
        if ((dist = [point hitSquareDistance:position]) < bestDist) {
            bestDist = dist;
            bestPoint = point;
        }
    }
    
    if (bestDist < graceSquared) {
        return bestPoint;
    }
    
    return nil;
}



- (GLKVector2)snapPositionForControlPoint:(RVControlPoint *)controlPoint nearPosition:(GLKVector2)position withDistanceSq:(float)distanceSq
{
    assert([controlPoint isKindOfClass:[RVControlPoint class]]);
    
    RVSegment *segment = controlPoint.segment;
    RVAnchorPoint *anchorPoint = [segment anchorPointAtSegmentEnd:controlPoint.segmentEnd];
    
    if (GLKVector2DistanceSq(position, anchorPoint.position) < _snapDistanceSquared) {
        anchorPoint.hasControlPoint = YES;
        return anchorPoint.position;
    }
    anchorPoint.hasControlPoint = NO;
    
    if (self.currentGuideLine) {
        float t;
        GLKVector2 tangentPoint = ClosestPointOnSegmentForPoint(self.currentGuideLine.start, self.currentGuideLine.end, position, &t);
        
        if (t <= 1.0 && t >= 0.0 && GLKVector2DistanceSq(position, tangentPoint) < _snapDistanceSquared) {
            return [self clampedPosition:tangentPoint];
        }
    }
    
    return [self clampedPosition:position];
}

- (RVEndPoint *)nearestEndPointForPosition:(GLKVector2)position amongSegments:(NSSet *)segments withDistanceSq:(float)distanceSq
{
    NSMutableSet *allEndPoints = [NSMutableSet setWithCapacity:segments.count * 2];
    
    for (RVSegment *segment in segments) {
        for (SegmentEnd end = SegmentEndFirst; end <= SegmentEndSecond; end++) {
            [allEndPoints addObject:[segment endPointAtSegmentEnd:end]];
        }
    }
    
    return (RVEndPoint *)[self closestPointInSet:allEndPoints toPosition:position graceSquared:distanceSq];
}



@end
