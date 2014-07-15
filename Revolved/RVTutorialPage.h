//
//  RVTutorialPageCell.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 21.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RVTutorialPage : UIView

@property (nonatomic) float displayPercent;

- (void)setupInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (NSString *)descriptionString;


@end
