//
//  NSMapTable+BlockEnumeration.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 25.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "NSMapTable+BlockEnumeration.h"

@implementation NSMapTable (BlockEnumeration)

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    BOOL stop = NO;
    for (id key in self) {
        block(key, [self objectForKey:key], &stop);
        if (stop) {
            return;
        }
    }
}

@end
