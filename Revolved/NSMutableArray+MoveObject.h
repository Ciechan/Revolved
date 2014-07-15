//
//  NSMutableArray+MoveObject.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 15.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MoveObject)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
