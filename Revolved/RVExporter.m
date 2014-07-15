//
//  RVExporter.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.11.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVExporter.h"
#import "RVModel.h"

@implementation RVExporter

- (void)exportModel:(RVModel *)model toFileAtPath:(NSString *)path
{
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];

    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
    
    [self appendModel:model toHandle:handle];
    
    [handle closeFile];
}

- (void)appendModel:(RVModel *)model toHandle:(NSFileHandle *)handle
{
    
}

@end
