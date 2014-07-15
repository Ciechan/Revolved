//
//  RVFileManager.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 23.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVModelManager.h"
#import "RVModel.h"
#import "RVModelMetadata.h"
#import "RVModelSerializer.h"

#import "NSError+RevolvedErrors.h"
#import "NSArray+Functional.h"

#import "NSMutableArray+MoveObject.h"
#import "NSMutableOrderedSet+MoveObject.h"


static const NSInteger FileMajorVersion = 1;
static const NSInteger FileMinorVersion = 0;

static NSString * const MetadataModelsKey = @"models";

static NSString * const FileMajorVersionKey = @"major";
static NSString * const FileMinorVersionKey = @"minor";
static NSString * const FileModelKey = @"model";

@interface RVModelManager()

@property (nonatomic, strong) NSMutableOrderedSet *models;
@property (nonatomic, strong) NSMutableArray *modelMetadatas;

@end


@implementation RVModelManager

- (id)init
{
    self = [super init];
    if (self) {
        _models = [NSMutableOrderedSet orderedSet];
        [self loadMetadata];
        [self loadModels];
    }
    return self;
}

#pragma mark - Path Operations

- (NSString *)modelsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Models"];
    
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    return dataPath;
}

- (NSString *)metadataPath
{
    return [[self modelsPath] stringByAppendingPathComponent:@"meta.data"];
}


- (NSString *)pathForModelAtIndex:(NSUInteger)modelIndex
{
    NSString *fileName = [self.modelMetadatas[modelIndex] fileName];
    return [[self modelsPath] stringByAppendingPathComponent:fileName];
}

#pragma mark - Save/Load

- (void)loadMetadata
{
    NSData *data = [NSData dataWithContentsOfFile:[self metadataPath]];
    NSArray *metadatas;
    NSError *error;
    
    if (data) {
        NSDictionary *parsedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (parsedJSON) {
            metadatas =[parsedJSON[MetadataModelsKey] mapObjectsUsingBlock:^id(NSDictionary *json, NSUInteger idx) {
                return [RVModelMetadata modelMetadataFromJSON:json];
            }];
        }
    }
    
    self.modelMetadatas = [NSMutableArray arrayWithArray:metadatas];
}

- (void)saveMetadata
{
    NSError *error;
    
    NSArray *jsonedMetadatas = [self.modelMetadatas mapObjectsUsingBlock:^id(RVModelMetadata *metadata, NSUInteger idx) {
        return [metadata toJSON];
    }];
    
    NSDictionary *metadata = @{MetadataModelsKey : jsonedMetadatas ?: @[]};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:metadata options:0 error:&error];
    [data writeToFile:[self metadataPath] atomically:YES];
}



- (void)loadModels
{
    NSError *error;
    NSUInteger count = [self.modelMetadatas count];
    
    NSMutableIndexSet *invalidIndexes = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSData *jsonData = [NSData dataWithContentsOfFile:[self pathForModelAtIndex:i]];
        if (!jsonData) {
            [invalidIndexes addIndex:i];
            continue;
        }
        NSDictionary *modelDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (modelDictionary == nil) {
            [invalidIndexes addIndex:i];
            continue;
        }
        
        RVModel *model = [self modelWithDictionary:modelDictionary error:&error];
        if (! model) {
            [invalidIndexes addIndex:i];
            continue;
        }
        
        [self.models addObject:model];
    }
    
    if (invalidIndexes.count > 0) {
        NSLog(@"INVALID DATA!!!");
    }
    
    [self.modelMetadatas removeObjectsAtIndexes:invalidIndexes];
    
    NSAssert(self.models.count == [self.modelMetadatas count], @"Models array does not match metadata");
}


- (void)saveModel:(RVModel *)model
{
    NSError *error;
    NSUInteger modelIndex = [self.models indexOfObject:model];
    if (modelIndex == NSNotFound) {
        return;
    }
    
    NSDictionary *modelDictionary = [RVModelManager dictionaryForModel:model];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:modelDictionary options:0 error:&error];
    if (jsonData) {
        [jsonData writeToFile:[self pathForModelAtIndex:modelIndex] atomically:YES];
    } else {
        NSLog(@"Error serializing model - %@", error.localizedDescription);
    }
}

#pragma mark -

- (NSString *)newFileName
{
    NSInteger max = 0;
    
    for (RVModelMetadata *metadata in self.modelMetadatas) {
        max = MAX(max, [metadata.fileName integerValue]);
    }
    
    return [@(max + 1) stringValue];
}

- (void)addModelToDatabase:(RVModel *)model imported:(BOOL)imported
{
    RVModelMetadata *metadata = [RVModelMetadata new];
    metadata.fileName = [self newFileName];
    metadata.imported = imported;
    
    [self.modelMetadatas insertObject:metadata atIndex:0];
    [self saveMetadata];
    
    [self.models insertObject:model atIndex:0];
    [self saveModel:model];
}



#pragma mark -

- (NSUInteger)numberOfModels
{
    return self.models.count;
}


- (RVModel *)createNewModel
{
    RVModel *newModel = [[RVModel alloc] init];
    [self addModelToDatabase:newModel imported:NO];
    
    return newModel;
}

- (RVModel *)modelAtIndex:(NSUInteger)modelIndex
{
    return self.models[modelIndex];
}

- (void)moveModelAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)targetIndex
{
    [self.modelMetadatas moveObjectAtIndex:sourceIndex toIndex:targetIndex];
    [self.models moveObjectAtIndex:sourceIndex toIndex:targetIndex];
    
    [self saveMetadata];
}

- (void)deleteModelAtIndex:(NSUInteger)modelIndex
{
    NSAssert(modelIndex < self.models.count, @"Model index of out range");

    NSString *path = [self pathForModelAtIndex:modelIndex];
    
    NSError *error;
    [self.modelMetadatas removeObjectAtIndex:modelIndex];
    [self.models removeObjectAtIndex:modelIndex];
    
    if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        NSLog(@"Error deleting model");
    }
    
    [self saveMetadata];
}

- (void)cloneModelAtIndex:(NSUInteger)modelIndex
{
    NSError *error;
    RVModel *sourceModel = self.models[modelIndex];
    NSDictionary *sourceDictionary = [RVModelManager  dictionaryForModel:sourceModel];
    RVModel *copiedModel = [self modelWithDictionary:sourceDictionary error:&error];
    
    
    RVModelMetadata *metadata = [RVModelMetadata new];
    metadata.fileName = [self newFileName];
    
    [self.modelMetadatas insertObject:metadata atIndex:modelIndex + 1];
    [self.models insertObject:copiedModel atIndex:modelIndex + 1];

    [self saveModel:copiedModel];
    [self saveMetadata];
}

#pragma mark - Import/Export

- (BOOL)importModelData:(NSData *)data error:(NSError **)error
{
    NSError *parseError;
    NSDictionary *documentDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (!documentDict) {
        *error = [NSError malformedFileError];
        return NO;
    }
    
    
    RVModel *model = [self modelWithDictionary:documentDict error:&parseError];
    if (!model) {
        *error = parseError;
        return NO;
    }
    
    [self addModelToDatabase:model imported:YES];
    
    return YES;
}

+ (NSData *)exportDataForModel:(RVModel *)model
{
    
    NSError *error;
    NSDictionary *modelDictionary = [RVModelManager dictionaryForModel:model];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:modelDictionary options:0 error:&error];
    
    return jsonData;
}

#pragma mark - Model Serialization

+ (NSDictionary *)dictionaryForModel:(RVModel *)model
{
    NSDictionary *jsonModel = [RVModelSerializer JSONModelDictionaryFromSegments:model.segments.set];
    
    return @{FileMajorVersionKey : @(FileMajorVersion),
             FileMinorVersionKey : @(FileMinorVersion),
             FileModelKey : jsonModel};

}

- (RVModel *)modelWithDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    if ([dictionary[FileMajorVersionKey] integerValue] > FileMajorVersion) {
        if (error) {
            *error = [NSError obsoleteAppVersionError];
        }
        
        return nil;
    }
    
    NSError *parseError = nil;
    NSSet *segments = [RVModelSerializer segmentsFromJSONModelDictionary:dictionary[FileModelKey] error:&parseError];
    
    if (!segments) {
        *error = parseError;
        return nil;
    }
    
    RVModel *model = [[RVModel alloc] init];
    model.segments = [NSMutableOrderedSet orderedSetWithSet:segments];
    
    return model;
}


@end
