//
//  RVPoint.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SegmentEnd.h"

@class RVSegment;

typedef NS_ENUM(NSInteger, PointType) {
    PointTypeEnd = 1,
    PointTypeControl,
    PointTypeAnchor
};



@interface RVPoint : NSObject

@property (nonatomic, readonly, weak) RVSegment *segment;
@property (nonatomic, readonly) SegmentEnd segmentEnd;
@property (nonatomic, readonly) PointType type;

@property (nonatomic) GLKVector2 position;

- (id)initWithSegment:(RVSegment *)segment segmentEnd:(SegmentEnd)segmentEnd;

- (float)hitSquareDistance:(GLKVector2)point;


@end

