//
//  RVModelSerializer.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVModelSerializer : NSObject

+ (NSSet *)segmentsFromJSONModelDictionary:(NSDictionary *)dictionary error:(NSError **)error;
+ (NSDictionary *)JSONModelDictionaryFromSegments:(NSSet *)segments;

@end
