//
//  DrawGestureRecognizer.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 07.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "DrawGestureRecognizer.h"

@interface DrawGestureRecognizer()

@property (nonatomic, strong) UITouch *firstTouch;
@property (nonatomic) CGPoint firstTouchLocation;

@end

@implementation DrawGestureRecognizer



- (CGPoint)firstTouchLocationInView:(UIView *)view
{
    return [self.view convertPoint:self.firstTouchLocation toView:view];
}


- (void)reset
{
    [super reset];
    self.firstTouch = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.numberOfTouches > 0) {
        return;
    }
    
    if (touches.count > 1) {
        touches = [NSSet setWithObject:[touches anyObject]];
    }
    
    [super touchesBegan:touches withEvent:event];

    self.firstTouch = [touches anyObject];
    self.firstTouchLocation = [self.firstTouch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![touches containsObject:self.firstTouch]) {
        return;
    }
    
    touches = [NSSet setWithObject:self.firstTouch];
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![touches containsObject:self.firstTouch]) {
        return;
    }
    
    touches = [NSSet setWithObject:self.firstTouch];
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![touches containsObject:self.firstTouch]) {
        return;
    }
    
    touches = [NSSet setWithObject:self.firstTouch];
    
    [super touchesCancelled:touches withEvent:event];
}


@end
