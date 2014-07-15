//
//  NSMapTable+BlockEnumeration.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 25.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMapTable (BlockEnumeration)

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;

@end
