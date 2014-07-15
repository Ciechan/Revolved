//
//  RVOpenGLView.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 21.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVOpenGLView.h"

@interface RVOpenGLView()
@property (nonatomic) GLuint colorRenderbuffer;
@property (nonatomic) GLuint resolveFramebuffer;

@property (nonatomic) GLuint sampleFramebuffer;
@property (nonatomic) GLuint sampleColorRenderbuffer;
@property (nonatomic) GLuint sampleDepthRenderbuffer;

@end

@implementation RVOpenGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    [self destroyRenderBuffers];
}

- (void)commonInit
{
    self.layer.opaque = YES;
    self.layer.contentsScale = [[UIScreen mainScreen] scale];
}

- (void)setContext:(EAGLContext *)context
{
    _context = context;
    
    [self createRenderBuffers];
}

- (void)destroyRenderBuffers
{
    if (_resolveFramebuffer) {
        glDeleteFramebuffers(1, &_resolveFramebuffer);
        _resolveFramebuffer = 0;
    }
    
    if (_colorRenderbuffer) {
        glDeleteRenderbuffers(1, &_colorRenderbuffer);
        _colorRenderbuffer = 0;
    }
    
    
    
    if (_sampleDepthRenderbuffer) {
        glDeleteFramebuffers(1, &_sampleDepthRenderbuffer);
        _sampleDepthRenderbuffer = 0;
    }
    
    if (_sampleColorRenderbuffer) {
        glDeleteRenderbuffers(1, &_sampleColorRenderbuffer);
        _sampleColorRenderbuffer = 0;
    }
    
    if (_sampleFramebuffer) {
        glDeleteRenderbuffers(1, &_sampleFramebuffer);
        _sampleFramebuffer = 0;
    }
    
}

- (void)createRenderBuffers
{
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];

    glGenFramebuffers(1, &_resolveFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _resolveFramebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
    
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_drawableWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_drawableHeight);
    
    
    glGenFramebuffers(1, &_sampleFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _sampleFramebuffer);

    glGenRenderbuffers(1, &_sampleColorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _sampleColorRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, _drawableWidth, _drawableHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _sampleColorRenderbuffer);
    
    glGenRenderbuffers(1, &_sampleDepthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _sampleDepthRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT24_OES, _drawableWidth, _drawableHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _sampleDepthRenderbuffer);
}

- (void)presentWithRenderingBlock:(void (^)(void))renderingBlock
{
    glBindFramebuffer(GL_FRAMEBUFFER, _sampleFramebuffer);

    renderingBlock();

    const GLenum depthDiscard  = GL_DEPTH_ATTACHMENT;
    glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, &depthDiscard);
    
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _sampleFramebuffer);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _resolveFramebuffer);

    glResolveMultisampleFramebufferAPPLE();
    
    const GLenum discards[]  = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, discards);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

void dataProviderReleaseDataCallback(void *info, const void *data, size_t size)
{
    free((void *)data);
}


/*
 https://github.com/BradLarson/GPUImage/blob/8986763eaf1061d150356c3ccfaf85bba679ad89/framework/Source/GPUImageFilter.m
 */

- (UIImage *)snapshotWithRenderingBlock:(void (^)(void))renderingBlock
{
    glBindFramebuffer(GL_FRAMEBUFFER, _sampleFramebuffer);

    renderingBlock();
    
    
    GLuint dataFramebuffer;
    glGenFramebuffers(1, &dataFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, dataFramebuffer);
    
    
    CVOpenGLESTextureCacheRef rawDataTextureCache;
    CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [EAGLContext currentContext], NULL, &rawDataTextureCache);
    
    if (error) {
        NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreate %d", error);
    }
    
    // Code originally sourced from http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
    
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, // our empty IOSurface properties dictionary
                               NULL,
                               NULL,
                               0,
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                      1,
                                      &kCFTypeDictionaryKeyCallBacks,
                                      &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(attrs,
                         kCVPixelBufferIOSurfacePropertiesKey,
                         empty);
    
    CVPixelBufferRef renderTarget;
    CVPixelBufferCreate(kCFAllocatorDefault,
                        _drawableWidth,
                        _drawableHeight,
                        kCVPixelFormatType_32BGRA,
                        attrs,
                        &renderTarget);
    
    CVOpenGLESTextureRef renderTexture;
    CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault,
                                                  rawDataTextureCache, renderTarget,
                                                  NULL, // texture attributes
                                                  GL_TEXTURE_2D,
                                                  GL_RGBA, // opengl format
                                                  _drawableWidth,
                                                  _drawableHeight,
                                                  GL_BGRA, // native iOS format
                                                  GL_UNSIGNED_BYTE,
                                                  0,
                                                  &renderTexture);
    CFRelease(attrs);
    CFRelease(empty);
    glActiveTexture(GL_TEXTURE2);

    glBindTexture(CVOpenGLESTextureGetTarget(renderTexture), CVOpenGLESTextureGetName(renderTexture));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(renderTexture), 0);

    
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, dataFramebuffer);
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _sampleFramebuffer);
    glResolveMultisampleFramebufferAPPLE();
    
    glFinish();
    
    
    
    CVPixelBufferLockBaseAddress(renderTarget, 0);
    GLubyte *_rawBytesForImage = (GLubyte *)CVPixelBufferGetBaseAddress(renderTarget);
    
    NSUInteger paddedWidthOfImage = CVPixelBufferGetBytesPerRow(renderTarget) / 4;
    NSUInteger paddedBytesForImage = paddedWidthOfImage * _drawableHeight * 4;
    
    void *copiedData = malloc(paddedBytesForImage);
    memcpy(copiedData, _rawBytesForImage, paddedBytesForImage);

    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, copiedData, paddedBytesForImage, dataProviderReleaseDataCallback);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef cgImageFromBytes = CGImageCreate(_drawableWidth, _drawableHeight, 8, 32, CVPixelBufferGetBytesPerRow(renderTarget), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    
    CVPixelBufferUnlockBaseAddress(renderTarget, 0);
    
    UIImage *image = [UIImage imageWithCGImage:cgImageFromBytes];
    
    CGImageRelease(cgImageFromBytes);
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colorSpace);
    
    
    if (renderTexture) {
        CFRelease(renderTexture);
        renderTexture = NULL;
    }
    
    if (dataFramebuffer) {
        glDeleteFramebuffers(1, &dataFramebuffer);
        dataFramebuffer = 0;
    }
    
    if (rawDataTextureCache) {
        CVOpenGLESTextureCacheFlush(rawDataTextureCache, 0);
        CFRelease(rawDataTextureCache);
        rawDataTextureCache = 0;
    }
    
    if (renderTarget) {
        CVPixelBufferRelease(renderTarget);
        renderTarget = 0;
    }
    

    
    return image;

}

@end
