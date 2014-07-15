//
//  DrawViewController.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 07.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVDrawViewController.h"

#import "RVDrawController.h"
#import "RVSpaceConverter.h"

#import "RVModelMeshController.h"
#import "RVLineMeshController.h"
#import "RVGuidlineDotMeshController.h"
#import "RVPointMeshController.h"

#import "RVColorPicker.h"
#import "RVColorProvider.h"

#import "DrawGestureRecognizer.h"
#import "Geometry.h"
#import "RVPoint.h"
#import "RVSegment.h"
#import "RVGuideline.h"

#import "RVLineSprite.h"
#import "RVPointSprite.h"
#import "RVGuidelineDotSprite.h"

#import "RVVectorAnimation.h"
#import "RVFloatAnimation.h"

#import "NSMapTable+BlockEnumeration.h"

static const float SnapDistance = 17.0f;
static const float TapDistance = 26.0f;


@interface RVDrawViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) DrawGestureRecognizer *drawRecgonizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet RVColorPicker *colorPicker;

@property (nonatomic, strong) NSArray *axisLineSprites;

@property (nonatomic, strong) NSMapTable *segmentToLineSpriteMap;
@property (nonatomic, strong) NSMapTable *guidelineToLineSpriteArrayMap;
@property (nonatomic, strong) NSMapTable *pointToPointSpriteMap;

@end

@implementation RVDrawViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _segmentToLineSpriteMap = [NSMapTable strongToStrongObjectsMapTable];
        _guidelineToLineSpriteArrayMap = [NSMapTable strongToStrongObjectsMapTable];
        _pointToPointSpriteMap = [NSMapTable strongToStrongObjectsMapTable];
        
        [self createAxisLineSprites];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.drawRecgonizer = [[DrawGestureRecognizer alloc] initWithTarget:self action:@selector(draw:)];
    self.drawRecgonizer.cancelsTouchesInView = NO;
    self.drawRecgonizer.delegate = self;
    [self.view addGestureRecognizer:self.drawRecgonizer];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.tapRecognizer.cancelsTouchesInView = NO;
    self.tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)setConverter:(RVSpaceConverter *)converter {
    
    const CGFloat DraggerRadius = 26.0f;

    _converter = converter;
    
    self.drawController.snapDistanceSquared = [converter modelSquareDistanceForViewDistance:SnapDistance];
    self.drawController.tapDistanceSquared = [converter modelSquareDistanceForViewDistance:TapDistance];

    CGSize size = self.view.bounds.size;
    
    self.drawController.topEdge = [converter modelPointForViewPoint:CGPointMake(0.0, DraggerRadius)].y;
    self.drawController.rightEdge = [converter modelPointForViewPoint:CGPointMake(size.width - DraggerRadius, 0.0)].x;
    self.drawController.bottomEdge = [converter modelPointForViewPoint:CGPointMake(0.0, size.height - DraggerRadius)].y;

    CGFloat xCenter = self.deleteButton.center.x;
    
    self.drawController.evadeSquareRadius = [converter modelSquareDistanceForViewDistance:90.0f];
    self.drawController.bottomEvadeCenter = [converter modelPointForViewPoint:CGPointMake(xCenter, size.height)];
    self.drawController.topEvadeCenter = [converter modelPointForViewPoint:CGPointMake(xCenter, 0.0f)];
    
    [self resizeAxisLineSprites];
}

- (NSArray *)lineSprites
{
    NSMutableArray *allSprites = [NSMutableArray array];
    [allSprites addObjectsFromArray:self.axisLineSprites];

    
    NSMutableArray *validLineSprites = [NSMutableArray array];
    NSMutableSet *allLineSprite = [NSMutableSet setWithArray:self.segmentToLineSpriteMap.objectEnumerator.allObjects];
    
    for (RVSegment *segment in self.drawController.segments) {
        RVLineSprite *sprite = [self.segmentToLineSpriteMap objectForKey:segment];
        [validLineSprites addObject:sprite];
        [allLineSprite removeObject:sprite];
    }

    [allSprites addObjectsFromArray:allLineSprite.allObjects];
    [allSprites addObjectsFromArray:validLineSprites];
    
    return allSprites;
}

- (NSArray *)guidelineSprites
{
    NSMutableArray *allSprites = [NSMutableArray array];

    for (NSArray *guidelineArray in self.guidelineToLineSpriteArrayMap.objectEnumerator.allObjects) {
        [allSprites addObjectsFromArray:guidelineArray];
    }
    
    return allSprites;
}

- (NSArray *)axisSprites
{
    return self.axisLineSprites;
}



#pragma mark - UI Events


- (void)draw:(DrawGestureRecognizer *)sender
{
    GLKVector2 position = [self.converter modelPointForViewPoint:[sender locationInView:sender.view]];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self.drawController handlePanBeginAtPosition:position
                                       firstTouchPosition:[self.converter modelPointForViewPoint:[sender firstTouchLocationInView:sender.view]]];
            /* FALL THROUGH */
        case UIGestureRecognizerStateChanged:
            [self.drawController handlePanContinueAtPosition:position];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self.drawController handlePanEndAtPosition:position];
            break;
            
        default:
            break;
    }
}

- (void)setSelectedColorIndex:(NSUInteger)colorIndex
{
    [self.colorPicker setSelectedColorIndex:colorIndex animated:YES];
}


- (IBAction)tap:(UITapGestureRecognizer *)sender
{
    GLKVector2 point = [self.converter modelPointForViewPoint:[sender locationInView:sender.view]];
    
    [self.drawController handleTapAtPosition:point];
}

- (IBAction)deleteButtonTapped:(UIButton *)sender
{
    [self.drawController deleteSegment:self.drawController.selectedSegment];
}

- (IBAction)colorPickerChangedColor:(RVColorPicker *)sender
{
    [self.drawController handleColorSelection:sender.selectedColorIndex];
}

#pragma mark - In/Out animation

- (void)animateInWithDuration:(NSTimeInterval)duration
{
    self.deleteButton.alpha = 0.0f;
    self.colorPicker.alpha = 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        self.deleteButton.alpha = 1.0f;
        self.colorPicker.alpha = 1.0f;
    }];
    
    [self.segmentToLineSpriteMap enumerateKeysAndObjectsUsingBlock:^(RVSegment *segment, RVLineSprite *lineSprite, BOOL *stop) {
        
        RVVectorAnimation *colorAnimation = [RVVectorAnimation vectorAnimationFromValue:lineSprite.color toValue:[RVColorProvider vectorForColorIndex:segment.colorIndex] withDuration:duration];
        RVFloatAnimation *widthAnimation = [RVFloatAnimation floatAnimationFromValue:lineSprite.widthMultiplier toValue:1.0 withDuration:duration];
        
        [lineSprite addAnimation:colorAnimation forKey:@"color"];
        [lineSprite addAnimation:widthAnimation forKey:@"widthMultiplier"];
    }];
    
    
    
    NSUInteger axisSegmentsCount = self.axisLineSprites.count;
    GLKVector3 backgroundColor = [RVColorProvider vectorForBackgroundColor];
    GLKVector3 axisColor = [RVColorProvider vectorForAxisColor];
    
    [self.axisLineSprites enumerateObjectsUsingBlock:^(RVLineSprite *axisSprite, NSUInteger i, BOOL *stop) {
        float t = i / (axisSegmentsCount - 1.0f);
        
        float value = MIN(1.0f, 30.0 * sinf(t*M_PI) * sinf(t*M_PI) + 0.05);
        GLKVector3 finalColor = GLKVector3Add(GLKVector3MultiplyScalar(axisColor, value),
                                              GLKVector3MultiplyScalar(backgroundColor, 1.0 - value));
        
        RVVectorAnimation *colorAnimation = [RVVectorAnimation vectorAnimationFromValue:backgroundColor toValue:finalColor withDuration:duration];
        [axisSprite addAnimation:colorAnimation forKey:@"color"];
    }];
    

}

- (void)animateOutWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.deleteButton.alpha = 0.0f;
        self.colorPicker.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.colorPicker collapseAnimated:NO];
    }];
    
    for (RVLineSprite *lineSprite in self.segmentToLineSpriteMap.objectEnumerator.allObjects) {
        RVVectorAnimation *colorAnimation = [RVVectorAnimation vectorAnimationFromValue:lineSprite.color toValue:[RVColorProvider vectorForBackgroundColor] withDuration:duration];
        RVFloatAnimation *widthAnimation = [RVFloatAnimation floatAnimationFromValue:lineSprite.widthMultiplier toValue:0.0 withDuration:duration];
        
        [lineSprite addAnimation:colorAnimation forKey:@"color"];
        [lineSprite addAnimation:widthAnimation forKey:@"widthMultiplier"];
    }
    GLKVector3 backgroundColor = [RVColorProvider vectorForBackgroundColor];

    for (RVLineSprite *axisSprite in self.axisLineSprites) {
        RVVectorAnimation *colorAnimation = [RVVectorAnimation vectorAnimationFromValue:axisSprite.color toValue:backgroundColor withDuration:duration];
        [axisSprite addAnimation:colorAnimation forKey:@"color"];
    }
    
    for (RVPointSprite *pointSprite in self.pointToPointSpriteMap.objectEnumerator.allObjects) {
        RVFloatAnimation *alphaAnimation = [RVFloatAnimation floatAnimationFromValue:pointSprite.alpha toValue:0.0f withDuration:duration];
        [pointSprite addAnimation:alphaAnimation forKey:@"alpha"];
    }
}

#pragma mark - UIGestureRecognizerDelegate


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.colorPicker.expanded) {
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if (gestureRecognizer == self.tapRecognizer && [touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }

    
    return YES;
}

#pragma mark - Line Sprites

- (void)mapNewTesselationDataToSprite:(RVLineSprite *)lineSprite withSegment:(RVSegment *)segment
{
    lineSprite.tesselator = segment.tesselator;
    lineSprite.tesselationSegments = segment.lineTesselationSegments;
}


- (void)addIntitialLineSpritesForSegments:(NSSet *)segments
{
    for (RVSegment *segment in segments) {
        RVLineSprite *lineSprite = [[RVLineSprite alloc] init];
        lineSprite.color = [RVColorProvider vectorForBackgroundColor];
        lineSprite.widthMultiplier = 0.0f;
        
        [self.segmentToLineSpriteMap setObject:lineSprite forKey:segment];
        [self mapNewTesselationDataToSprite:lineSprite withSegment:segment];
    }
}

- (void)addLineSpriteForSegment:(RVSegment *)segment
{
    RVLineSprite *lineSprite = [[RVLineSprite alloc] init];
    lineSprite.color = [RVColorProvider vectorForColorIndex:segment.colorIndex];
    lineSprite.widthMultiplier = 1.0f;
    
    [self.segmentToLineSpriteMap setObject:lineSprite forKey:segment];
    [self mapNewTesselationDataToSprite:lineSprite withSegment:segment];
}



- (void)modifyLineSpriteForSegment:(RVSegment *)segment
{
    RVLineSprite *lineSprite = [self.segmentToLineSpriteMap objectForKey:segment];
    lineSprite.color = [RVColorProvider vectorForColorIndex:segment.colorIndex];
    [self mapNewTesselationDataToSprite:lineSprite withSegment:segment];
}

- (void)removeLineSpriteForSegment:(RVSegment *)segment
{
    RVLineSprite *lineSprite = [self.segmentToLineSpriteMap objectForKey:segment];
    
    RVFloatAnimation *burnoutAnimation = [RVFloatAnimation new];
    burnoutAnimation.from = 0.0f;
    burnoutAnimation.to = 1.0f;
    burnoutAnimation.duration = 0.3f;
    //burnoutAnimation.animationCurve = RVAnimationCurveEaseIn;
    burnoutAnimation.completionBlock = ^{[self.segmentToLineSpriteMap removeObjectForKey:segment];};
    
    //RVFloatAnimation *lineAnimation = [self lineWidthAnimationFromWidth:1.0 toWidth:0.7];
    
    [lineSprite addAnimation:burnoutAnimation forKey:@"burnout"];
    //[lineSprite addAnimation:lineAnimation forKey:@"widthMultiplier"];
}

- (void)selectLineSpriteForSegment:(RVSegment *)segment
{
    const NSTimeInterval Duration = 0.16;
    if (segment) {
        self.deleteButton.enabled = YES;
        
        [self.segmentToLineSpriteMap enumerateKeysAndObjectsUsingBlock:^(RVSegment *segment, RVLineSprite *lineSprite, BOOL *stop) {
            
            RVVectorAnimation *colorAnimation = [RVVectorAnimation vectorAnimationFromValue:lineSprite.color toValue:[RVColorProvider vectorForDesaturatedColorIndex:segment.colorIndex] withDuration:Duration];
            RVFloatAnimation *widthAnimation = [RVFloatAnimation floatAnimationFromValue:lineSprite.widthMultiplier toValue:0.8 withDuration:Duration];
            
            [lineSprite addAnimation:colorAnimation forKey:@"color"];
            [lineSprite addAnimation:widthAnimation forKey:@"widthMultiplier"];
        }];
        
        RVLineSprite *selectedLineSprite = [self.segmentToLineSpriteMap objectForKey:segment];
        RVVectorAnimation *colorAnimation = [RVVectorAnimation vectorAnimationFromValue:selectedLineSprite.color toValue:[RVColorProvider vectorForColorIndex:segment.colorIndex] withDuration:Duration];
        RVFloatAnimation *widthAnimation = [RVFloatAnimation floatAnimationFromValue:selectedLineSprite.widthMultiplier toValue:1.1 withDuration:Duration];
        
        [selectedLineSprite addAnimation:colorAnimation forKey:@"color"];
        [selectedLineSprite addAnimation:widthAnimation forKey:@"widthMultiplier"];
        
    } else {
        self.deleteButton.enabled = NO;

        [self.segmentToLineSpriteMap enumerateKeysAndObjectsUsingBlock:^(RVSegment *segment, RVLineSprite *lineSprite, BOOL *stop) {
            RVVectorAnimation *colorAnimation = [RVVectorAnimation vectorAnimationFromValue:lineSprite.color toValue:[RVColorProvider vectorForColorIndex:segment.colorIndex] withDuration:Duration];
            RVFloatAnimation *widthAnimation = [RVFloatAnimation floatAnimationFromValue:lineSprite.widthMultiplier toValue:1.0 withDuration:Duration];
            
            [lineSprite addAnimation:colorAnimation forKey:@"color"];
            [lineSprite addAnimation:widthAnimation forKey:@"widthMultiplier"];
        }];
    }
}

- (void)clearAllSprites
{
    [self.segmentToLineSpriteMap removeAllObjects];
    [self.pointToPointSpriteMap removeAllObjects];
}

#pragma mark - Guideline Sprites

- (void)addSpritesForGuideLine:(RVGuideline *)guideline
{
    const NSTimeInterval AppearDuration = 0.15;
    const NSTimeInterval AppearStepMaxDelay = 0.01;
    const NSTimeInterval AppearStepMaxDiff  = 0.006;

    float dotDistance = sqrtf(self.drawController.snapDistanceSquared/4.0);
    NSInteger dotCount = guideline.length/dotDistance;
    
    if (dotCount == 0) {
        return;
    }
    
    
    GLKVector2 start = guideline.start;
    GLKVector2 direction = guideline.direction;
    
    NSMutableArray *dots = [NSMutableArray arrayWithCapacity:dotCount];
    
    float p = 1.0f/(dotCount - 1);
    
    NSTimeInterval delay = 0.0;
    for (int i = 0; i < dotCount; i++) {
        RVGuidelineDotSprite *sprite = [RVGuidelineDotSprite new];
        sprite.position = GLKVector2Add(start, GLKVector2MultiplyScalar(direction, i * dotDistance));
        sprite.alpha = 1.0f;
        
        RVFloatAnimation *scaleAnimation = [RVFloatAnimation floatAnimationFromValue:0.0f toValue:1.0f withDuration:AppearDuration];
        scaleAnimation.delay = delay;
        scaleAnimation.animationCurve = RVAnimationCurveEaseOut;
        [sprite addAnimation:scaleAnimation forKey:@"scale"];
        [dots addObject:sprite];
        
        delay += AppearStepMaxDelay - (i * p) * (i * p) * AppearStepMaxDiff;
    }
    
    if (dotCount == 2) {
        [(RVPointSprite *)[dots lastObject] setAlpha:0.5f];
    } else if (dotCount > 2) {
        [(RVPointSprite *)dots[dotCount - 1] setAlpha:0.33f];
        [(RVPointSprite *)dots[dotCount - 2] setAlpha:0.66f];
    }
    
    [self.guidelineToLineSpriteArrayMap setObject:dots forKey:guideline];
}

- (void)removeSpritesForGuideLine:(RVGuideline *)guideline
{
    const NSTimeInterval DisappearDuration = 0.15;

    NSArray *dots = [self.guidelineToLineSpriteArrayMap objectForKey:guideline];
    NSUInteger count = dots.count;
    

    
    [dots enumerateObjectsUsingBlock:^(RVGuidelineDotSprite *dot, NSUInteger idx, BOOL *stop) {
        RVFloatAnimation *alphaAnimation = [RVFloatAnimation floatAnimationFromValue:dot.alpha toValue:0.0f withDuration:DisappearDuration];
        alphaAnimation.animationCurve = RVAnimationCurveEaseOut;
        [dot addAnimation:alphaAnimation forKey:@"alpha"];
        if (idx == count - 1) {
            alphaAnimation.completionBlock = ^{[self.guidelineToLineSpriteArrayMap removeObjectForKey:guideline];};
        }
    }];
}

#pragma mark - Point Sprites


- (void)mapNewPointPositionDataToSprite:(RVPointSprite *)pointSprite withPoint:(RVPoint *)point
{
    pointSprite.position = point.position;
}

- (NSArray *)pointSprites
{
    return self.pointToPointSpriteMap.objectEnumerator.allObjects;
}

- (void)addPointSpritesForPoints:(NSSet *)points
{
    for (RVPoint *point in points) {
        RVPointSprite *pointSprite = [RVPointSprite new];
        
        pointSprite.segmentEnd = point.segmentEnd;
        pointSprite.type = point.type;
        
        [self.pointToPointSpriteMap setObject:pointSprite forKey:point];
        [self mapNewPointPositionDataToSprite:pointSprite withPoint:point];
        
        RVFloatAnimation *alphaAnimation = [RVFloatAnimation floatAnimationFromValue:0.3 toValue:1.0 withDuration:0.18];
        alphaAnimation.animationCurve = RVAnimationCurveQuartEaseOut;
        
        RVFloatAnimation *scaleAnimation = [RVFloatAnimation floatAnimationFromValue:0.0 toValue:1.0 withDuration:0.18];
        scaleAnimation.animationCurve = RVAnimationCurveQuartEaseOut;
        
        [pointSprite addAnimation:alphaAnimation forKey:@"alpha"];
        [pointSprite addAnimation:scaleAnimation forKey:@"scale"];
    }
}

- (void)modifyPointSpritesForPoints:(NSSet *)points
{
    for (RVPoint *point in points) {
        RVPointSprite *pointSprite = [self.pointToPointSpriteMap objectForKey:point];
        [self mapNewPointPositionDataToSprite:pointSprite withPoint:point];
    }
}

- (void)dropPointSpritesForPoints:(NSSet *)points
{
    const NSTimeInterval Duration = 0.6;
    const NSTimeInterval DelayVariation = 0.12;
    
    for (RVPoint *point in points) {
        RVPointSprite *pointSprite = [self.pointToPointSpriteMap objectForKey:point];
        [pointSprite removeAnimationForKey:@"scale"];
        
        RVFloatAnimation *alphaAnimation = (RVFloatAnimation *)[pointSprite animationForKey:@"alpha"];
        alphaAnimation.duration = Duration + DelayVariation;
        alphaAnimation.to = 0.8f;
        
        GLKVector3 startTranslation = pointSprite.extraTranslationVector;
        GLKVector3 endTranslation = startTranslation;
        endTranslation.y -= 4.0f;
        RVVectorAnimation *translationAnimation = [RVVectorAnimation vectorAnimationFromValue:startTranslation
                                                                                      toValue:endTranslation
                                                                                 withDuration:Duration];
        translationAnimation.animationCurve = RVAnimationCurveJumpEaseIn;
        translationAnimation.delay = drand48() * DelayVariation;
        [pointSprite addAnimation:translationAnimation forKey:@"extraTranslationVector"];
        
    }
}

- (void)removeAllPointSprites
{
    for (RVPoint *point in self.pointToPointSpriteMap.keyEnumerator.allObjects) {
        
        RVPointSprite *pointSprite = [self.pointToPointSpriteMap objectForKey:point];
        
        RVFloatAnimation *alphaAnimation = [RVFloatAnimation floatAnimationFromValue:1.0 toValue:0.3 withDuration:0.12];
        alphaAnimation.animationCurve = RVAnimationCurveEaseOut;
        alphaAnimation.completionBlock = ^{[self.pointToPointSpriteMap removeObjectForKey:point];};

        RVFloatAnimation *scaleAnimation = [RVFloatAnimation floatAnimationFromValue:1.0 toValue:0.0 withDuration:0.12];
        scaleAnimation.animationCurve = RVAnimationCurveEaseOut;

        
        [pointSprite addAnimation:alphaAnimation forKey:@"alpha"];
        [pointSprite addAnimation:scaleAnimation forKey:@"scale"];
    }
}

#pragma mark - Axis Line Sprites

- (void)createAxisLineSprites
{
    const NSUInteger AxisSegmentsCount = 50;
    GLKVector3 backgroundColor = [RVColorProvider vectorForBackgroundColor];

    NSMutableArray *axisSprites = [NSMutableArray array];
    for (int i = 0; i <AxisSegmentsCount; i++) {
        RVLineSprite *sprite = [RVLineSprite new];
        sprite.widthMultiplier = 0.5f;
        sprite.tesselationSegments = 1;
        sprite.color = backgroundColor;
        [axisSprites addObject:sprite];
    }
    
    self.axisLineSprites = axisSprites;
}

- (void)resizeAxisLineSprites
{
    const float SegmentToSpaceRatio = 1.0;
    
    NSUInteger count = self.axisLineSprites.count;
    
    float bottomEdge = self.drawController.bottomEdge;
    float totalSpan = self.drawController.topEdge - self.drawController.bottomEdge;

    float spaceSpan = totalSpan/(SegmentToSpaceRatio * count + count - 1);
    float segmentSpan = spaceSpan * SegmentToSpaceRatio;
    float midSegmentSpan = spaceSpan + segmentSpan;
    
    [self.axisLineSprites enumerateObjectsUsingBlock:^(RVLineSprite *lineSprite, NSUInteger idx, BOOL *stop) {
        
        GLKVector2 a = GLKVector2Make(0.0f, midSegmentSpan * idx + bottomEdge);
        GLKVector2 b = GLKVector2Make(0.0f, midSegmentSpan * idx + segmentSpan + bottomEdge);
        
        lineSprite.tesselator = ^(float t){
            float nt = 1.0f - t;
            
            SegmentTesselation tess;
            tess.p = GLKVector2Make(a.x * nt + b.x * t, a.y * nt + b.y * t);
            tess.n = GLKVector2Normalize(GLKVector2Make(a.y - b.y, -a.x + b.x));
            
            return tess;
        };
    }];
}


@end
