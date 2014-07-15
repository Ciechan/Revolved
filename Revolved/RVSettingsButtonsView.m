//
//  RVSettingsButtonsView.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVSettingsButtonsView.h"

static const CGFloat Radius = 59.0f;
static const CGFloat Angle = M_PI/3.5;

@interface RVSettingsButtonsView()

@property (weak, nonatomic) IBOutlet UIView *container;

@end


@implementation RVSettingsButtonsView

- (void)awakeFromNib
{
    self.tutorialButton.exclusiveTouch = YES;
    self.creditsButton.exclusiveTouch = YES;
    self.rateMeButton.exclusiveTouch = YES;
    self.settingsButton.exclusiveTouch = YES;
    
    CGSize size = self.container.bounds.size;
    
    CGFloat dx = roundf(Radius * sinf(Angle));
    CGFloat dy = roundf(Radius * cosf(Angle));
    
    
    self.tutorialButton.center = CGPointMake(size.width/2.0 - dx, size.width/2.0 - dy);
    self.creditsButton.center = CGPointMake(size.width/2.0, size.width/2.0 - Radius);
    self.rateMeButton.center = CGPointMake(size.width/2.0 + dx, size.width/2.0 - dy);

    [self setOut:NO];
}

- (IBAction)buttonTapped:(UIButton *)sender
{
    [self setOut:!self.out animated:YES];
}


- (void)setOut:(BOOL)out
{
    [self setOut:out animated:NO];
}

- (void)setOut:(BOOL)isOut animated:(BOOL)animated
{
    NSTimeInterval duration = 0.5;
    CGFloat damping = 0.8f;
    CGFloat velocity = -1.0f;
    
    const CGFloat AlmostPi = M_PI*0.999f;
    const CGFloat AlmostZero = 0.0f;

    self.settingsButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:animated ? duration : 0.0f delay:0.0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.container.transform = CGAffineTransformMakeRotation(isOut ? AlmostZero : AlmostPi);
        self.tutorialButton.transform = CGAffineTransformMakeRotation(isOut ? AlmostZero : -AlmostPi);
        self.creditsButton.transform = CGAffineTransformMakeRotation(isOut ? AlmostZero : -AlmostPi);
        self.rateMeButton.transform = CGAffineTransformMakeRotation(isOut ? AlmostZero : -AlmostPi);
    } completion:^(BOOL finished) {
        self.settingsButton.userInteractionEnabled = YES;
        
        if (finished && !isOut) {
            self.container.transform = CGAffineTransformMakeRotation(-AlmostPi);
            self.tutorialButton.transform = CGAffineTransformMakeRotation(AlmostPi);
            self.creditsButton.transform = CGAffineTransformMakeRotation(AlmostPi);
            self.rateMeButton.transform = CGAffineTransformMakeRotation(AlmostPi);
        }
    }];
    
    self.tutorialButton.userInteractionEnabled = isOut;
    self.creditsButton.userInteractionEnabled = isOut;
    self.rateMeButton.userInteractionEnabled = isOut;
    
    _out = isOut;
}

@end
