//
//  RVModel.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVModel.h"

@implementation RVModel

- (id)init
{
    self = [super init];
    if (self) {
        self.segments = [NSMutableOrderedSet new];
    }
    return self;
}

@end
