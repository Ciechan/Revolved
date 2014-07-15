//
//  Color.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 03.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#ifndef Revolved_Color_h
#define Revolved_Color_h

typedef struct Color {
    unsigned char r, g, b;
} Color;

static inline GLKVector3 colorToGLKVector3(Color color)
{
    return GLKVector3Make(color.r / 255.0, color.g / 255.0, color.b / 255.0);
}

static inline Color colorWithRGB(char red, char green, char blue)
{
    return (Color){red, green, blue};
}

static inline Color colorWithHexColor(NSUInteger hexColor)
{
    return colorWithRGB((hexColor & 0xFF0000) >> 16,
                        (hexColor & 0x00FF00) >> 8,
                        (hexColor & 0x0000FF) >> 0);
}



#endif
