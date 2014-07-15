//
//  RVLineSprite.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 19.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSprite.h"
#import "RVSegment.h"

@interface RVLineSprite : RVSprite

@property (nonatomic) GLKVector3 color;
@property (nonatomic) float burnout;
@property (nonatomic) float widthMultiplier;

@property (nonatomic, strong) SegmentTesselator tesselator;
@property (nonatomic) NSUInteger tesselationSegments;

@end
