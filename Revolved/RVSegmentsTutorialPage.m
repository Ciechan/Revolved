//
//  RVSegmentsTutorialPage.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 01.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSegmentsTutorialPage.h"

@interface RVSegmentsTutorialPage()

@property (weak, nonatomic) IBOutlet UIImageView *firstSegmentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondSegmentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdSegmentImageView;

@end

@implementation RVSegmentsTutorialPage


- (NSString *)descriptionString
{
    return @"In Revolved models consist of segments";
}

- (void)setDisplayPercent:(float)displayPercent
{
    [super setDisplayPercent:displayPercent];
    
    
    const CGFloat Offset = 440.0f;
    
    self.firstSegmentImageView.transform  = CGAffineTransformMakeTranslation(0.0f, -1 * Offset * [self progressForPercent:displayPercent*1.0]);
    self.secondSegmentImageView.transform = CGAffineTransformMakeTranslation(0.0f, -2 * Offset * [self progressForPercent:displayPercent*1.0]);
    self.thirdSegmentImageView.transform  = CGAffineTransformMakeTranslation(0.0f, -3 * Offset * [self progressForPercent:displayPercent*1.0]);
}

- (float)progressForPercent:(float)percent
{
    percent = MIN(MAX(0.0f, percent), 1.0f);

    float value = - percent * (percent - 2.0f);
    return MIN(MAX(0.0f, 1.0f - value), 1.0f);
}


@end
