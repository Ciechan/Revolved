//
//  RVModelsViewController.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 20.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVModelsViewController, RVModelSprite, RVRenderingController, RVModel;

@protocol RVModelsViewControllerDataSource <NSObject>

- (NSUInteger)modelsViewControllerNumberOfModels:(RVModelsViewController *)controller;
- (RVModel *)modelsViewController:(RVModelsViewController *)controller modelAtIndex:(NSUInteger)modelIndex;
- (CGRect)modelsViewControllerDestinationRectForSelectedModel:(RVModelsViewController *)controller;

@end



@protocol RVModelsViewControllerDelegate <NSObject>

- (void)modelsViewControllerDidAddModel:(RVModelsViewController *)controller;
- (void)modelsViewController:(RVModelsViewController *)controller didSelectModelAtIndex:(NSUInteger)modelIndex;
- (void)modelsViewController:(RVModelsViewController *)controller didDeleteModelAtIndex:(NSUInteger)modelIndex;
- (void)modelsViewController:(RVModelsViewController *)controller didCloneModelAtIndex:(NSUInteger)modelIndex;
- (void)modelsViewController:(RVModelsViewController *)controller didShareModelAtIndex:(NSUInteger)modelIndex;

- (void)modelsViewController:(RVModelsViewController *)controller didMoveModelAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)targetIndex;

- (void)modelsViewController:(RVModelsViewController *)controller didZoomInToModelAtIndex:(NSUInteger)modelIndex;

- (void)modelsViewControllerDidRequestTutorial:(RVModelsViewController *)controller;
- (void)modelsViewControllerDidZoomOut:(RVModelsViewController *)controller;

@end


@interface RVModelsViewController : UIViewController

@property (nonatomic, weak) id<RVModelsViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<RVModelsViewControllerDelegate> delegate;
@property (nonatomic, strong) RVRenderingController *renderingController;
@property (nonatomic) CGSize previewSize;

- (void)zoomOut;

- (void)reloadData;
- (void)addNewModelSpriteForModelAtIndex:(NSInteger)modelIndex;
- (void)importModelSpriteForModelAtIndex:(NSInteger)modelIndex;
- (void)removeModelSpriteForModel:(RVModel *)model;

- (void)tick;

@end
