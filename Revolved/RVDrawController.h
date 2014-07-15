//
//  DrawController.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Color.h"

@class RVSegment, RVPoint, RVGuideline, RVControlPoint;
@protocol DrawControllerDelegate;

typedef NS_ENUM(NSInteger, DrawControllerState) {
    DrawControllerStateIdle,
    DrawControllerStateDrawing,
    DrawControllerStateSelection,
    DrawControllerStateDraggingPoint
};

@interface RVDrawController : NSObject

@property (nonatomic, weak) id<DrawControllerDelegate> delegate;
@property (nonatomic) DrawControllerState state;

@property (nonatomic, strong) NSMutableOrderedSet *segments;
@property (nonatomic, strong, readonly) RVSegment *selectedSegment;

@property (nonatomic) float rightEdge;
@property (nonatomic) float topEdge;
@property (nonatomic) float bottomEdge;

@property (nonatomic) float evadeSquareRadius;
@property (nonatomic) GLKVector2 topEvadeCenter;
@property (nonatomic) GLKVector2 bottomEvadeCenter;

@property (nonatomic) float snapDistanceSquared;
@property (nonatomic) float tapDistanceSquared;


- (void)handlePanBeginAtPosition:(GLKVector2)position firstTouchPosition:(GLKVector2)firstTouchPosition;
- (void)handlePanContinueAtPosition:(GLKVector2)position;
- (void)handlePanEndAtPosition:(GLKVector2)position;

- (void)handleTapAtPosition:(GLKVector2)position;

- (void)handleColorSelection:(NSUInteger)selectedColorIndex;


- (void)deleteSegment:(RVSegment *)segment;
- (void)clear;

@end


@protocol DrawControllerDelegate <NSObject>

- (void)drawControllerDidSelectSegment:(RVSegment *)segment;
- (void)drawControllerDidSelectEndPoint:(RVPoint *)endPoint;

- (void)drawControllerDidTryAddButReachedSegmentLimit;

- (void)drawControllerDidAddSegment:(RVSegment *)segment;
- (void)drawControllerDidModifySegment:(RVSegment *)segment;
- (void)drawControllerDidRecolorSegment:(RVSegment *)segment;
- (void)drawControllerDidRemoveSegment:(RVSegment *)segment;

- (void)drawControllerDidAddGuideLine:(RVGuideline *)guideline;
- (void)drawControllerDidRemoveGuideLine:(RVGuideline *)guideline;

- (void)drawControllerDidStartDraggingPoint:(RVPoint *)point;
- (void)drawControllerDidDragPoint:(RVPoint *)point;
- (void)drawControllerDidEndDraggingPoint:(RVPoint *)point;

- (void)drawControllerDidSelectColorIndex:(NSUInteger)colorIndex;

@end