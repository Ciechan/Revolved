//
//  DrawGestureRecognizer.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 07.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawGestureRecognizer : UIPanGestureRecognizer

- (CGPoint)firstTouchLocationInView:(UIView *)view;

@end
