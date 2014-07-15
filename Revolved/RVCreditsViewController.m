//
//  RVCreditsViewController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVCreditsViewController.h"

#import <MessageUI/MessageUI.h>
#import "MFMailComposeViewController+SendIfPossible.h"

typedef NS_ENUM(NSInteger, TwitterClient) {
    TwitterClientTwitterrific,
    TwitterClientTweetbot,
    TwitterClientTwitter,
};


static NSString * const TwitterNames[] = {
    [TwitterClientTwitterrific] = @"Twitterrific",
    [TwitterClientTweetbot] = @"Tweetbot",
    [TwitterClientTwitter] = @"Twitter",
};

@interface RVCreditsViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *displayedTwitterClients;
@property (weak, nonatomic) IBOutlet UIControl *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@end

@implementation RVCreditsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.twitterButton.exclusiveTouch = YES;
    self.emailButton.exclusiveTouch = YES;
    
    self.view.hidden = YES;
    self.containerView.backgroundColor = [UIColor rv_backgroundColor];
    self.backgroundView.backgroundColor = [UIColor rv_dimColor];

}


- (void)present
{
    const NSTimeInterval BackgroundDuration = 0.2;
    const NSTimeInterval SlideDelay = 0.1;
    const NSTimeInterval SlideDuration = 0.5;
    
    
    self.view.hidden = NO;
    self.backgroundView.alpha = 0.0f;
    self.containerView.transform = CGAffineTransformMakeTranslation(0.0, -self.view.bounds.size.height);
    
    [UIView animateWithDuration:BackgroundDuration animations:^{
        self.backgroundView.alpha = 1.0f;
    }];
    
    [UIView animateWithDuration:SlideDuration delay:SlideDelay usingSpringWithDamping:0.85 initialSpringVelocity:0.0 options:0 animations:^{
        self.containerView.transform = CGAffineTransformIdentity;
    } completion:NULL];
}

- (void)dismiss
{
    const NSTimeInterval BackgroundDuration = 0.2;
    const NSTimeInterval BackgroundDelay = 0.3;
    const NSTimeInterval SlideDuration = 0.5;
    
    [UIView animateWithDuration:BackgroundDuration delay:BackgroundDelay options:0 animations:^{
        self.backgroundView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
    }];
    
    
    [UIView animateWithDuration:SlideDuration delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:-5.0 options:0 animations:^{
        self.containerView.transform = CGAffineTransformMakeTranslation(0.0, -self.view.bounds.size.height);
    } completion:NULL];
}

- (IBAction)backgroundTouched:(UIControl *)sender
{
    [self dismiss];
}


- (IBAction)emailButtonTapped:(UIButton *)sender
{
    if ([MFMailComposeViewController rv_canSendEmailIfNotShowAlert]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"Hello!"];
        [mailer setToRecipients:@[@"bartosz@ciechanowski.me"]];
        [self presentViewController:mailer animated:YES completion:NULL];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultFailed) {
        [MFMailComposeViewController rv_showDefaultFailAlertWithError:error];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}


- (IBAction)twitterButtonTapped:(UIButton *)sender
{
    NSArray *clients = [self twitterClients];
    
    if (clients.count == 0) {
        [[UIApplication sharedApplication] openURL:[self safariAppURL]];
        return;
    }
    
    if (clients.count == 1) {
        [[UIApplication sharedApplication] openURL:[self urlForClient:[[clients firstObject] integerValue]]];
        return;
    }
    
    self.displayedTwitterClients = clients;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Multiple Twitter Clients" message:@"Which one would you like to use?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    for (NSNumber *clientNumber in clients) {
        [alert addButtonWithTitle:TwitterNames[[clientNumber integerValue]]];
    }
    
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    TwitterClient client = [self.displayedTwitterClients[buttonIndex - 1] integerValue];
    [[UIApplication sharedApplication] openURL:[self urlForClient:client]];
}

- (NSArray *)twitterClients
{
    NSMutableArray *clients = [NSMutableArray array];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) {
        [clients addObject:@(TwitterClientTwitterrific)];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
        [clients addObject:@(TwitterClientTweetbot)];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        [clients addObject:@(TwitterClientTwitter)];
    }

    
    return clients;
}


- (NSURL *)urlForClient:(TwitterClient)client
{
    switch (client) {
        case TwitterClientTweetbot:
            return [NSURL URLWithString:@"tweetbot:///user_profile/BCiechanowski"];
        case TwitterClientTwitter:
            return [NSURL URLWithString:@"twitter://user?screen_name=BCiechanowski"];
        case TwitterClientTwitterrific:
            return [NSURL URLWithString:@"twitterrific:///profile?screen_name=BCiechanowski"];
            
        default:
            break;
    }
    return nil;
}

- (NSURL *)safariAppURL
{
    return [NSURL URLWithString:@"https://twitter.com/BCiechanowski"];
}

@end
