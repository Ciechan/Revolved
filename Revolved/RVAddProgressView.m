//
//  RVAddProgressView.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 15.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVAddProgressView.h"

#import <QuartzCore/QuartzCore.h>

@interface RVAddProgressView()

@property (nonatomic, strong) UIView *firstContainer;
@property (nonatomic, strong) UIView *secondContainer;

@property (nonatomic, strong) UIImageView *firstSemiCircle;
@property (nonatomic, strong) UIImageView *secondSemiCircle;

@property (nonatomic, strong, readwrite) UIButton *plus;
@property (nonatomic, strong) UIImageView *plusFull;


@end

@implementation RVAddProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    
    _firstContainer = [[UIView alloc] init];
    _firstContainer.clipsToBounds = YES;
    _firstContainer.backgroundColor = [UIColor clearColor];
    _firstContainer.userInteractionEnabled = NO;
    
    _secondContainer = [[UIView alloc] init];
    _secondContainer.clipsToBounds = YES;
    _secondContainer.backgroundColor = [UIColor clearColor];
    _secondContainer.userInteractionEnabled = NO;
    
    _firstSemiCircle = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"AddSemiCircle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _firstSemiCircle.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
    
    _secondSemiCircle = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"AddSemiCircle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _secondSemiCircle.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
    
    _plus = [UIButton buttonWithType:UIButtonTypeSystem];
    _plus.bounds = CGRectMake(0, 0, 44.0f, 44.0f);
    _plus.exclusiveTouch = YES;
    [_plus setImage:[UIImage imageNamed:@"AddPlus"] forState:UIControlStateNormal];
    
    _plusFull = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"AddFull"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _plusFull.alpha = 0.0f;
    
    [self addSubview:_firstContainer];
    [self addSubview:_secondContainer];
    [self addSubview:_plus];
    [self addSubview:_plusFull];
    
    [_firstContainer addSubview:_firstSemiCircle];
    [_secondContainer addSubview:_secondSemiCircle];
    
    [self setProgress:0.0f];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGRect leftFrame, rightFrame;
    CGRectDivide(bounds, &rightFrame, &leftFrame, bounds.size.width/2.0f, CGRectMaxXEdge);
    
    _firstContainer.frame = rightFrame;
    _secondContainer.frame = leftFrame;
    
    _firstSemiCircle.center = CGPointMake(0.0, rightFrame.size.height/2.0);
    _secondSemiCircle.center = CGPointMake(leftFrame.size.width, leftFrame.size.height/2.0);
    
    _plus.center = CGPointMake(bounds.size.width/2.0, bounds.size.height/2.0);
    _plusFull.center = CGPointMake(bounds.size.width/2.0, bounds.size.height/2.0);
}

- (void)setProgress:(float)progress
{
    [self setProgress:progress allowingFull:NO];
}

- (void)setProgress:(float)progress allowingFull:(BOOL)allowFull
{
    progress = MIN(MAX(0.0f, progress), 1.0f);
    
    _firstSemiCircle.transform = CGAffineTransformMakeRotation(M_PI + 2.0f * M_PI * MIN(progress, 0.5f));
    _secondSemiCircle.transform = CGAffineTransformMakeRotation(M_PI * 2.0f * MAX(progress - 0.5f, 0.0f));
    
    if (progress == 1.0f && _progress < 1.0f && allowFull) {
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _plus.alpha = 0.0f;
            _firstContainer.alpha = 0.0f;
            _secondContainer.alpha = 0.0f;
            
            _plusFull.alpha = 1.0f;
        } completion:NULL];
    } else if (_progress == 1.0f && progress < 1.0f) {
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _plus.alpha = 1.0f;
            _firstContainer.alpha = 1.0f;
            _secondContainer.alpha = 1.0f;
            
            _plusFull.alpha = 0.0f;
        } completion:NULL];
    }
    
    _progress = progress;
}


@end

