//
//  Grid.h
//  GridBall
//
//  Created by James on 12/13/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIBezierPath.h>
#import <math.h>
#import "SceneProtocol.h"
#import "Math.h"

@class Grid;

@interface Grid : NSObject {
    int lineCountX, lineCountY;
    int dispatchAxesFinishedUpdating;
    curve c;
    curve *curveArrayX, *curveArrayY;
    //curve *thisCurve;//, *lastCurve;
    float *tickMarksX, *tickMarksY;
    float squareSize, x, y, s, k, k2,
          sensorWidth, sensorHeight,
          centerX, centerY,
          c1, c2;
    CGPoint a1, a2, a3;
    CGSize gridSize;
    BallData *ballArray;
    BallData **xBalls, **yBalls;
}

- (instancetype)initWithSize:(CGSize)totalSize andSquareSize:(float)squareSize;

- (void) update;

- (void)drawToContext:(CGContextRef)ctx;


@property (nonatomic, weak) id<Scene> scene;

@end
