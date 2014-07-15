//
//  RVColorProvider.m
//  Revolved
//
//  Created by Bartosz Ciechanowski on 18.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVColorProvider.h"


const NSUInteger ColorCount = 12;

static const NSUInteger ColorValues[ColorCount] = {
    0xed4c54,
    0xf58c58,
    0xfebe4d,
    0xf1d948,
    0x98cc3d,
    0x47b24f,
    0x35b299,
    0x368ab4,
    0x345fa3,
    0x8045ba,
    0xb440b1,
    0xb53678,
};

static UIColor *colors[ColorCount];
static GLKVector3 vectors[ColorCount];
static GLKVector3 desaturatedVectors[ColorCount];

@implementation RVColorProvider


+ (void)initialize
{
    for (int i = 0; i < ColorCount; i++) {
        colors[i] = [self colorFromHex:ColorValues[i]];
        vectors[i] = [self vectorFromHex:ColorValues[i]];
        desaturatedVectors[i] = [self vectorForColor:[self desaturatedColor:colors[i]]];
    }
}

+ (UIColor *)colorFromHex:(NSUInteger)hex
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0x00FF00) >> 8))/255.0
                            blue:((float)((hex & 0x0000FF) >> 0))/255.0 alpha:1.0];
}

+ (UIColor *)desaturatedColor:(UIColor *)color
{
    CGFloat hue, saturation, brightness, alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    return [UIColor colorWithHue:hue saturation:saturation * 0.1 brightness:brightness * 0.8 alpha:alpha];
}

+ (GLKVector3)vectorForColor:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return GLKVector3Make(red, green, blue);
}

+ (GLKVector3)vectorFromHex:(NSUInteger)hex
{
    return GLKVector3Make((float)((hex & 0xFF0000) >> 16)/255.0,
                          (float)((hex & 0x00FF00) >> 8)/255.0,
                          (float)((hex & 0x0000FF) >> 0)/255.0);
}


+ (UIColor *)colorForColorIndex:(NSUInteger)colorIndex
{
    return colors[colorIndex];
}

+ (GLKVector3)vectorForColorIndex:(NSUInteger)colorIndex
{
    return vectors[colorIndex];
}

+ (GLKVector3)vectorForDesaturatedColorIndex:(NSUInteger)colorIndex
{
    return desaturatedVectors[colorIndex];
}

+ (GLKVector3)vectorForBackgroundColor
{
    const float shade = 0.93f;
    return GLKVector3Make(shade, shade, shade);
}

+ (GLKVector3)vectorForAxisColor
{
    const float shade = 0.72f;
    return GLKVector3Make(shade, shade, shade);
}

+ (NSString *)mtlString
{
    NSMutableString *string = [NSMutableString string];
    
    for (int i = 0; i < ColorCount; i++) {
        [string appendFormat:@"newmtl mat%d\n", i];
        
        GLKVector3 c = [self vectorForColorIndex:i];
        GLKVector3 Ka = c;
        GLKVector3 Kd = c;
        
        [string appendFormat:@"Ka %g %g %g\n", Ka.x, Ka.y, Ka.z];
        [string appendFormat:@"Kd %g %g %g\n", Kd.x, Kd.y, Kd.z];
        [string appendFormat:@"Ks %g %g %g\n", 0.0f, 0.0f, 0.0f];
        
        [string appendString:@"d 1\nillum 2\n\n"];
    }
    
    return string;
}

@end
