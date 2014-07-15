//
//  RVExporter.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.11.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RVModel;
@interface RVExporter : NSObject

- (void)exportModel:(RVModel *)model toFileAtPath:(NSString *)path;
- (void)appendModel:(RVModel *)model toHandle:(NSFileHandle *)handle;


@end
