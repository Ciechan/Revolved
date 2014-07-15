//
//  RVSettingsButtonsView.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RVSettingsButtonsView : UIView

@property (weak, nonatomic) IBOutlet UIButton *tutorialButton;
@property (weak, nonatomic) IBOutlet UIButton *creditsButton;
@property (weak, nonatomic) IBOutlet UIButton *rateMeButton;

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (nonatomic) BOOL out;
- (void)setOut:(BOOL)isOut animated:(BOOL)animated;

@end
