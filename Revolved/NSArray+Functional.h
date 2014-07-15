//
//  NSArray+Functional.h
//  Ico
//
//  Created by Bartosz Ciechanowski on 21.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Functional)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
- (NSArray *)filterObjectsUsingBlock:(BOOL (^)(id obj, NSUInteger idx))block;

@end
