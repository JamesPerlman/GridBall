//
//  GravityField.h
//  GridBall
//
//  Created by James on 12/19/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Ball.h"

#import "SceneProtocol.h"

@interface GravityField : NSObject {
    BallData *ballArray;
    int gravityCount, collisionCount;
}

@property (nonatomic, weak) id<Scene> scene;

- (void) update;

@end
