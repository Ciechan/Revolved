//
//  AppDelegate.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVRootViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RVRootViewController *viewController;

@end
