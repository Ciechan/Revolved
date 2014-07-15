//
//  SpaceConverter.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 07.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSpaceConverter.h"
#import "Geometry.h"

static const float Scale = 2.0;

static const float AxisLocation = 30.0f;

@implementation RVSpaceConverter
{
    CGSize _viewSize;
}

- (id)initWithViewSize:(CGSize)viewSize
{
    self = [super init];
    if (self) {
        _viewSize = viewSize;
    }
    return self;
}

- (GLKVector2)modelPointForViewPoint:(CGPoint)viewPoint
{
    GLKVector2 point = GLKVector2Make(viewPoint.x, viewPoint.y);
    point.y -= _viewSize.height/2.0;
    point.y *= -1.0;
    point.x -= AxisLocation;
    
    point = GLKVector2MultiplyScalar(point, Scale * 2.0/_viewSize.height);
    
    return point;
}

- (GLKVector2)modelVectorForViewVector:(CGPoint)viewVector
{
    GLKVector2 start = [self modelPointForViewPoint:CGPointZero];
    GLKVector2 end = [self modelPointForViewPoint:viewVector];
    
    return GLKVector2Subtract(end, start);
}

- (CGPoint)viewPointForModelPoint:(GLKVector2)modelPoint
{
    GLKVector2 point;
    point = GLKVector2MultiplyScalar(modelPoint, _viewSize.height / (Scale * 2.0));
    point.x += AxisLocation;
    point.y *= -1.0;
    point.y += _viewSize.height/2.0;
    
    return CGPointMake(point.x, point.y);
}

- (float)modelSquareDistanceForViewDistance:(CGFloat)viewDistance
{
    GLKVector2 a = [self modelPointForViewPoint:CGPointMake(0.0, 0.0)];
    GLKVector2 b = [self modelPointForViewPoint:CGPointMake(viewDistance, 0.0)];
    
    return GLKVector2DistanceSq(b, a);
}

@end
