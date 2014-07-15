//
//  RVColorPicker.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 14.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Color.h"

@interface RVColorPicker : UIControl

@property (nonatomic, readonly) BOOL expanded;
@property (nonatomic) NSUInteger selectedColorIndex;
- (void)setSelectedColorIndex:(NSUInteger)selectedColorIndex animated:(BOOL)animated;



- (void)expandAnimated:(BOOL)animated;
- (void)collapseAnimated:(BOOL)animated;

@end
