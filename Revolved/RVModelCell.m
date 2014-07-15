//
//  RVModelCell.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVModelCell.h"
#import "RVModelButtonsView.h"

@implementation RVModelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.contentView.superview.clipsToBounds = NO;
        _buttonsView = [[NSBundle mainBundle] loadNibNamed:@"RVModelButtonsView" owner:self options:nil][0];
        _buttonsView.alpha = 0.0f;
        

        _buttonsContainerView = [[UIView alloc] initWithFrame:_buttonsView.bounds];
        _buttonsContainerView.backgroundColor = nil;
        
        [_buttonsContainerView addSubview:_buttonsView];
        [self.contentView addSubview:_buttonsContainerView];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.buttonsView.userInteractionEnabled = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _buttonsContainerView.center = CGPointMake(_buttonsView.bounds.size.height/2.0f + 3.0f, self.contentView.frame.size.height/2.0);
    _buttonsContainerView.transform = CGAffineTransformMakeRotation(M_PI_2);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.buttonsView.alpha = editing ? 1.0f : 0.0f;
    } completion:^(BOOL finished) {
        if (finished && !editing) {
            [self.buttonsView setTrashCanMode:NO animated:NO];
        }
    }];
}
@end
