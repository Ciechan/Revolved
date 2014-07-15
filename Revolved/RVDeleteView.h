//
//  RVDeleteView.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 16.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RVDeleteView : UIView

@property (nonatomic) float percentOpen;

- (void)appear;
- (void)disappearWithDeleteAnimation:(BOOL)shouldAnimateDelete;

@end
