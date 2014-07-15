//
//  RVPointSprite.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 19.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSprite.h"
#import "RVPoint.h"

@interface RVPointSprite : RVSprite

@property (nonatomic) PointType type;
@property (nonatomic) SegmentEnd segmentEnd;
@property (nonatomic) GLKVector2 position;
@property (nonatomic) GLKVector3 extraTranslationVector;

@property (nonatomic) float alpha;
@property (nonatomic) float scale;

@end
