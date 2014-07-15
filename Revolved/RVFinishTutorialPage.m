//
//  RVFinishTutorialPage.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVFinishTutorialPage.h"


@interface RVFinishTutorialPage()

@property (weak, nonatomic) IBOutlet UIImageView *haveFunCaption;

@end

@implementation RVFinishTutorialPage

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.button.exclusiveTouch = YES;
}

- (void)setDisplayPercent:(float)displayPercent
{
    [super setDisplayPercent:displayPercent];
    
    displayPercent += 0.2;

    displayPercent = MIN(MAX(0.0f, displayPercent), 1.0f);
    displayPercent = 1.0 - displayPercent;

    displayPercent *= displayPercent;
    
    self.haveFunCaption.transform = CGAffineTransformMakeTranslation(0.0f, 150.0f * (displayPercent));
    self.button.transform = CGAffineTransformMakeTranslation(0.0f, -400.0f * (displayPercent));
}

@end
