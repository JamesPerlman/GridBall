//
//  SceneProtocol.h
//  GridBall
//
//  Created by James on 12/15/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Math.h"
#import "Ball.h"

@class Grid;
@protocol Scene <NSObject>
- (void) gridDidFinishUpdating;
- (void) gridDidFinishDrawing;
- (void) physicsDidFinishProcessing;

@property (nonatomic, readonly) BallData* ballArray;
@property (nonatomic) Grid* grid;

@end