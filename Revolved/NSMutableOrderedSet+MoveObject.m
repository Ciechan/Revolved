//
//  NSMutableOrderedSet+MoveObject.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 15.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "NSMutableOrderedSet+MoveObject.h"

@implementation NSMutableOrderedSet (MoveObject)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    id object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}

@end
