//
//  RVModelManager.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RVModel;
@interface RVModelManager : NSObject

- (void)loadModels;
- (NSUInteger)numberOfModels;

- (RVModel *)createNewModel;
- (void)saveModel:(RVModel *)model;

- (RVModel *)modelAtIndex:(NSUInteger)modelIndex;
- (void)moveModelAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)targetIndex;
- (void)cloneModelAtIndex:(NSUInteger)modelIndex;
- (void)deleteModelAtIndex:(NSUInteger)modelIndex;

- (BOOL)importModelData:(NSData *)data error:(NSError **)error;

+ (NSData *)exportDataForModel:(RVModel *)model;

@end
