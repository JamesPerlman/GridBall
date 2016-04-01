//
//  Math.c
//  GridBall
//
//  Created by James on 12/15/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#include "Math.h"

float F(float d) {
    return bForceMultiplier * (cosf(M_PI*d)+1.0)/2.0;
};