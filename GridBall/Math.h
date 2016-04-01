//
//  Math.h
//  GridBall
//
//  Created by James on 12/13/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#ifndef __GridBall__Math__
#define __GridBall__Math__

#include <stdio.h>
#include <math.h>
#include <CoreGraphics/CGGeometry.h>
#import "constants.h"

// Force as a function of distance and radius

inline float F(float d);

// Data structures


struct curve {
    float bulge;
    float range;
    float x;
};

typedef struct curve curve;

struct vector {
    float x;
    float y;
};

typedef struct vector vector;

static const vector ZeroVector = (vector){0.0, 0.0};
                           
struct intVector {
    int x;
    int y;
};

typedef struct intVector intVector;

struct ptrVector {
    void *x;
    void *y;
};

typedef struct ptrVector ptrVector;


#endif /* defined(__GridBall__Math__) */
