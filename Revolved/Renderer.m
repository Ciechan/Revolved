//
//  Renderer.m
//  Patterns
//
//  Created by Bartosz Ciechanowski on 23.07.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "Renderer.h"
#import "Camera.h"

#import "RVModelShader.h"
#import "RVAxisShader.h"
#import "RVLineShader.h"
#import "RVPointShader.h"

#import "RVModelMeshController.h"
#import "RVAxisMeshController.h"
#import "RVGuidlineDotMeshController.h"
#import "RVLineMeshController.h"
#import "RVPointMeshController.h"
#import "RVColorProvider.h"

#import "RVModelSprite.h"
#import "RVAxisSprite.h"

#import "Constants.h"

@interface Renderer()

@property (nonatomic, strong) RVModelShader *modelShader;
@property (nonatomic, strong) RVAxisShader *axisShader;
@property (nonatomic, strong) RVLineShader *lineShader;
@property (nonatomic, strong) RVPointShader *pointShader;

@property (nonatomic, strong) GLKTextureInfo *spritesTexture;
@property (nonatomic, assign) GLuint noiseTextureName;
@end


@implementation Renderer

- (id)init
{
    self = [super init];
    if (self) {
        _modelShader = [RVModelShader new];
        _axisShader = [RVAxisShader new];
        _lineShader = [RVLineShader new];
        _pointShader = [RVPointShader new];
    }
    
    return self;
}

- (void)setupOpenGL
{
    [self.modelShader loadProgram];
    [self.axisShader loadProgram];
    [self.lineShader loadProgram];
    [self.pointShader loadProgram];
    
    NSError *error;
    self.spritesTexture = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sprites" ofType:@"png"]
                                                              options:@{GLKTextureLoaderApplyPremultiplication: @(NO)}
                                                                error:&error];
    
    glBindTexture(GL_TEXTURE_2D, self.spritesTexture.name);
    
    glActiveTexture(GL_TEXTURE1);
  
    [self createNoiseTexture];
    
    GLKVector3 backgroundColor = [RVColorProvider vectorForBackgroundColor];
    glClearColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, 1.0);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glLineWidth([UIScreen mainScreen].scale);
    
    glUseProgram(self.pointShader.program);
    glUniform1i(self.pointShader.texSamplerUniform, 0);
    
    GLKVector2 trig[Spans];
    for (int i = 0; i < Spans; i++) {
        trig[i].x = cosf(2.0f * M_PI * i/Spans);
        trig[i].y = sinf(2.0f * M_PI * i/Spans);
    }

    
    glUseProgram(self.modelShader.program);
    glUniform1i(self.modelShader.texSamplerUniform, 1);
    glUniform2fv(self.modelShader.trigonometryUniform, Spans, (GLfloat*)&trig);
    

}

- (void)createNoiseTexture
{
    static const GLint MaxMipMapLevel = 4;
    
    glGenTextures(1, &_noiseTextureName);
    glBindTexture(GL_TEXTURE_2D, _noiseTextureName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL_APPLE, MaxMipMapLevel - 1);

    
    UIImage *image = [UIImage imageNamed:@"noise"];
    
    CGImageRef imageRef = [image CGImage];
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    
    for (int level = 0; level < MaxMipMapLevel; level++) {
        NSUInteger bytesPerRow = bytesPerPixel * width;
        
        CGImageRef partImage = CGImageCreateWithImageInRect(imageRef, CGRectMake(0, 0, width, height));
        
        unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(*rawData));
        
        CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                     bitsPerComponent, bytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone); // don't blur pixels
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), partImage);
        CGContextRelease(context);

        glTexImage2D(GL_TEXTURE_2D, level, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, rawData);
        
        free(rawData);
        CGImageRelease(partImage);
        
        width /= 2;
        height /= 2;
    }
    
    CGColorSpaceRelease(colorSpace);
}


#pragma mark - Rendering

- (void)render
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // left side
    
    glViewport(_meshViewport.origin.x, _meshViewport.origin.y, _meshViewport.size.width, _meshViewport.size.height);
    
    glEnable(GL_DEPTH_TEST);
    
    [self renderSpansFlipped:NO];
    
    glDepthMask(GL_FALSE);
    glEnable(GL_BLEND);
    [self renderAxis];
    glDisable(GL_BLEND);
    
    // right side
    
    glDisable(GL_DEPTH_TEST);
    glViewport(_drawingViewport.origin.x, _drawingViewport.origin.y, _drawingViewport.size.width, _drawingViewport.size.height);
    glEnable(GL_BLEND);
    
    [self renderGuidelines];
    
    glDisable(GL_BLEND);
     
    [self renderLines];
    
    glEnable(GL_BLEND);
    
    [self renderPoints];
    
    glDisable(GL_BLEND);
    glDepthMask(GL_TRUE);
    
    glBindVertexArrayOES(0);
}

- (void)renderModelMesh
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glViewport(_meshViewport.origin.x, _meshViewport.origin.y, _meshViewport.size.width, _meshViewport.size.height);
    glEnable(GL_DEPTH_TEST);
    
    [self renderSpansFlipped:YES];
    
    glDepthMask(GL_TRUE);
    glBindVertexArrayOES(0);
}



- (void)renderSpansFlipped:(BOOL)flipped
{
    glBindVertexArrayOES(self.modelController.VAO);
    
    GLKMatrix4 baseViewProjectionMatrix = self.camera.viewProjectionMatrix;
    GLKMatrix4 baseNormalMatrix = self.camera.viewMatrix;
    
    glUseProgram(self.modelShader.program);

    for (RVModelSprite *modelSprite in self.modelController.sprites) {
        
        GLKVector3 translation = GLKVector3Add(modelSprite.translationVector, modelSprite.extraTranslationVector);
        GLKVector3 scale = modelSprite.scaleVector;
        GLKMatrix4 spriteMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(translation.x, translation.y, translation.z),
                                                     GLKMatrix4MakeScale(scale.x, scale.y, scale.z));
        
        GLKVector3 modelScale = modelSprite.modelScaleVector;
        
        GLKMatrix4 modelScaleMatrix = GLKMatrix4MakeScale(modelScale.x, modelScale.y, modelScale.z);
        GLKMatrix4 modelRotationMatrix = GLKMatrix4MakeWithQuaternion(modelSprite.quaternion);
        GLKMatrix4 viewProjectionMatrix = GLKMatrix4Multiply(GLKMatrix4Multiply(baseViewProjectionMatrix, modelScaleMatrix), modelRotationMatrix);
        GLKMatrix4 normalMatrix = GLKMatrix4Multiply(baseNormalMatrix, modelRotationMatrix);
        
        BOOL hasScissors = modelSprite.hasScissors;
        if (hasScissors) {
            CGRect scissorsRect = modelSprite.scissorsRect;
            scissorsRect.origin.x += 1.0f;
            scissorsRect.origin.y += 1.0f;
            scissorsRect.origin.x *= _meshViewport.size.width/2.0;
            scissorsRect.origin.y *= _meshViewport.size.height/2.0;
            scissorsRect.size.width *= _meshViewport.size.width/2.0;
            scissorsRect.size.height *= _meshViewport.size.height/2.0;
            glScissor(scissorsRect.origin.x, scissorsRect.origin.y, scissorsRect.size.width, scissorsRect.size.height);
            glEnable(GL_SCISSOR_TEST);
        }
        
        
        GLKMatrix4 viewProjectionModelMatrix = GLKMatrix4Multiply(spriteMatrix, viewProjectionMatrix);
        GLKMatrix4 normalModelMatrix = normalMatrix;
        
        if (flipped) {
            viewProjectionModelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeScale(1.0, -1.0, 1.0), viewProjectionModelMatrix);
        }
        
        glUniformMatrix3fv(self.modelShader.normalModelMatrixUniform, 1, 0, GLKMatrix4GetMatrix3(normalModelMatrix).m);
        glUniformMatrix4fv(self.modelShader.viewProjectionModelMatrixUniform, 1, 0, viewProjectionModelMatrix.m);
        
        glDrawElementsInstancedEXT(GL_TRIANGLES, modelSprite.indiciesCount, GL_UNSIGNED_SHORT, (GLvoid *)(NSUInteger)modelSprite.indiciesOffset, Spans);

        if (hasScissors) {
            glDisable(GL_SCISSOR_TEST);
        }
    }
}

- (void)renderAxis
{
    if (self.axisController.indiciesCount == 0) {
        return;
    }
    
    glBindVertexArrayOES(self.axisController.VAO);
    
    glUseProgram(self.axisShader.program);
    GLKMatrix4 baseViewProjectionMatrix = self.camera.viewProjectionMatrix;
    
    for (RVModelSprite *modelSprite in self.modelController.sprites) {
        
        if (modelSprite.axisAlpha == 0.0f) {
            continue;
        }
        GLKMatrix4 modelRotationMatrix = GLKMatrix4MakeWithQuaternion(modelSprite.quaternion);
        GLKMatrix4 viewProjectionMatrix = GLKMatrix4Multiply(baseViewProjectionMatrix, modelRotationMatrix);
        
        glUniform1f(self.axisShader.alphaUniform, modelSprite.axisAlpha);
        
        glUniformMatrix4fv(self.axisShader.viewProjectionModelMatrixUniform, 1, 0, viewProjectionMatrix.m);
        
        glDrawElements(GL_LINES, self.axisController.indiciesCount, GL_UNSIGNED_SHORT, 0);
    }
    
    
}

- (void)renderGuidelines
{
    glBindVertexArrayOES(self.guidlineController.VAO);
    
    glUseProgram(self.pointShader.program);
    glUniformMatrix4fv(self.pointShader.viewProjectionMatrixUniform, 1, 0, self.drawingTransformMatrix.m);
    
    
    if (self.guidlineController.indiciesCount > 0) {
        glDrawElements(GL_TRIANGLES, self.guidlineController.indiciesCount, GL_UNSIGNED_SHORT, 0);
    }
}

- (void)renderLines
{
    if (self.lineController.indiciesCount == 0) {
        return;
    }
    
    glBindVertexArrayOES(self.lineController.VAO);
    
    glUseProgram(self.lineShader.program);
    glUniformMatrix4fv(self.lineShader.viewProjectionMatrixUniform, 1, 0, self.drawingTransformMatrix.m);
    
    glDrawElements(GL_TRIANGLES, self.lineController.indiciesCount, GL_UNSIGNED_SHORT, 0);
}

- (void)renderPoints
{
    glBindVertexArrayOES(self.pointController.VAO);
    
    glUseProgram(self.pointShader.program);
    glUniformMatrix4fv(self.pointShader.viewProjectionMatrixUniform, 1, 0, self.drawingTransformMatrix.m);
    
    
    if (self.pointController.indiciesCount > 0) {
        glDrawElements(GL_TRIANGLES, self.pointController.indiciesCount, GL_UNSIGNED_SHORT, 0);
    }
}


@end
