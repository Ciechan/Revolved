//
//  RVTutorialLineImageView.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 01.10.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RVTutorialLineImageView : UIImageView

- (void)positionFromPoint:(CGPoint)from toPoint:(CGPoint)to;
- (void)positionWithRotation:(CGFloat)rotation atPoint:(CGPoint)point;

@end
