//
//  NSError+RevolvedErrors.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 01.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (RevolvedErrors)

+ (NSError *)malformedFileError;
+ (NSError *)obsoleteAppVersionError;

@end
