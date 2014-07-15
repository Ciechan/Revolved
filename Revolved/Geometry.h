//
//  Geometry.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#ifndef Revolved_Geometry_h
#define Revolved_Geometry_h


static inline float GLKVector2DistanceSq(GLKVector2 vectorStart, GLKVector2 vectorEnd)
{
    GLKVector2 diff = GLKVector2Subtract(vectorEnd, vectorStart);
    return GLKVector2DotProduct(diff, diff);
}



static inline float SquareDistancePointSegment(GLKVector2 a, GLKVector2 b, GLKVector2 c)
{
    GLKVector2 ab = GLKVector2Subtract(b, a);
    GLKVector2 ac = GLKVector2Subtract(c, a);
    
    float e = GLKVector2DotProduct(ac, ab);
    if (e <= 0.0f) {
        return GLKVector2DotProduct(ac, ac);
    }

    GLKVector2 bc = GLKVector2Subtract(c, b);
    
    float f = GLKVector2DotProduct(ab, ab);
    if (e >= f) {
        return GLKVector2DotProduct(bc, bc);
    }
    
    return GLKVector2DotProduct(ac, ac) - e * e / f;
}


// given segment ab and point c, computes closest point d on ab
// returns UNCLAMPPED value of t
static inline GLKVector2 ClosestPointOnSegmentForPoint(GLKVector2 a, GLKVector2 b, GLKVector2 c, float *t)
{
    GLKVector2 ab = GLKVector2Subtract(b, a);
    GLKVector2 ac = GLKVector2Subtract(c, a);
    
    float realT = GLKVector2DotProduct(ac, ab) / GLKVector2DotProduct(ab, ab);
    *t = realT;
    
    return GLKVector2Add(a, GLKVector2MultiplyScalar(ab, realT));
}

#endif
