//
//  RVRevolvedTutorialPage.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 01.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVRevolvedTutorialPage.h"
#import "RVTutorialLineImageView.h"

@interface RVRevolvedTutorialPage()

@property (weak, nonatomic) IBOutlet RVTutorialLineImageView *line;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIImageView *frontImageView;

@end

@implementation RVRevolvedTutorialPage


- (void)setDisplayPercent:(float)displayPercent
{
    [super setDisplayPercent:displayPercent];
    
    const CGSize TopSize = {58, 32};
    const CGSize BottomSize = {156, 92};
    
    const CGFloat Top = 190.0f;
    const CGFloat Bottom = 323.0f;
    
    float progress = [self progressForPercent:displayPercent];
    float angle = 2.0 * M_PI * progress + M_PI_2;
    
    float s = sinf(angle);
    float c = cosf(angle);
    
    float alpha = MIN(MAX(0.0f, progress), 1.0f);

    CGFloat x = self.bounds.size.width/2.0f;
    
    CGPoint start = CGPointMake(x + c * TopSize.width, Top + s * TopSize.height);
    CGPoint end = CGPointMake(x + c * BottomSize.width, Bottom + s * BottomSize.height);
    
    if (self.backImageView) {
        self.backImageView.alpha = alpha;
        self.frontImageView.alpha = alpha;
        self.line.alpha = 1.0 - alpha;
    }

    [self.line positionFromPoint:start toPoint:end];
}

- (NSString *)descriptionString
{
    return self.backImageView ?  @"...to create your model" : @"Segments get Revolved around the axis...";
}

- (float)progressForPercent:(float)percent
{
    return percent - 0.2;
}


@end
