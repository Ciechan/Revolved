//
//  RVModelViewController.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVModelViewController, RVModel, RVModelSprite, RVRenderingController;

@protocol RVModelViewControllerDelegate <NSObject>

- (void)modelViewControllerDidRequestBack:(RVModelViewController *)controller;

- (void)modelViewControllerDidRequestSharePicture:(RVModelViewController *)controller;
- (void)modelViewControllerDidAnimateOut:(RVModelViewController *)controller;
- (void)modelViewControllerDidAnimateIn:(RVModelViewController *)controller;
- (void)modelViewController:(RVModelViewController *)controller didChangeModel:(RVModel *)model;
@end



@interface RVModelViewController : UIViewController

@property (nonatomic, weak) id<RVModelViewControllerDelegate> delegate;
@property (nonatomic, strong) RVRenderingController *renderingController;
@property (nonatomic) CGFloat previewWidth;

@property (nonatomic, readonly) CGRect previewFrame;
@property (nonatomic, readonly) CGRect drawFrame;
@property (nonatomic, readonly) GLKMatrix4 drawMatrix;


- (void)setupModel:(RVModel *)model;

- (void)tick;

- (void)animateIn;
- (void)animateOut;

- (void)presentShareOptionsWithImage:(UIImage *)image;

@end
