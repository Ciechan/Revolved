//
//  MFMailComposeViewController+SendIfPossible.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 24.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "MFMailComposeViewController+SendIfPossible.h"

@implementation MFMailComposeViewController (SendIfPossible)

+ (BOOL)rv_canSendEmailIfNotShowAlert
{
    if ([self canSendMail]) {
        return YES;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error sending e-mail"
                                                    message:@"Your iPad doesn't have an e-mail account setup"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    return NO;
}

+ (void)rv_showDefaultFailAlertWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error sending e-mail"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
