//
//  SpaceConverter.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 07.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVSpaceConverter : NSObject

- (id)initWithViewSize:(CGSize)viewSize;

- (GLKVector2)modelPointForViewPoint:(CGPoint)viewPoint;
- (GLKVector2)modelVectorForViewVector:(CGPoint)viewVector;
- (CGPoint)viewPointForModelPoint:(GLKVector2)modelPoint;

- (float)modelSquareDistanceForViewDistance:(CGFloat)viewDistance;

@end
