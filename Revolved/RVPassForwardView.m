//
//  RVPassForwardView.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 02.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVPassForwardView.h"

@implementation RVPassForwardView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *target = [super hitTest:point withEvent:event];
    
    if (target == self) {
        return self.forwardView;
    }
    
    return target;
}

@end
