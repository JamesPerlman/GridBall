//
//  Ball.h
//  GridBall
//
//  Created by James on 12/13/14.
//  Copyright (c) 2014 James. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#ifndef __BALL_H
#define __BALL_H

#import "Math.h"

struct BallData {
    float mass;
    float range;
    //    float radius;
    CGPoint position;
    vector velocity;
    vector acceleration;
};

typedef struct BallData BallData;

BallData MakeBall(float mass, float x, float y);

#endif

@interface Ball : NSObject {
    BallData *data;
}

- (void)drawToContext:(CGContextRef)ctx;

@end
