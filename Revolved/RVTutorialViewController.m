//
//  RVTutorialViewController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 21.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVTutorialViewController.h"
#import "RVTutorialPage.h"
#import "RVFinishTutorialPage.h"

#import "RVPassForwardView.h"

#import "RVFloatAnimation.h"
#import "RVAnimator.h"
#import "RVUserDefaults.h"

#import "UIView+RotationAnimation.h"

static const CGSize PageSize = {700.0f, 576.0f};
static const CGFloat PageSpace = 120.0f;

@interface RVTutorialViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet RVPassForwardView *backgroundView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) NSArray *pages;

@property (nonatomic, copy) void (^postDismissalBlock)(void);

@end

@implementation RVTutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.backgroundView setForwardView:self.scrollView];
    
    self.backgroundView.backgroundColor = [UIColor rv_dimColor];
    
    self.pages = @[
                   [[NSBundle mainBundle] loadNibNamed:@"RVStartTutorialPage" owner:self options:nil][0],
                   [[NSBundle mainBundle] loadNibNamed:@"RVSegmentsTutorialPage" owner:self options:nil][0],
                   [[NSBundle mainBundle] loadNibNamed:@"RVDrawingTutorialPage" owner:self options:nil][0],
                   [[NSBundle mainBundle] loadNibNamed:@"RVRevolvedTutorialPage" owner:self options:nil][0],
                   [[NSBundle mainBundle] loadNibNamed:@"RVRevolvedTutorialPageSolid" owner:self options:nil][0],
                   [[NSBundle mainBundle] loadNibNamed:@"RVSelectTutorialPage" owner:self options:nil][0],
                   [[NSBundle mainBundle] loadNibNamed:@"RVBendTutorialPage" owner:self options:nil][0],
                   [[NSBundle mainBundle] loadNibNamed:@"RVFinishTutorialPage" owner:self options:nil][0],
                   ];
    
    self.pageIndicator.numberOfPages = self.pages.count;
    
    [[(RVFinishTutorialPage *)[self.pages lastObject] button] addTarget:self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.scrollView.frame = CGRectMake(0.0f, 0.0f, PageSpace + PageSize.width, self.view.bounds.size.height);
    self.scrollView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    self.scrollView.clipsToBounds = NO;
    self.scrollView.contentSize = CGSizeMake(self.pages.count * (PageSize.width + PageSpace), 1.0f);
    self.scrollView.delegate = self;
    self.scrollView.delaysContentTouches = NO;
    
    [self.pages enumerateObjectsUsingBlock:^(RVTutorialPage *page , NSUInteger idx, BOOL *stop) {
        [self.scrollView addSubview:page];
        page.center = CGPointMake((idx + 0.5f) * (PageSize.width + PageSpace), self.scrollView.bounds.size.height/2.0f);
        [page setupInterfaceOrientation:self.interfaceOrientation];
    }];
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HasPlayedTutorialKey]) {

        UIView *lastPage = [self.pages lastObject];
        UIButton *button = self.closeButton;
        [button removeFromSuperview];

        button.center = CGPointMake(lastPage.center.x + lastPage.bounds.size.width/2.0 + 80.0, lastPage.center.y);
        [self.scrollView addSubview:button];
    }
}



- (void)rv_setRotation:(float)rotation
{
    self.scrollView.contentOffset = CGPointMake(rotation, 0.0f);
}

- (float)rv_Rotation
{
    return self.scrollView.contentOffset.x;
}

- (void)presentWithPostDismissalBlock:(void (^)(void))postDismissalBlock
{
    self.postDismissalBlock = postDismissalBlock;
    
    const NSTimeInterval BackgroundDuration = 0.3;
    const float StartOffset = - 900.0f;
    
    self.view.hidden = NO;
    self.backgroundView.alpha = 0.0f;
    [self.scrollView setContentOffset:CGPointMake(StartOffset, 0.0f)];

    [UIView animateWithDuration:BackgroundDuration animations:^{
        self.backgroundView.alpha = 1.0f;
    } completion:^(BOOL finished) {

        self.backgroundView.userInteractionEnabled = NO;
        RVFloatAnimation *animation = [RVFloatAnimation floatAnimationFromValue:StartOffset toValue:0.0f withDuration:0.6f];
        animation.animationCurve = RVAnimationCurveQuartEaseOut;
        animation.completionBlock = ^{self.backgroundView.userInteractionEnabled = YES;};
        
        [[RVAnimator sharedAnimator] addAnimation:animation forKey:@"rotation" toTarget:self];
    
    }];
}

- (void)dismiss
{
    const NSTimeInterval BackgroundDuration = 0.2;
    const NSTimeInterval SlideDuration = 0.3;
    
    self.view.userInteractionEnabled = NO;
    
    [ UIView animateWithDuration:SlideDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.scrollView.transform = CGAffineTransformMakeTranslation(0.0f, self.view.bounds.size.height);
        self.pageIndicator.alpha = 0.0f;
        self.closeButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:BackgroundDuration delay:0.0 options:0 animations:^{
            self.backgroundView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.postDismissalBlock();
            self.postDismissalBlock = nil;
        }];
    }];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat span = scrollView.bounds.size.width/2.0f;
    CGFloat center = scrollView.contentOffset.x + span;

    [self.pages enumerateObjectsUsingBlock:^(RVTutorialPage *page , NSUInteger idx, BOOL *stop) {
        float percent = 1.0f - (page.center.x - center)/span;
        page.displayPercent = percent;
        if (percent >= 0.0 && percent <= 2.0) {
            self.pageIndicator.currentPage = idx;
        }
    }];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.pages enumerateObjectsUsingBlock:^(RVTutorialPage *page , NSUInteger idx, BOOL *stop) {
        [page setupInterfaceOrientation:toInterfaceOrientation];
    }];
}

- (IBAction)closeTapped:(UIButton *)sender
{
    [self dismiss];
}

@end
