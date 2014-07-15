//
//  RVModelSerializer.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVModelSerializer.h"
#import "RVSegment.h"

#import "RVEndPoint.h"
#import "RVAnchorPoint.h"
#import "RVControlPoint.h"

#import "NSError+RevolvedErrors.h"

NSString * const SegmentsKey = @"segments";
NSString * const ConnectionsKey = @"connections";

NSString * const ColorKey = @"colorIndex";
NSString * const EndPointsKey = @"endPoints";
NSString * const ControlPointsKey = @"controlPoints";

NSString * const PointXCoordinateKey = @"x";
NSString * const PointYCoordinateKey = @"y";
NSString * const PointIsSnappedKey = @"snapped";

NSString * const ConnectionFromKey = @"from";
NSString * const ConnectionToKey = @"to";

NSString * const ConnectionSegmentIndex = @"index";
NSString * const ConnectionSegmentEnd = @"end";

@implementation RVModelSerializer

+ (NSSet *)segmentsFromJSONModelDictionary:(NSDictionary *)dictionary error:(NSError **)error
{

    NSMutableOrderedSet *segments = [NSMutableOrderedSet orderedSet];

    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        goto error;
    }
    
    __unsafe_unretained NSArray *jsonSegments = dictionary[SegmentsKey];
    if (![jsonSegments isKindOfClass:[NSArray class]]) {
        goto error;
    }

    
    for (NSDictionary *segmentDict in jsonSegments) {
        if (![segmentDict isKindOfClass:[NSDictionary class]]) {
            goto error;
        }
        
        RVSegment *segment = [[RVSegment alloc] init];
        segment.colorIndex = [segmentDict[ColorKey] unsignedIntegerValue];
        
        // end points
        
        NSArray *endPoints = segmentDict[EndPointsKey];
        if (![endPoints isKindOfClass:[NSArray class]]) {
            goto error;
        }
        if (endPoints.count < 2) {
            goto error;
        }
        
        if (![self deserializeEndPointDictionary:endPoints[0] toEndPoint:segment.endPoints[0]]) {
            goto error;
        }
        if (![self deserializeEndPointDictionary:endPoints[1] toEndPoint:segment.endPoints[1]]) {
            goto error;
        }
        
        // control points

        
        NSArray *controlPoints = segmentDict[ControlPointsKey];
        if (![controlPoints isKindOfClass:[NSArray class]]) {
            goto error;
        }
        if (controlPoints.count < 2) {
            goto error;
        }
        
        if (![self deserializeControlPointDictionary:controlPoints[0] toControlPoint:segment.controlPoints[0] anchorPoint:segment.anchorPoints[0]]) {
            goto error;
        }
        if (![self deserializeControlPointDictionary:controlPoints[1] toControlPoint:segment.controlPoints[1] anchorPoint:segment.anchorPoints[1]]) {
            goto error;
        }
        
        [segment adjustAnchorPoints];
        [segments addObject:segment];
    }
    
    __unsafe_unretained NSArray *jsonConnections = dictionary[ConnectionsKey];
    if (![jsonConnections isKindOfClass:[NSArray class]]) {
        goto error;
    }
    
    for (NSDictionary *connectionDict in jsonConnections) {
        if (![connectionDict isKindOfClass:[NSDictionary class]]) {
            goto error;
        }
        
        
        NSDictionary *from = connectionDict[ConnectionFromKey];
        if (![from isKindOfClass:[NSDictionary class]]) {
            goto error;
        }
        
        NSUInteger aIndex = [from[ConnectionSegmentIndex] unsignedIntegerValue];
        SegmentEnd aEnd = [from[ConnectionSegmentEnd] integerValue];
        
        
        NSDictionary *to = connectionDict[ConnectionToKey];
        if (![to isKindOfClass:[NSDictionary class]]) {
            goto error;
        }
        
        NSUInteger bIndex = [to[ConnectionSegmentIndex] unsignedIntegerValue];
        SegmentEnd bEnd = [to[ConnectionSegmentEnd] integerValue];
        
        if (aIndex >= segments.count || bIndex >= segments.count) {
            goto error;
        }
        
        RVSegment *aSegment = segments[aIndex];
        RVSegment *bSegment = segments[bIndex];
        
        [RVSegmentConnection connectSegment:aSegment bySegmentEnd:aEnd toSegment:bSegment atSegmentEnd:bEnd];
    }
    
    if (error) {
        *error = nil;
    }
    return segments.set;
    
error:
    
    if (error) {
        *error = [NSError malformedFileError];
    }
    return nil;
}



+ (NSDictionary *)JSONModelDictionaryFromSegments:(NSSet *)segments
{
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithSet:segments];
    NSMutableSet *connections = [NSMutableSet set];
    
    NSMutableArray *jsonSegments = [NSMutableArray array];
    for (RVSegment *segment in orderedSet) {
        NSMutableDictionary *segmentDict = [NSMutableDictionary dictionary];
        segmentDict[ColorKey] = @(segment.colorIndex);
        
        segmentDict[EndPointsKey] = @[[self serializeEndPoint:segment.endPoints[0]],
                                      [self serializeEndPoint:segment.endPoints[1]]];
        
        segmentDict[ControlPointsKey] = @[[self serializeControlPoint:segment.controlPoints[0] isSnapped:[segment.anchorPoints[0] hasControlPoint]],
                                          [self serializeControlPoint:segment.controlPoints[1] isSnapped:[segment.anchorPoints[1] hasControlPoint]]];
        
        if ([segment connectionAtSegmentEnd:SegmentEndFirst]) {
            [connections addObject:[segment connectionAtSegmentEnd:SegmentEndFirst]];
        }
        if ([segment connectionAtSegmentEnd:SegmentEndSecond]) {
            [connections addObject:[segment connectionAtSegmentEnd:SegmentEndSecond]];
        }
        
        [jsonSegments addObject:segmentDict];
    }
    
    NSMutableArray *jsonConnections = [NSMutableArray array];
    for (RVSegmentConnection *connection in connections) {
        NSDictionary *connectionDict = [self serializeConnection:connection withOrderedSegments:orderedSet];
        [jsonConnections addObject:connectionDict];
    }
    
    return @{SegmentsKey   : jsonSegments,
             ConnectionsKey : jsonConnections};
}

+ (NSDictionary *)serializeEndPoint:(RVEndPoint *)endPoint
{
    return @{PointXCoordinateKey : @(endPoint.position.x),
             PointYCoordinateKey : @(endPoint.position.y)};
}

+ (BOOL)deserializeEndPointDictionary:(NSDictionary *)endPointDict toEndPoint:(RVEndPoint *)endPoint
{
    if (![endPointDict isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    endPoint.position = GLKVector2Make([endPointDict[PointXCoordinateKey] floatValue],
                                       [endPointDict[PointYCoordinateKey] floatValue]);
    return YES;
}



+ (NSDictionary *)serializeControlPoint:(RVControlPoint *)controlPoint isSnapped:(BOOL)snapped;
{
    return @{PointXCoordinateKey : @(controlPoint.position.x),
             PointYCoordinateKey : @(controlPoint.position.y),
             PointIsSnappedKey   : @(snapped)};
}

+ (BOOL)deserializeControlPointDictionary:(NSDictionary *)controlPointDict toControlPoint:(RVControlPoint *)controlPoint anchorPoint:(RVAnchorPoint *)anchorPoint
{
    if (![controlPointDict isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    controlPoint.position = GLKVector2Make([controlPointDict[PointXCoordinateKey] floatValue],
                                           [controlPointDict[PointYCoordinateKey] floatValue]);
    anchorPoint.hasControlPoint = [controlPointDict[PointIsSnappedKey] boolValue];
    
    return YES;
}



+ (NSDictionary *)serializeConnection:(RVSegmentConnection *)connection withOrderedSegments:(NSOrderedSet *)segments
{
    NSAssert(connection, nil);
    NSAssert(connection.a, nil);
    NSAssert(connection.b, nil);
    
    return @{ConnectionFromKey : @{ConnectionSegmentIndex : @([segments indexOfObject:connection.a]),
                                   ConnectionSegmentEnd   : @(connection.aEnd)},
             ConnectionToKey   : @{ConnectionSegmentIndex : @([segments indexOfObject:connection.b]),
                                   ConnectionSegmentEnd   : @(connection.bEnd)},
             };
}

@end
