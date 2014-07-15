//
//  RVConnectionTests.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GLKit/GLKit.h>


#import "RVSegment.h"
#import "RVEndPoint.h"
#import "RVAnchorPoint.h"
#import "RVControlPoint.h"

@interface RVConnectionTests : XCTestCase

@end

@implementation RVConnectionTests


- (void)testExample
{
    RVSegment *segment1 = [[RVSegment alloc] init];
    [[segment1 endPointAtSegmentEnd:SegmentEndFirst] setPosition:GLKVector2Make(2.34, 3.0)];
    [[segment1 endPointAtSegmentEnd:SegmentEndSecond] setPosition:GLKVector2Make(4.0, 20.0)];
    
    
    RVSegment *segment2 = [[RVSegment alloc] init];
    [[segment2 endPointAtSegmentEnd:SegmentEndFirst] setPosition:GLKVector2Make(2.34, 3.0)];
    [[segment2 endPointAtSegmentEnd:SegmentEndSecond] setPosition:GLKVector2Make(4.0, 20.0)];
    
    [RVSegmentConnection connectSegment:segment1 bySegmentEnd:SegmentEndFirst toSegment:segment2 atSegmentEnd:SegmentEndSecond];
    
    XCTAssertNil([segment2 connectionAtSegmentEnd:SegmentEndFirst], @"");
    XCTAssertNil([segment1 connectionAtSegmentEnd:SegmentEndSecond], @"");
    XCTAssertNotNil([segment1 connectionAtSegmentEnd:SegmentEndFirst], @"");
    XCTAssertNotNil([segment2 connectionAtSegmentEnd:SegmentEndSecond], @"");
    
    
    RVSegmentConnection *connection = [segment1 connectionAtSegmentEnd:SegmentEndFirst];
    
    XCTAssertEqual(connection.aEnd, SegmentEndFirst, @"");
    XCTAssertEqual(connection.bEnd, SegmentEndSecond, @"");
    
    
    XCTAssertEqualObjects(connection.a, segment1, @"");
    XCTAssertEqualObjects(connection.b, segment2, @"");
}

    

@end
