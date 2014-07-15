//
//  RVDeleteView.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 16.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVDeleteView.h"

@interface RVDeleteView()

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UIImageView *canImageView;
@property (nonatomic, strong) UIImageView *lidImageView;

@end


@implementation RVDeleteView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.container = [[UIView alloc] initWithFrame:CGRectZero];
        self.container.clipsToBounds = NO;
        self.container.backgroundColor = [UIColor clearColor];
        [self addSubview:self.container];
        
        self.canImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TrashCan"]];
        [self.container addSubview:self.canImageView];
        
        self.lidImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TrashCanLid"]];
        [self.container addSubview:self.lidImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    const CGPoint LidCoverOffset = CGPointMake(-1, 2);
    
    CGRect bounds = self.bounds;
    
    self.container.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    self.canImageView.center = CGPointZero;
    CGPoint canOrigin = self.canImageView.frame.origin;
    CGPoint lidCenter = CGPointMake(canOrigin.x + LidCoverOffset.x, canOrigin.y + LidCoverOffset.y);
    self.lidImageView.center = lidCenter;
}

- (UIColor *)onColor
{
    return [UIColor colorWithHue:0.0 saturation:0.82 brightness:0.89 alpha:0.85];
}

- (UIColor *)offColor
{
    return [UIColor colorWithWhite:0.75 alpha:0.85];
}


- (void)setPercentOpen:(float)percentOpen
{
    percentOpen = MIN(MAX(0.0, percentOpen), 1.0);
    
    if (percentOpen == 1.0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundColor = [self onColor];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundColor = [self offColor];
        }];
    }
    _percentOpen = percentOpen;
    
    self.lidImageView.transform = CGAffineTransformMakeRotation(-M_PI * _percentOpen);
}

- (void)appear
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0f;
    }];
}

- (void)disappearWithDeleteAnimation:(BOOL)shouldAnimateDelete
{
    const float Scale = 1.2f;
    
    if (shouldAnimateDelete) {
        [UIView animateWithDuration:0.2 animations:^{
            self.container.transform = CGAffineTransformMakeScale(Scale, Scale);
            self.container.alpha = 0.5;
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.container.transform = CGAffineTransformIdentity;
                self.container.alpha = 1.0;
                
                self.backgroundColor = [self offColor];
            }];
        }];
    } else {
        [UIView animateWithDuration:_percentOpen * 0.2 animations:^{
            self.lidImageView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.alpha = 0.0f;
                }];
            }
        }];
    }
}


@end
