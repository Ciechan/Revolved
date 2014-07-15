//
//  RVSerializerTests.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GLKit/GLKit.h>

#import "RVModelSerializer.h"

#import "RVSegment.h"
#import "RVEndPoint.h"
#import "RVAnchorPoint.h"
#import "RVControlPoint.h"

@interface RVSerializerTests : XCTestCase

@end

@implementation RVSerializerTests


- (void)testSimpleSerialization
{
    RVSegment *segment = [[RVSegment alloc] init];
    [[segment endPointAtSegmentEnd:SegmentEndFirst] setPosition:GLKVector2Make(2.34, 3.0)];
    [[segment endPointAtSegmentEnd:SegmentEndSecond] setPosition:GLKVector2Make(4.0, 20.0)];
    
    [[segment controlPointAtSegmentEnd:SegmentEndFirst] setPosition:GLKVector2Make(5.0, -7.0)];
    [[segment controlPointAtSegmentEnd:SegmentEndSecond] setPosition:GLKVector2Make(1.54, M_PI)];
    
    [[segment anchorPointAtSegmentEnd:SegmentEndFirst] setHasControlPoint:YES];
    [[segment anchorPointAtSegmentEnd:SegmentEndSecond] setHasControlPoint:NO];
    
    NSError *error;
    NSDictionary *dict = [RVModelSerializer JSONModelDictionaryFromSegments:[NSSet setWithObject:segment]];
    NSSet *segments = [RVModelSerializer segmentsFromJSONModelDictionary:dict error:&error];
    
    XCTAssertTrue(error == nil, @"");
    XCTAssertTrue(segments.count == 1, @"");
    
    RVSegment *parsedSeg = [segments anyObject];

    
    XCTAssertEqual([[parsedSeg anchorPointAtSegmentEnd:SegmentEndFirst] hasControlPoint],
                   [[segment anchorPointAtSegmentEnd:SegmentEndFirst] hasControlPoint],
                   @"");
    
    XCTAssertEqual([[parsedSeg anchorPointAtSegmentEnd:SegmentEndSecond] hasControlPoint],
                   [[segment anchorPointAtSegmentEnd:SegmentEndSecond] hasControlPoint],
                   @"");
}

- (void)testWrongInputSerialization
{
    NSError *error;
    NSSet *segments;
    
    segments = [RVModelSerializer segmentsFromJSONModelDictionary:nil error:&error];
    XCTAssertNil(segments, @"");

    segments = [RVModelSerializer segmentsFromJSONModelDictionary:@{} error:&error];
    XCTAssertNil(segments, @"");

    segments = [RVModelSerializer segmentsFromJSONModelDictionary:@{@"segments" : @{}, @"connections" : @[]} error:&error];
    XCTAssertNil(segments, @"");

    segments = [RVModelSerializer segmentsFromJSONModelDictionary:@{@"segments" : @[], @"connections" : @{}} error:&error];
    XCTAssertNil(segments, @"");
}


- (void)testConnectionSerialization
{
    RVSegment *segment1 = [[RVSegment alloc] init];
    [[segment1 endPointAtSegmentEnd:SegmentEndFirst] setPosition:GLKVector2Make(2.34, 3.0)];
    [[segment1 endPointAtSegmentEnd:SegmentEndSecond] setPosition:GLKVector2Make(4.0, 20.0)];
    
    
    RVSegment *segment2 = [[RVSegment alloc] init];
    [[segment2 endPointAtSegmentEnd:SegmentEndFirst] setPosition:GLKVector2Make(2.34, 3.0)];
    [[segment2 endPointAtSegmentEnd:SegmentEndSecond] setPosition:GLKVector2Make(4.0, 20.0)];
    
    [RVSegmentConnection connectSegment:segment1 bySegmentEnd:SegmentEndFirst toSegment:segment2 atSegmentEnd:SegmentEndSecond];
    
    NSError *error;
    NSDictionary *dict = [RVModelSerializer JSONModelDictionaryFromSegments:[NSSet setWithObjects:segment1, segment2, nil]];
    NSSet *segments = [RVModelSerializer segmentsFromJSONModelDictionary:dict error:&error];
    
    XCTAssertTrue(error == nil, @"");
    XCTAssertTrue(segments.count == 2, @"");
    
    RVSegment *parsedSeg = [segments anyObject];
    RVSegmentConnection *connection = [parsedSeg connectionAtSegmentEnd:SegmentEndFirst] ?: [parsedSeg connectionAtSegmentEnd:SegmentEndSecond];
    

    XCTAssertEqual([connection aEnd],
                   SegmentEndFirst,
                   @"");

    XCTAssertEqual([connection bEnd],
                   SegmentEndSecond,
                   @"");
    
    
    XCTAssertNotNil([connection a], @"");
    XCTAssertNotNil([connection b], @"");
    XCTAssertNotEqualObjects(connection.a, connection.b, @"");
}

@end
