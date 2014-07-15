//
//  RVDrawingTutorialPage.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 01.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVDrawingTutorialPage.h"
#import "RVTutorialLineImageView.h"

@interface RVDrawingTutorialPage()

@property (weak, nonatomic) IBOutlet UIView *iPadBorderView;
@property (weak, nonatomic) IBOutlet UIImageView *iPadCameraImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iPadHomeButtonImageView;
@property (weak, nonatomic) IBOutlet RVTutorialLineImageView *line;

@end

@implementation RVDrawingTutorialPage

/*
 I detect the device color by a private API call. Then it's just a matter of
 adjusting the iPad color on screen.
 */

+ (NSString *)deviceColor
{
    static NSString * color = @"white";
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *deviceColor;
        NSString *argument = [@"hDhehvihcehCohlhhorh" stringByReplacingOccurrencesOfString:@"h" withString:@""];
        NSString *selectorString = [@"_zdzzezvzizczzezIznzfzoFzozrzKezyz:" stringByReplacingOccurrencesOfString:@"z" withString:@""];

        SEL selector = NSSelectorFromString(selectorString);
        if ([[UIDevice currentDevice] respondsToSelector:selector]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setArgument:&argument atIndex:2];
            [invocation setTarget:[UIDevice currentDevice]];
            [invocation invoke];
            [invocation getReturnValue:&deviceColor];
        }
        
        if ([deviceColor isKindOfClass:[NSString class]] && (
            [deviceColor isEqualToString:@"black"] ||
            [deviceColor isEqualToString:@"#3b3b3c"] )) {
            color = @"black";
        }
    });
    
    return color;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
        
    if ([[RVDrawingTutorialPage deviceColor] isEqualToString:@"black"]) {
        self.iPadHomeButtonImageView.image = [UIImage imageNamed:@"TutorialiPadHomeBlack"];
        self.iPadBorderView.backgroundColor = [UIColor colorWithWhite:0.09 alpha:1.0f];
    }
}

- (NSString *)descriptionString
{
    return @"You draw them on the right side of the screen";
}


/*
 Making sure the iPad on screen looks the same as the one held in user's hands
 */
- (void)setupInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    self.iPadCameraImageView.alpha = orientation == UIInterfaceOrientationLandscapeLeft ? 1.0f : 0.0f;
    self.iPadHomeButtonImageView.alpha = orientation == UIInterfaceOrientationLandscapeLeft ? 0.0f : 1.0f;
}

- (void)setDisplayPercent:(float)displayPercent
{
    [super setDisplayPercent:displayPercent];
    
    const CGPoint Start = {188, 125};
    const CGPoint End = {364, 392};
    

    float progress = [self progressForPercent:displayPercent];
    CGFloat dx = End.x - Start.x;
    CGFloat dy = End.y - Start.y;
    
    CGPoint end = CGPointMake(Start.x + progress * dx, Start.y + progress * dy);
    
    if (progress == 0.0f) {
        [self.line positionWithRotation:atan2f(dy, dx) atPoint:Start];
    } else {
        [self.line positionFromPoint:Start toPoint:end];
    }
}


- (float)progressForPercent:(float)percent
{
    percent = MIN(MAX(0.0f, percent), 1.0f);
    
    return percent;
}



@end
