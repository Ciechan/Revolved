//
//  RVBendTutorialPage.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 02.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVBendTutorialPage.h"

@interface RVBendTutorialPage()

@property (weak, nonatomic) IBOutlet UIImageView *lineBend1;
@property (weak, nonatomic) IBOutlet UIImageView *lineBend2;
@property (weak, nonatomic) IBOutlet UIImageView *lineBend3;
@property (weak, nonatomic) IBOutlet UIImageView *lineBend4;
@property (weak, nonatomic) IBOutlet UIImageView *lineBend5;

@property (nonatomic, strong) NSArray *lines;

@end

@implementation RVBendTutorialPage

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.lines = @[self.lineBend1,
                   self.lineBend2,
                   self.lineBend3,
                   self.lineBend4,
                   self.lineBend5];
}

- (NSString *)descriptionString
{
    return @"...drag handles to change its shape";
}


- (void)setDisplayPercent:(float)displayPercent
{
    [super setDisplayPercent:displayPercent];
    
    displayPercent -= 0.4;
    displayPercent /= 0.6;
    
    NSUInteger count = self.lines.count;
    
    [self.lines enumerateObjectsUsingBlock:^(UIView *line, NSUInteger idx, BOOL *stop) {

        float probingOffset = (count - (NSInteger)idx - 1)/(float)(count - 1);
        float probe = displayPercent + probingOffset - 1.0f;
        
        if (idx == 0) {
            probe = MAX(probe, 0.0);
        } else if (idx == count - 1) {
            probe = MIN(probe, 0.0);
        }
        float progress = [self progressForPercent:probe];
        
        line.alpha = progress;
    }];
}

- (float)progressForPercent:(float)percent
{
    float value = (-fabsf(percent) + 1.0f);
    
    return MIN(MAX(0.0f, value), 1.0);
}

@end
