//
//  RVColorPickerButton.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 06.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVColorPickerButton.h"

@implementation RVColorPickerButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    const CGFloat Surplus = 7.0f;
    
    CGSize size = self.bounds.size;
    CGFloat radius = MIN(size.width, size.height)/2.0f;
    
    point.x -= radius;
    point.y -= radius;
    
    CGFloat r = radius + Surplus;
    
    return point.x*point.x + point.y*point.y <= r * r;
}

@end
