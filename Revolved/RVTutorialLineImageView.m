//
//  RVTutorialLineImageView.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 01.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVTutorialLineImageView.h"

@implementation RVTutorialLineImageView

- (void)awakeFromNib
{
    self.image = [[UIImage imageNamed:@"TutorialLine"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    [self positionFromPoint:self.center toPoint:self.center];
}

/*
 I shouldn't really modify self, but this is much more convenient
 */
- (void)positionFromPoint:(CGPoint)from toPoint:(CGPoint)to
{
    const CGFloat LengthSurplus = 3.0f;
    
    CGFloat dx = to.x - from.x;
    CGFloat dy = to.y - from.y;
    
    CGFloat length = sqrtf(dx * dx + dy * dy);
    
    self.bounds = CGRectMake(0.0f, 0.0f, length + 2.0 * LengthSurplus, 6.0f);
    self.center = CGPointMake(from.x + dx/2.0f, from.y + dy/2.0f);
    self.transform = CGAffineTransformMakeRotation(atan2f(dy, dx));
}

- (void)positionWithRotation:(CGFloat)rotation atPoint:(CGPoint)point
{
    self.bounds = CGRectMake(0.0, 0.0, 6.0f, 6.0f);
    self.center = point;
    self.transform = CGAffineTransformMakeRotation(rotation);
}

@end
