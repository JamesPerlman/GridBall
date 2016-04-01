//
//  Ball.m
//  GridBall
//
//  Created by James on 12/13/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#import "Ball.h"

BallData MakeBall(float mass, float x, float y)
{
    BallData ball;
    ball.mass = mass;
    ball.range = mass*bRangeMultiplier;
    ball.position = CGPointMake(x,y);
    ball.velocity = ZeroVector;
    ball.acceleration = ZeroVector;
    return ball;
};

@implementation Ball

- (void) drawToContext:(CGContextRef)ctx {
    
}

@end
