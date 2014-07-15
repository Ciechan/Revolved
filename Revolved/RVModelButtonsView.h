//
//  RVModelButtonsView.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 17.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RVModelButtonsView : UIView

@property (weak, nonatomic) IBOutlet UIButton *cloneButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmTrashButton;

- (void)setTrashCanMode:(BOOL)trashCanMode animated:(BOOL)animated;


@end
