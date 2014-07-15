//
//  RVModelSprite.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 24.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSprite.h"

@interface RVModelSprite : RVSprite

@property (nonatomic, strong) NSArray *drawnSegments;
@property (nonatomic) GLKVector3 modelScaleVector;
@property (nonatomic) GLKVector3 scaleVector;
@property (nonatomic) GLKVector3 translationVector;
@property (nonatomic) GLKVector3 extraTranslationVector;

@property (nonatomic) float axisAlpha;
@property (nonatomic) BOOL hasScissors;
@property (nonatomic) CGRect scissorsRect;

@property (nonatomic) GLKQuaternion quaternion;

@end
