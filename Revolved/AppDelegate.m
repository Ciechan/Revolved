//
//  AppDelegate.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "AppDelegate.h"

#import "UIColor+RevolvedColors.h"

#import "RVModelViewController.h"
#import "RVRootViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[RVRootViewController alloc] init];
    self.window.rootViewController = self.viewController;
    self.window.backgroundColor = [UIColor rv_backgroundColor];
    self.window.tintColor = [UIColor rv_tintColor];
    [self.window makeKeyAndVisible];
    
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    
    if (url != nil && [url isFileURL]) {
        [self.viewController handleOpeningURL:url];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url != nil && [url isFileURL]) {
        [self.viewController handleOpeningURL:url];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
