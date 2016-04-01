//
//  GravityField.m
//  GridBall
//
//  Created by James on 12/19/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#import "GravityField.h"

#import <dispatch/dispatch.h>

static float G = 1.0;

@implementation GravityField
@synthesize scene = _scene;

- (void) setScene:(id<Scene>)scene {
    _scene = scene;
    ballArray = [scene ballArray];
}
- (void) update {
    // apply gravity -> accel
    // apply accel -> velocity
    // pre-detect collisions
    // apply velocity -> position
    [self applyGravity];
}

- (void) gravityDone {
    gravityCount++;
    if (gravityCount == MAXIMUM_BALLS) {
        [self detectCollisions];
    }
}

- (void) applyGravity {
    for (int i = 0; i < MAXIMUM_BALLS; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int j, thisIndex = i;
            BallData *ball1, *ball2;
            float ax, ay, b, x, y; // accel (x and y), G*m2, x distance, y distance
            
            ball1 = &ballArray[i];
            ax = ay = 0;
            
            for (j = 0; j < MAXIMUM_BALLS; j++) {
                if (j!=thisIndex) {
                    ball2 = &ballArray[j];
                    // get distance between balls
                    x = ball1->position.x - ball2->position.x;
                    y = ball1->position.y - ball2->position.y;
                    
                    b = G * ball2->mass;
                    // add gravity acceleration from ball2
                    ax += b / (x*x);
                    ay += b / (y*y);
                }
            }
            
            // save total acceleration in ball1's data
            
            ball1->acceleration.x = ax;
            ball1->acceleration.y = ay;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self gravityDone];
            });
        });
    }
}

- (void) collisionDone {
    collisionCount++;
    if (collisionCount == MAXIMUM_BALLS) {
        [_scene physicsDidFinishProcessing];
    }
}

- (void) detectCollisions {
    
}

@end
