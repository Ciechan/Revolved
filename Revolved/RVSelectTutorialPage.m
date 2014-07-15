//
//  RVSelectTutorialPage.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 02.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSelectTutorialPage.h"

@interface RVSelectTutorialPage()
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *points;
@property (weak, nonatomic) IBOutlet UIImageView *rotatedControlPoint;

@end


@implementation RVSelectTutorialPage

- (void)setDisplayPercent:(float)displayPercent
{
    [super setDisplayPercent:displayPercent];
    
    
    float progress = [self progressForPercent:displayPercent];
    float alpha = 0.3 + 0.7 * progress;
    float scale = 0.01 + 0.99 * progress;
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    
    for (UIView *point in self.points) {
        point.alpha = alpha;
        if (point == _rotatedControlPoint) {
            point.transform = CGAffineTransformRotate(transform, M_PI_2);
        } else {
            point.transform = transform;
        }
    }
}

- (NSString *)descriptionString
{
    return @"After selecting a segment with a tap...";
}

- (float)progressForPercent:(float)percent
{
    return MIN(MAX(0.0, (percent - 0.2)/0.8), 1.0);
}

@end
