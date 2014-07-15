//
//  RVTutorialPageCell.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 21.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVTutorialPage.h"

const CGFloat LabelHeight = 50.0f;

@interface RVTutorialPage()

@property (nonatomic, strong) UILabel *label;

@end


@implementation RVTutorialPage

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor rv_backgroundColor];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height - LabelHeight, self.bounds.size.width, LabelHeight)];
    self.label.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.85];
    self.label.textColor = [UIColor whiteColor];
    self.label.text = [self descriptionString];
    self.label.textAlignment = NSTextAlignmentCenter;
    if (![self.label.text length]) {
        self.label.hidden = YES;
    }
        
    [self addSubview:self.label];
}

- (void)setDisplayPercent:(float)displayPercent
{
    _displayPercent = displayPercent;
    
    self.hidden = displayPercent > 3.3 || displayPercent < -1.3;

    displayPercent -= 1.0f;
    
    const float Span = 0.3;
    
    if (displayPercent > Span) {
        displayPercent -= Span;
        displayPercent *= -1.0f;
        displayPercent += 1.0f;
    } else if ( displayPercent < -Span) {
        displayPercent += 1.0 + Span;
    } else {
        displayPercent = 1.0f;
    }
}


- (void)setupInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    
}

- (NSString *)descriptionString
{
    return @"";
}

@end
