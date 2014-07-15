//
//  CameraController.m
//  Patterns
//
//  Created by Bartosz Ciechanowski on 23.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "CameraController.h"
#import "Camera.h"

#import "RVQuaternionAnimation.h"
#import "RVAnimator.h"

static const float DeaccelerationFactor = 0.96;

static const float ThresholdScreenPanVelocity = 100.0f;
static const float ThresholdScreenRotationVelocity = 1.0f;

static const float RotationVelocityToAngularScale = 0.01f;
static const float PanVelocityToAngularScale = 0.00007f;


static const GLKQuaternion IdentityQuaternion = {0.0f, 0.0f, 0.0f, 1.0f};

typedef NS_ENUM(NSInteger, CameraControllerState) {
    CameraControllerStatePassive,
    CameraControllerStatePanning,
    CameraControllerStateRotating,
    CameraControllerStateInertia
};


@interface CameraController() <UIGestureRecognizerDelegate>

@property (nonatomic) CameraControllerState state;

@property (nonatomic) GLKQuaternion startQuaternion;
@property (nonatomic) GLKQuaternion panQuaternion;
@property (nonatomic) GLKQuaternion rotationQuaternion;

@property (nonatomic) GLKVector3 panStartPoint;
@property (nonatomic) NSUInteger previousNumberOfPanTouches;

@property (nonatomic) float currentRotation;
@property (nonatomic) float previousRotation;

@property (nonatomic) GLKVector3 inertiaAxis;
@property (nonatomic) float inertiaVelocity;
@property (nonatomic) float inertiaAngle;
@property (nonatomic) float extraSlowdownFactor;


@property (nonatomic) float panInertiaVelocity;
@property (nonatomic) GLKVector3 panInertiaAxis;
@property (nonatomic) float rotationInertiaVelocity;
@property (nonatomic) GLKVector3 rotationInertiaAxis;

@end

@implementation CameraController


- (id)init
{
    self = [super init];
    if (self)
    {
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        _panRecognizer.delegate = self;
        _panRecognizer.cancelsTouchesInView = NO;
        
        _rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        _rotationRecognizer.delegate = self;
        _rotationRecognizer.cancelsTouchesInView = NO;
        
        [self resetPosition];
        [self displayTick];
    }
    return self;
}


- (void)setState:(CameraControllerState)state
{
    if (state == _state) {
        return;
    }
    
    _state = state;
    
    if (state != CameraControllerStatePanning) {
        [self resetPanQuaternion];
    }
    
    if (state != CameraControllerStateRotating) {
        [self resetRotationQuaternion];
    }
}


- (void)resetPanQuaternion
{
    _startQuaternion = GLKQuaternionMultiply(_panQuaternion, _startQuaternion);
    _panQuaternion = GLKQuaternionIdentity;
}

- (void)resetRotationQuaternion
{
    _startQuaternion = GLKQuaternionMultiply(_rotationQuaternion, _startQuaternion);
    _rotationQuaternion = IdentityQuaternion;
    _previousRotation = _currentRotation;
}

#pragma mark - Gesture Recognizers

- (void)pan:(UIPanGestureRecognizer *)sender
{
    CGPoint viewPoint = [sender locationInView:sender.view];
    CGPoint viewVelocity = [sender velocityInView:sender.view];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self beginPanAtPoint:[self pointToSphere:viewPoint]];
            _previousNumberOfPanTouches = 1;
            break;
        case UIGestureRecognizerStateChanged:
            [self continuePanAtPoint:[self pointToSphere:viewPoint] withNumberOfTouches:sender.numberOfTouches];
            _previousNumberOfPanTouches = sender.numberOfTouches;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self endPanWithVelocity:[self angularVelocityForScreenVelocty:viewVelocity atScreenPoint:viewPoint]];
            break;
        default:
            break;
    }
    
}

- (void)rotate:(UIRotationGestureRecognizer *)sender
{
    CGFloat rotation = sender.rotation;
    CGFloat velocity = sender.velocity;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self beginRotation:rotation];
            break;
        case UIGestureRecognizerStateChanged:
            [self continueRotation:rotation withNumberOfTouches:sender.numberOfTouches];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self endRotation:rotation withVelocity:velocity];
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return touch.view == gestureRecognizer.view;
}


#pragma mark - Pan

- (void)beginPanAtPoint:(GLKVector3)point
{
    [self resetInertia];
    
    _panStartPoint = point;
    _panQuaternion = IdentityQuaternion;
    
    if (_state != CameraControllerStateRotating) {
        _state = CameraControllerStatePanning;
    }
}

- (void)continuePanAtPoint:(GLKVector3)point withNumberOfTouches:(NSUInteger)numberOfTouches
{
    if (numberOfTouches > 1 && _previousNumberOfPanTouches == 1) {
        [self resetRotationQuaternion];
    }
    
    if (numberOfTouches > 1) {
        return;
    }

    if (numberOfTouches == 1 && _previousNumberOfPanTouches > 1) {
        self.panStartPoint = point;
    }
    
    if (_state == CameraControllerStateRotating) {
        self.state = CameraControllerStatePanning;
        self.panStartPoint = point;
    }
    
    GLKVector3 panEndPoint = point;
    _panQuaternion = [self quaternionFromStartPoint:_panStartPoint toEndPoint:panEndPoint];
}


- (void)endPanWithVelocity:(GLKVector3)velocity
{
    float length = GLKVector3Length(velocity);
    
    _panInertiaAxis = GLKVector3MultiplyScalar(velocity, 1.0/length);
    _panInertiaVelocity = length;
    [self resolveInertia];
}

#pragma mark - Rotation

- (void)beginRotation:(CGFloat)rotation
{
    [self resetInertia];
    _previousRotation = 0.0f;
    
    if (_state == CameraControllerStatePassive) {
        self.state = CameraControllerStateRotating;
    }
    
}

- (void)continueRotation:(CGFloat)rotation withNumberOfTouches:(NSUInteger)touches
{
    if (touches == 2) {
        if (_state == CameraControllerStatePanning) {
            self.state = CameraControllerStateRotating;
        }
        
        _currentRotation = rotation;
        _rotationQuaternion = GLKQuaternionMakeWithAngleAndAxis(rotation - _previousRotation, 0, 0, -1);
    } else {
        if (_state == CameraControllerStateRotating) {
            self.state = CameraControllerStatePanning;
        }
    }
}

- (void)endRotation:(CGFloat)rotation withVelocity:(CGFloat)velocity
{
    float absVelocity = fabsf(velocity);
    _rotationInertiaAxis = GLKVector3Make(0.0f, 0.0f, -1.0f);
    _rotationInertiaVelocity = (absVelocity > ThresholdScreenRotationVelocity ? velocity : 0.0) * RotationVelocityToAngularScale;
    [self resolveInertia];
}

- (void)resolveInertia
{
    if (_rotationInertiaVelocity != 0.0f) {
        _inertiaAxis = _rotationInertiaAxis;
        _inertiaVelocity = _rotationInertiaVelocity;
    } else if (_panInertiaVelocity > 0.0f) {
        _inertiaAxis = _panInertiaAxis;
        _inertiaVelocity = _panInertiaVelocity;
    }
    
    self.state = CameraControllerStatePassive;
}


- (void)displayTick
{
    _inertiaVelocity *= DeaccelerationFactor * _extraSlowdownFactor;
    _inertiaAngle += _inertiaVelocity;
    
    GLKQuaternion intertiaQuaternion = GLKQuaternionMakeWithAngleAndVector3Axis(_inertiaAngle, _inertiaAxis);
    GLKQuaternion q = GLKQuaternionMultiply(GLKQuaternionMultiply(intertiaQuaternion, _rotationQuaternion),
                                            GLKQuaternionMultiply(_panQuaternion, _startQuaternion));
    _quaternion = q;
}


- (void)resetInertia
{
    GLKQuaternion intertiaQuaternion = GLKQuaternionMakeWithAngleAndVector3Axis(_inertiaAngle, _inertiaAxis);
    _startQuaternion = GLKQuaternionMultiply(intertiaQuaternion, _startQuaternion);
    
    _inertiaAxis = GLKVector3Make(1.0f, 0.0f, 0.0f);
    _inertiaAngle = 0.0f;
    _inertiaVelocity = 0.0f;
    _extraSlowdownFactor = 1.0f;

    _panInertiaVelocity = 0.0f;
    _rotationInertiaVelocity = 0.0f;
    
    if (_state == CameraControllerStateInertia) {
        self.state = CameraControllerStatePassive;
    }
}

- (void)stop
{
    _extraSlowdownFactor = 0.65;
}

- (void)resetPosition
{
    _startQuaternion = BaseQuaternion;
    _panQuaternion = GLKQuaternionIdentity;
    _rotationQuaternion = GLKQuaternionIdentity;;
    _inertiaAngle = 0.0f;
    
    [self resetInertia];
    [self displayTick];
}


- (GLKQuaternion)quaternionFromStartPoint:(GLKVector3)start toEndPoint:(GLKVector3)end
{
    const float epsilon = 0.00001;
    
    GLKVector3 cross = GLKVector3CrossProduct(start, end);
    float length = GLKVector3Length(cross);
    
    if (length < epsilon) {
        return GLKQuaternionIdentity;
    } else {
        GLKVector3 axis = GLKVector3MultiplyScalar(cross, 1.0/length);
        float angle = 2.0 * acosf(GLKVector3DotProduct(start, end));
        
        return GLKQuaternionMakeWithAngleAndVector3Axis(angle, axis);
    }
}


#pragma mark - Trackball

- (GLKVector3)normalizedScreenVectorFromPoint:(CGPoint)point
{
    CGSize surfaceSize = self.renderSurfaceSize;
    GLKVector3 vector = GLKVector3Make(point.x - surfaceSize.width/2.0, surfaceSize.height/2.0 - point.y, 0.0f);
    
    return GLKVector3MultiplyScalar(vector, 2.0f/(MAX(surfaceSize.width, surfaceSize.height)));
}

- (GLKVector3)pointToSphere:(CGPoint)pointOnScreen
{
    GLKVector3 point = [self normalizedScreenVectorFromPoint:pointOnScreen];
    
    CGFloat length = point.x*point.x + point.y*point.y;
    CGFloat radius = 1.0f;
    
    if (length > radius * radius / 2.0f) {
        point.z = (radius * radius / 2.0) / sqrtf(length);
    } else {
        point.z = sqrtf(radius * radius - length);
    }
    
    return GLKVector3Normalize(point);
    
}

- (GLKVector3)angularVelocityForScreenVelocty:(CGPoint)screenVelocity atScreenPoint:(CGPoint)screenPoint
{
    CGFloat length = sqrtf(screenVelocity.x * screenVelocity.x + screenVelocity.y * screenVelocity.y);
    
    if (length < ThresholdScreenPanVelocity) {
        return GLKVector3Make(0.0f, 0.0f, 0.0f);
    }
    
    CGPoint endPoint = CGPointMake(screenPoint.x + screenVelocity.x/length, screenPoint.y + screenVelocity.y/length);
    
    GLKVector3 start = [self pointToSphere:screenPoint];
    GLKVector3 end = [self pointToSphere:endPoint];
    
    GLKVector3 axis = GLKVector3Normalize(GLKVector3CrossProduct(start, end));
    
    return GLKVector3MultiplyScalar(axis, length * PanVelocityToAngularScale);
}

#pragma mark - Animation


- (void)animateToStartPositionWithDuration:(NSTimeInterval)duration
{
    self.state = CameraControllerStatePassive;
    [self resetInertia];
    
    RVQuaternionAnimation *animation = [RVQuaternionAnimation quaternionAnimationFromValue:self.startQuaternion toValue:BaseQuaternion withDuration:duration];
    [[RVAnimator sharedAnimator] addAnimation:animation forKey:@"startQuaternion" toTarget:self];
}



@end
