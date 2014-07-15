//
//  RVAddProgressView.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 15.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RVAddProgressView : UIView

@property (nonatomic, strong, readonly) UIButton *plus;
@property (nonatomic) float progress;

- (void)setProgress:(float)progress allowingFull:(BOOL)allowFull;

@end
