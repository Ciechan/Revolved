//
//  RVModelCell.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVModelButtonsView;

@interface RVModelCell : UITableViewCell

@property (nonatomic, strong, readonly) UIView *buttonsContainerView;
@property (nonatomic, strong, readonly) RVModelButtonsView *buttonsView;

@end
