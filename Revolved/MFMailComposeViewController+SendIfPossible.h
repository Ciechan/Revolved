//
//  MFMailComposeViewController+SendIfPossible.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 24.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface MFMailComposeViewController (SendIfPossible)

+ (BOOL)rv_canSendEmailIfNotShowAlert;
+ (void)rv_showDefaultFailAlertWithError:(NSError *)error;

@end
