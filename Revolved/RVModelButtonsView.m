//
//  RVModelButtonsView.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 17.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVModelButtonsView.h"

@interface RVModelButtonsView()

@property (weak, nonatomic) IBOutlet UIView *trashContainer;
@property (weak, nonatomic) IBOutlet UIImageView *lidImageView;
@property (weak, nonatomic) IBOutlet UIImageView *canImageView;

@property (weak, nonatomic) IBOutlet UIButton *trashButton;
@property (weak, nonatomic) IBOutlet UIButton *declineTrashButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *allButtons;

@end

@implementation RVModelButtonsView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.lidImageView.image = [self.lidImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.canImageView.image = [self.canImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.backgroundColor = nil;
    
    for (UIButton *button in self.allButtons) {
        button.exclusiveTouch = YES;
    }
    
    [self setTrashCanMode:NO animated:NO];
}

- (IBAction)trashButtonTapped:(UIButton *)sender
{
    [self setTrashCanMode:YES animated:YES];
}

- (IBAction)declineTrashButtonTapped:(UIButton *)sender
{
    [self setTrashCanMode:NO animated:YES];
}

- (IBAction)confirmTrashButtonTapped:(id)sender
{
    self.userInteractionEnabled = NO;
}

- (void)setTrashCanMode:(BOOL)trashCanMode animated:(BOOL)animated
{
    NSTimeInterval Duration = animated ? 0.25 : 0.0;
    CGFloat Scale = 0.05;
    CGFloat TrashQuestionAlpha = 0.75f;
    CGFloat TrashQuestionScale = 0.75f;
    
    if (trashCanMode) {
        self.trashButton.hidden = YES;
        self.trashContainer.hidden = NO;
        

        [UIView animateWithDuration:Duration/2.0f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.shareButton.transform = CGAffineTransformMakeScale(Scale, Scale);
            self.cloneButton.transform = CGAffineTransformMakeScale(Scale, Scale);
        } completion:^(BOOL finished) {

            self.declineTrashButton.alpha = 1.0f;
            self.confirmTrashButton.alpha = 1.0f;
            self.shareButton.alpha = 0.0f;
            self.cloneButton.alpha = 0.0f;
            [UIView animateWithDuration:Duration/2.0f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.confirmTrashButton.transform = CGAffineTransformIdentity;
                self.declineTrashButton.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }];
        
        [UIView animateWithDuration:Duration animations:^{
            self.lidImageView.transform = CGAffineTransformMakeRotation(1.2*M_PI);
            self.trashContainer.alpha = TrashQuestionAlpha;
            self.trashContainer.transform = CGAffineTransformMakeScale(TrashQuestionScale, TrashQuestionScale);
        }];
    } else {
        [UIView animateWithDuration:Duration/2.0f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.confirmTrashButton.transform = CGAffineTransformMakeScale(Scale, Scale);
            self.declineTrashButton.transform = CGAffineTransformMakeScale(Scale, Scale);
        } completion:^(BOOL finished) {

            self.declineTrashButton.alpha = 0.0f;
            self.confirmTrashButton.alpha = 0.0f;
            self.shareButton.alpha = 1.0f;
            self.cloneButton.alpha = 1.0f;

            [UIView animateWithDuration:Duration/2.0f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.shareButton.transform = CGAffineTransformIdentity;
                self.cloneButton.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }];
        
        
        [UIView animateWithDuration:Duration animations:^{
            self.lidImageView.transform = CGAffineTransformIdentity;
            self.trashContainer.alpha = 1.0f;
            self.trashContainer.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            self.trashButton.hidden = NO;
            self.trashContainer.hidden = YES;
        }];
    }
}

@end
