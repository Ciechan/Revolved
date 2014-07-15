//
//  RVModelMetadata.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 01.09.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVModelMetadata.h"

static NSString * const FileNameKey = @"fileName";
static NSString * const ImportedKey = @"imported";

@implementation RVModelMetadata

+ (RVModelMetadata *)modelMetadataFromJSON:(NSDictionary *)json
{
    RVModelMetadata *metadata = [RVModelMetadata new];
    metadata.fileName = json[FileNameKey];
    metadata.imported = [json[ImportedKey] boolValue];
    
    return metadata;
}

- (NSDictionary *)toJSON
{
    return @{FileNameKey : self.fileName ?: @"",
             ImportedKey : @(self.imported)};
}

@end
