//
//  RVModelMetadata.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 01.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVModelMetadata : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic) BOOL imported;

+ (RVModelMetadata *)modelMetadataFromJSON:(NSDictionary *)json;
- (NSDictionary *)toJSON;

@end
