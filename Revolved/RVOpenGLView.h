//
//  RVOpenGLView.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 21.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 I'm not using GLKView because its -snapshot method is slow and there are faster
 means of obtaining the image.
 */

@interface RVOpenGLView : UIView

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, readonly) GLint drawableWidth;
@property (nonatomic, readonly) GLint drawableHeight;

- (void)presentWithRenderingBlock:(void (^)(void))renderingBlock;
- (UIImage *)snapshotWithRenderingBlock:(void (^)(void))renderingBlock;

@end
