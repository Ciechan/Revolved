//
//  DrawViewController.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 07.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVDrawController, RVLineMeshController, RVSpaceConverter, RVPointMeshController, RVGuidlineDotMeshController, RVColorPicker, RVSegment, RVGuideline;

@interface RVDrawViewController : UIViewController

@property (nonatomic, strong) RVDrawController *drawController;
@property (nonatomic, strong) RVSpaceConverter *converter;

@property (nonatomic, strong, readonly) NSArray *axisSprites;
@property (nonatomic, strong, readonly) NSArray *lineSprites;
@property (nonatomic, strong, readonly) NSArray *guidelineSprites;
@property (nonatomic, strong, readonly) NSArray *pointSprites;


- (void)addIntitialLineSpritesForSegments:(NSSet *)segments;

- (void)addLineSpriteForSegment:(RVSegment *)segment;
- (void)modifyLineSpriteForSegment:(RVSegment *)segment;
- (void)removeLineSpriteForSegment:(RVSegment *)segment;

- (void)addSpritesForGuideLine:(RVGuideline *)guideline;
- (void)removeSpritesForGuideLine:(RVGuideline *)guideline;

- (void)addPointSpritesForPoints:(NSSet *)points;
- (void)modifyPointSpritesForPoints:(NSSet *)points;
- (void)dropPointSpritesForPoints:(NSSet *)points;
- (void)removeAllPointSprites;


- (void)setSelectedColorIndex:(NSUInteger)colorIndex;
- (void)selectLineSpriteForSegment:(RVSegment *)segment;


- (void)clearAllSprites;

- (void)animateInWithDuration:(NSTimeInterval)duration;
- (void)animateOutWithDuration:(NSTimeInterval)duration;

@end
