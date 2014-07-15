//
//  NSError+RevolvedErrors.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 01.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "NSError+RevolvedErrors.h"

static NSString * const ErrorDomain = @"com.bartoszciechanowski.revolved";

@implementation NSError (RevolvedErrors)

+ (NSError *)malformedFileError
{
    return [NSError errorWithDomain:ErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"The model you're trying to import seems to be malformed"}];
}

+ (NSError *)obsoleteAppVersionError
{
    return [NSError errorWithDomain:ErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"You need to update Revolved in the AppStore to import this model"}];
}

@end
