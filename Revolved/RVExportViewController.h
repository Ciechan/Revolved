//
//  RVExportViewController.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 27.12.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVModel;
@interface RVExportViewController : UIViewController

@property (nonatomic, strong) RVModel *model;

- (void)present;
- (void)dismiss;

@end
