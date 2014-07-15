//
//  RVSegmentConnection.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 11.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SegmentEnd.h"

@class RVSegment, RVEndPoint;

@interface RVSegmentConnection : NSObject

@property (nonatomic, weak, readonly) RVSegment *a;
@property (nonatomic, readonly) SegmentEnd aEnd;

@property (nonatomic, weak, readonly) RVSegment *b;
@property (nonatomic, readonly) SegmentEnd bEnd;


- (BOOL)hasSegment:(RVSegment *)segment;
- (BOOL)hasEndPoint:(RVEndPoint *)endPoint;

- (RVSegment *)otherSegment:(RVSegment *)segment otherEnd:(SegmentEnd *)otherEnd;

+ (void)connectSegment:(RVSegment *)segment bySegmentEnd:(SegmentEnd)segmentEnd toSegment:(RVSegment *)otherSegment atSegmentEnd:(SegmentEnd)otherSegmentEnd;
+ (void)disconnectSegment:(RVSegment *)segment atSegmentEnd:(SegmentEnd)segmentEnd;

@end
