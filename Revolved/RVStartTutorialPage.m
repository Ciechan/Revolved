//
//  RVStartTutorialPage.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 02.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVStartTutorialPage.h"

@interface RVStartTutorialPage()

@property (weak, nonatomic) IBOutlet UIImageView *getToKnow;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UIImageView *wheel;

@end

@implementation RVStartTutorialPage

- (void)setDisplayPercent:(float)displayPercent
{
    [super setDisplayPercent:displayPercent];

    self.wheel.transform = CGAffineTransformMakeRotation(-(displayPercent - 1.0f) * 2.0 * M_PI);
    displayPercent = MIN(MAX(0.0f, displayPercent), 1.0f);
    
    const CGFloat Offset = 500.0f;
    
    self.getToKnow.transform = CGAffineTransformMakeTranslation(0.0f, -Offset * (1.0f + displayPercent * (displayPercent - 2.0)));

    displayPercent -= 0.5;
    displayPercent *= 2.0f;
    displayPercent = MIN(MAX(0.0f, displayPercent), 1.0f);

    self.logo.alpha = displayPercent;
}

@end
