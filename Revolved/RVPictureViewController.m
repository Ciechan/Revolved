//
//  RVPictureViewController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 20.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "MFMailComposeViewController+SendIfPossible.h"
#import <Social/Social.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "RVPictureViewController.h"


static NSString * const ShareText = @"Check out what I've created in Revolved app! \nhttp://bit.ly/Rvlvd";


@interface RVPictureViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIControl *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation RVPictureViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.hidden = YES;
}

- (void)present
{
    const NSTimeInterval BackgroundDuration = 0.2;
    const NSTimeInterval SlideDelay = 0.1;
    const NSTimeInterval SlideDuration = 0.5;
    
    self.view.hidden = NO;
    self.backgroundView.alpha = 0.0f;
    self.backgroundView.backgroundColor = [UIColor rv_dimColor];
    self.containerView.transform = CGAffineTransformMakeTranslation(0.0, self.view.bounds.size.height);
    self.imageView.image = self.image;
    self.separator.backgroundColor = [UIColor rv_tintColor];
    
    for (UIButton *button in self.buttons) {
        button.exclusiveTouch = YES;
    }
    
    [UIView animateWithDuration:BackgroundDuration animations:^{
        self.backgroundView.alpha = 1.0f;
    }];
    
    [UIView animateWithDuration:SlideDuration delay:SlideDelay usingSpringWithDamping:0.85 initialSpringVelocity:0.0 options:0 animations:^{
        self.containerView.transform = CGAffineTransformIdentity;
    } completion:NULL];
}

- (void)dismissWithSuccess:(BOOL)success
{
    const NSTimeInterval BackgroundDuration = 0.2;
    const NSTimeInterval BackgroundDelay = 0.3;
    const NSTimeInterval SlideDuration = 0.5;
    
    [UIView animateWithDuration:BackgroundDuration delay:BackgroundDelay options:0 animations:^{
        self.backgroundView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
        self.imageView.image = nil;
        self.image = nil;
    }];
    
    CGFloat offset = (success ? -1.0 : 1.0) * self.view.bounds.size.height;
    
    [UIView animateWithDuration:SlideDuration delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:-5.0 options:0 animations:^{
        self.containerView.transform = CGAffineTransformMakeTranslation(0.0, offset);
    } completion:NULL];
}

- (void)setButtonsEnabled:(BOOL)enabled
{
    
}

- (IBAction)twitterButtonTapped:(UIButton *)sender
{
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeController setInitialText:ShareText];
    [composeController addImage:self.image];
    [composeController setCompletionHandler:^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultDone) {
            [self dismissWithSuccess:YES];
        }
    }];
    
    [self presentViewController:composeController animated:YES completion:NULL];
}

- (IBAction)facebookButtonTapped:(UIButton *)sender
{
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [composeController setInitialText:ShareText];
    [composeController addImage:self.image];
    [composeController setCompletionHandler:^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultDone) {
            [self dismissWithSuccess:YES];
        }
    }];
    
    [self presentViewController:composeController animated:YES completion:NULL];
}

- (IBAction)emailButtonTapped:(UIButton *)sender
{
    if ([MFMailComposeViewController rv_canSendEmailIfNotShowAlert]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"Picture from Revolved app"];
        [mailer setMessageBody:ShareText isHTML:NO];
        [mailer addAttachmentData:UIImagePNGRepresentation(self.image)
                         mimeType:@"image/png" fileName:@"model picture.png"];
        [self presentViewController:mailer animated:YES completion:^{}];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultFailed) {
        [MFMailComposeViewController rv_showDefaultFailAlertWithError:error];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            if (result == MFMailComposeResultSaved || result == MFMailComposeResultSent) {
                [self dismissWithSuccess:YES];
            }
        }];
    }
}

- (IBAction)cameraRollButtonTapped:(UIButton *)sender
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:self.image.CGImage
                              orientation:(ALAssetOrientation)self.image.imageOrientation
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              if (!error) {
                                  [self dismissWithSuccess:YES];
                              }
                          }];
}

- (IBAction)backgroundTouchedUp:(UIControl *)sender
{
    [self dismissWithSuccess:NO];
}

@end
