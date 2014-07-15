//
//  RVColorPicker.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 14.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVColorPicker.h"
#import "RVColorProvider.h"
#import "RVColorPickerButton.h"
#import <QuartzCore/QuartzCore.h>


static const CGFloat FlowerRadius = 22.0f;
static const CGFloat CenterPieceRadius = 30.0f;
static const CGFloat ExpandedRadius = 94.0f;
static const CGFloat TotalRadius = ExpandedRadius + FlowerRadius;


static const CGFloat CollapsedTopOffset = 40.0f;
static const CGFloat ExpandedTopOffset = 160.0f;


@interface RVColorPicker()

@property (nonatomic, strong) UIView *rootContainer;
@property (nonatomic, strong) UIButton *centerPiece;
@property (nonatomic, strong) UIView *centerPieceColorView;

@property (nonatomic, strong) NSArray *lollipops;
@property (nonatomic, strong) NSArray *stems;
@property (nonatomic, strong) NSArray *flowers;

@end


@implementation RVColorPicker



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
    //self.layer.speed = 0.1;
    
    [self addTarget:self action:@selector(touchedUp) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchedUp) forControlEvents:UIControlEventTouchUpOutside];
    
    self.rootContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2.0 * TotalRadius, 2.0 * TotalRadius)];
    self.rootContainer.center = CGPointMake(self.bounds.size.width/2.0, CollapsedTopOffset);
    self.rootContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.rootContainer];
    
    NSMutableArray *lollipops = [NSMutableArray array];
    NSMutableArray *stems = [NSMutableArray array];
    NSMutableArray *flowers = [NSMutableArray array];
    
    
    for (int i = 0; i < ColorCount; i++) {
        
        UIView *lollipop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2.0 * FlowerRadius, TotalRadius)];
        lollipop.layer.anchorPoint = CGPointMake(0.5, 1.0);
        lollipop.backgroundColor = [UIColor clearColor];
        lollipop.center = CGPointMake(TotalRadius, TotalRadius);
        lollipop.transform = CGAffineTransformMakeRotation(i * 2.0 * M_PI/ColorCount);
        [lollipops addObject:lollipop];
        
        UIImageView *stem = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Stem"]];
        stem.layer.anchorPoint = CGPointMake(0.5, 1.0);
        stem.center = CGPointMake(FlowerRadius, TotalRadius);
        [stems addObject:stem];
        
        UIButton *flower = [[RVColorPickerButton alloc] initWithFrame:CGRectMake(0, 0, 2.0 * FlowerRadius, 2.0 * FlowerRadius)];
        flower.backgroundColor = [RVColorProvider colorForColorIndex:i];
        flower.layer.cornerRadius = FlowerRadius;
        flower.center = CGPointMake(FlowerRadius, TotalRadius);
        flower.tag = i;
        [flower addTarget:self action:@selector(masterColorTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [flowers addObject:flower];
        
        [self.rootContainer addSubview:lollipop];
        [lollipop addSubview:stem];
        [lollipop addSubview:flower];
    }
    
    self.centerPiece = [[RVColorPickerButton alloc] initWithFrame:CGRectMake(0, 0, 2.0 * CenterPieceRadius, 2.0 * CenterPieceRadius)];
    self.centerPiece.center = CGPointMake(TotalRadius, TotalRadius);
    self.centerPiece.layer.cornerRadius = CenterPieceRadius;
    self.centerPiece.backgroundColor = [UIColor redColor];
    [self.centerPiece addTarget:self action:@selector(centerPieceTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.rootContainer addSubview:self.centerPiece];
    
    self.centerPieceColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2.0 * CenterPieceRadius, 2.0 * CenterPieceRadius)];
    self.centerPieceColorView.layer.cornerRadius = CenterPieceRadius;
    self.centerPieceColorView.backgroundColor = [UIColor clearColor];
    self.centerPieceColorView.userInteractionEnabled = NO;
    [self.centerPiece addSubview:self.centerPieceColorView];
    
    self.lollipops = lollipops;
    self.stems = stems;
    self.flowers = flowers;
    
    _selectedColorIndex = NSNotFound; //forcing refresh on setter
    self.selectedColorIndex = 0;
    [self collapseAnimated:NO];
}

- (void)layoutSubviews
{
    if (self.expanded) {
        [self expandAnimated:NO];
    } else {
        [self collapseAnimated:NO];
    }
}


- (void)centerPieceTap:(UIButton *)sender
{
    if (self.expanded) {
        [self collapseAnimated:YES];
    } else {
        [self expandAnimated:YES];
    }
}

- (void)setSelectedColorIndex:(NSUInteger)selectedColorIndex
{
    [self setSelectedColorIndex:selectedColorIndex animated:NO];
}

- (void)setSelectedColorIndex:(NSUInteger)selectedColorIndex animated:(BOOL)animated
{
    selectedColorIndex = MIN(ColorCount - 1, selectedColorIndex);
    
    if (_selectedColorIndex == selectedColorIndex) {
        return;
    }
    _selectedColorIndex = selectedColorIndex;
    
    self.centerPieceColorView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.centerPieceColorView.backgroundColor = [RVColorProvider colorForColorIndex:selectedColorIndex];
    self.centerPieceColorView.alpha = 0.4f;
    [UIView animateWithDuration:animated ? 0.2 : 0.0 animations:^{
        self.centerPieceColorView.transform = CGAffineTransformIdentity;
        self.centerPieceColorView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.centerPiece.backgroundColor = [RVColorProvider colorForColorIndex:selectedColorIndex];
        self.centerPieceColorView.alpha = 0.0f;
    }];
}


- (void)touchedUp
{
    [self collapseAnimated:YES];
}

- (void)masterColorTouchUp:(UIView *)sender
{
    if (self.expanded) {
        
        [self setSelectedColorIndex:sender.tag animated:YES];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self collapseAnimated:YES];
    } else {
        [self expandAnimated:YES];
    }
}

- (void)collapseAnimated:(BOOL)animated
{
    const CGFloat CollapsedScale = 0.3;
    
    const NSTimeInterval FirstStepDelayVariaton = 0.15;
    
    const NSTimeInterval WitherDuration = 0.3;
    const NSTimeInterval WitherDamping = 1.0;
    const NSTimeInterval WitherVelocity = -2.0;
    
    const NSTimeInterval ShrinkDuration = 0.15;
    const NSTimeInterval ShrinkDamping = 1.0;
    const NSTimeInterval ShrinkVelocity = 0.0;
    
    const NSTimeInterval HopDuration = 0.45;
    const NSTimeInterval HopDelay = 0.1;
    const NSTimeInterval HopDamping = 1.0;
    const NSTimeInterval HopVelocity = -5.0;
    
    _expanded = NO;
    
    [UIView animateWithDuration:animated ? HopDuration : 0.0
                          delay:animated ? HopDelay: 0.0
         usingSpringWithDamping:HopDamping
          initialSpringVelocity:HopVelocity
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.centerPiece.transform = CGAffineTransformMakeScale(FlowerRadius/CenterPieceRadius, FlowerRadius/CenterPieceRadius);
                         self.rootContainer.transform = CGAffineTransformIdentity;
                     }
                     completion:NULL];
    
    for (int i = 0; i < ColorCount; i++) {
        const NSTimeInterval delay = drand48() * FirstStepDelayVariaton;
        
        UIView *stem = self.stems[i];
        UIView *flower = self.flowers[i];
        
        [UIView animateWithDuration:animated ? WitherDuration : 0.0
                              delay:animated ? delay : 0.0
             usingSpringWithDamping:WitherDamping
              initialSpringVelocity:WitherVelocity
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             stem.transform = CGAffineTransformIdentity;
                             flower.center = CGPointMake(FlowerRadius, TotalRadius);
                         } completion:NULL];
        
        [UIView animateWithDuration:animated ? ShrinkDuration : 0.0
                              delay:animated ? delay : 0.0
             usingSpringWithDamping:ShrinkDamping
              initialSpringVelocity:ShrinkVelocity
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             flower.transform = CGAffineTransformMakeScale(0.8f * CollapsedScale, CollapsedScale);
                         } completion:NULL];
        
        
    }
}


- (void)expandAnimated:(BOOL)animated
{
    const NSTimeInterval DropDuration = 0.45;
    const NSTimeInterval DropDamping = 0.78;
    const NSTimeInterval DropVelocity = 12.0;
    
    
    const NSTimeInterval SecondStepDelayVariaton = 0.2;
    
    const NSTimeInterval ExpandDelay = 0.06;
    const NSTimeInterval ExpandDuration = 0.4;
    const NSTimeInterval ExpandDamping = 0.65;
    const NSTimeInterval ExpandVelocity = 10.0;
    
    const NSTimeInterval BlossomDelay = 0.13;
    const NSTimeInterval BlossomDuration = 0.3;
    const NSTimeInterval BlossomDamping = 0.9;
    const NSTimeInterval BlossomVelocity = 35.0;
    
    _expanded = YES;
    
    
    [UIView animateWithDuration:animated ? DropDuration : 0.0
                          delay:0.0
         usingSpringWithDamping:DropDamping
          initialSpringVelocity:DropVelocity
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.centerPiece.transform = CGAffineTransformIdentity;
                         self.rootContainer.transform = CGAffineTransformMakeTranslation(0.0, ExpandedTopOffset - CollapsedTopOffset);
                     }
                     completion:NULL];
    
    for (int i = 0; i < ColorCount; i++) {
        const NSTimeInterval surplusDelay = drand48() * SecondStepDelayVariaton;
        
        UIView *stem = self.stems[i];
        UIView *flower = self.flowers[i];
        
        [UIView animateWithDuration:animated ? ExpandDuration : 0.0
                              delay:animated ? (ExpandDelay + surplusDelay) : 0.0
             usingSpringWithDamping:ExpandDamping
              initialSpringVelocity:ExpandVelocity
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             stem.transform = CGAffineTransformMakeScale(1.0, ExpandedRadius);
                             flower.center = CGPointMake(FlowerRadius, FlowerRadius);
                         } completion:NULL];
        
        [UIView animateWithDuration:animated ? BlossomDuration : 0.0
                              delay:animated ? (BlossomDelay + surplusDelay) : 0.0
             usingSpringWithDamping:BlossomDamping
              initialSpringVelocity:BlossomVelocity
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             flower.transform = CGAffineTransformIdentity;
                         } completion:NULL];
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self && !_expanded) {
        return nil;
    }
    
    
    return hitView;
}



@end
