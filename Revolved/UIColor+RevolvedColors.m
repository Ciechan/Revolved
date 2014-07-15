//
//  UIColor+RevolvedColors.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "UIColor+RevolvedColors.h"

@implementation UIColor (RevolvedColors)

+ (UIColor *)rv_backgroundColor
{
    return [UIColor colorWithWhite:0.93 alpha:1.0];
}

+ (UIColor *)rv_tintColor
{
    return [UIColor colorWithWhite:0.72 alpha:1.0];
}

+ (UIColor *)rv_dimColor
{
    return [UIColor colorWithWhite:0.12 alpha:0.85];
}

@end
