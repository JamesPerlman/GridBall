///
//  Grid.m
//  GridBall
//
//  Created by James on 12/13/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#import "Grid.h"

#import <dispatch/dispatch.h>

@implementation Grid

@synthesize scene = _scene;

- (instancetype)initWithSize:(CGSize)totalSize andSquareSize:(float)size
{
    self = [super init];
    
    if (self) {
        int i;
        
        centerX = totalSize.width/2;
        centerY = totalSize.height/2;
        
        // setup grid
        
        gridSize = totalSize;
        squareSize = size;
        
        lineCountX = (int)(totalSize.width/squareSize);
        lineCountY = (int)(totalSize.height/squareSize);
        
        curveArrayX = calloc((size_t)lineCountX * MAXIMUM_BALLS, sizeof(curve));
        curveArrayY = calloc((size_t)lineCountY * MAXIMUM_BALLS, sizeof(curve));
        
        tickMarksX = malloc(lineCountX * sizeof(float));
        for (i = 0; i < lineCountX; i++) {
            tickMarksX[i] = totalSize.width/(float)lineCountX * (float)i;
        }
        tickMarksY = malloc(lineCountY * sizeof(float));
        for (i = 0; i < lineCountY; i++) {
            tickMarksY[i] = totalSize.height/(float)lineCountY * (float)i;
        }
        
        dispatchAxesFinishedUpdating = 0;
        
    }
    
    return self;
}

- (void)setScene:(id<Scene>)scene {
    
    _scene = scene;
    ballArray = (BallData*)[scene ballArray];
    
    xBalls = malloc(sizeof(void*)*MAXIMUM_BALLS);
    yBalls = malloc(sizeof(void*)*MAXIMUM_BALLS);
    
    for (int i = 0; i < MAXIMUM_BALLS; i++) {
        yBalls[i] = xBalls[i] = &ballArray[i];
    }
}

- (void)update {
    [self sortBalls];
    // loop through each ball
    // dispatch x loop
    
    int a;
    
    
    for (a = 0; a < lineCountX; a++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int i = a;
            int j;
            float range, d;
            BallData *ball;
            curve *thisCurve;
            
            for (j = 0; j < MAXIMUM_BALLS; j++) {
                // get a reference to this ball
                ball  = yBalls[j];
                range = ball->range;
                d     = fabsf(ball->position.x - tickMarksX[i]);
                
                // get a reference to the curve affected by this ball
                thisCurve = &curveArrayX[i*MAXIMUM_BALLS+j];
                
                // if this ball is in range of the gridline
                if (d <= range) {
                    // then we supply information to the curve
                    thisCurve->range = bRangeMultiplier*sqrtf(range*range - d*d);
                    thisCurve->x     = ball->position.y - thisCurve->range/2;
                    thisCurve->bulge = F(d/range);
                } else {
                    thisCurve->bulge = 0;
                }
                
            }
            // tell main thread this line's curves are done
            dispatch_async(dispatch_get_main_queue(), ^{
                [self axisDidFinishUpdating];
            });
        });
    }
    
    
    // dispatch y loop
    
    
    for (a = 0; a < lineCountY; a++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int i = a;
            int j;
            float range, d;
            BallData *ball;
            curve *thisCurve;
            
            for(j = 0; j < MAXIMUM_BALLS; j++) {
                // get a reference to this ball
                ball  = xBalls[j];
                range = ball->range;
                d     = fabsf(ball->position.y - tickMarksY[i]);
                
                // get a reference to the curve affected by this ball
                thisCurve = &curveArrayY[i*MAXIMUM_BALLS+j];
                
                // if this ball is in range of the gridline
                if (d <= range) {
                    // then we supply information to the curve
                    thisCurve->range = bRangeMultiplier * sqrtf(range*range - d*d);
                    thisCurve->x     = ball->position.x - thisCurve->range/2;
                    thisCurve->bulge = F(d/range);
                } else {
                    // otherwise we zero out the curve data
                    thisCurve->bulge = 0.0;
                }
                
            }
            // tell main thread this line's curves are done
            dispatch_async(dispatch_get_main_queue(), ^{
                [self axisDidFinishUpdating];
            });
        });
    }
    
}

- (void)sortBalls {
    BallData *ball;
    int minX, minY;
    int i, j;
    for (i = 0; i < MAXIMUM_BALLS; i++) {
        minX = minY = i;
        for (j = i + 1; j < MAXIMUM_BALLS; j++) {
            if (xBalls[j]->position.x < xBalls[minX]->position.x) {
                minX = j;
            }
            if (yBalls[j]->position.y < yBalls[minY]->position.y) {
                minY = j;
            }
        }
        if (minX != i) {
            // swap
            ball = xBalls[minX];
            xBalls[minX] = xBalls[i];
            xBalls[i] = ball;
        }
        if (minY != i) {
            ball = yBalls[minY];
            yBalls[minY] = yBalls[i];
            yBalls[i] = ball;
        }
    }
}

- (void)axisDidFinishUpdating {
    dispatchAxesFinishedUpdating++;
    if (dispatchAxesFinishedUpdating == lineCountX + lineCountY) {
        dispatchAxesFinishedUpdating = 0;
        [_scene gridDidFinishUpdating];
    }
}

- (void)drawToContext:(CGContextRef)ctx
{
    int i,j;
    float ix, iy, d, x1, x2, y1, y2;
    bool b;
    curve *thisCurve, *nextCurve, *prevCurve;
    BallData *thisBall, *prevBall, *nextBall;
    nextCurve = NULL;
    prevCurve = NULL;
    CGContextSaveGState(ctx);
    CGContextSetStrokeColor(ctx, (CGFloat[4]){0, 0, 0, .6});
    CGContextSetLineWidth(ctx, 1.0);
    CGContextBeginPath(ctx);
    // draw all curves
    // X axis first
    for (i=0; i<lineCountX; i++) {
        x = tickMarksX[i];
        
        CGContextMoveToPoint(ctx, x, 0);
        
        for (j=0; j<MAXIMUM_BALLS; j++) {
            
            thisCurve = &curveArrayX[i*MAXIMUM_BALLS+j];
            
            thisBall = yBalls[j];
            
            
            b = false;
            if (thisCurve->bulge) {
                y = thisCurve->x;
                
                
                // check if prevCurve is non-null
                if (j > 0) {
                    prevCurve = &curveArrayX[i*MAXIMUM_BALLS+j-1];
                    if (prevCurve->bulge) {
                        // check if curves overlap
                        if (thisCurve->x < prevCurve->x + prevCurve->range) {
                            
                            d = (thisCurve->x+thisCurve->range/2) - (prevCurve->x+prevCurve->range/2);
                            // smooth startpoint for this curve
                            
                            x1 = prevCurve->range/2;
                            y1 = prevCurve->bulge;
                            x2 = thisCurve->range/2;
                            y2 = thisCurve->bulge;
                            
                            // get slope
                            //slope = (y2 - y1) / d;
                            
                            // get curve intersection
                            ix = (x1*x2)/(x1*y2+x2*y1) * (y1-y2+d*(y2/x2));
                            iy = -(y1/x1) * ix + y1;
                            
                            // select a new centerpoint as the average of the ball centers
                            prevBall = yBalls[j-1];
                            
                            centerX = (thisBall->position.x + prevBall->position.x)/2;
                            centerY = (thisBall->position.y + prevBall->position.y)/2;
                            
                            k = (cameraZ + iy)/cameraZ;
                            
                            
                            // curve startpoint
                            a1.x = centerX + k*(x - centerX);
                            a1.y = centerY + k*(ix+x1+prevCurve->x - centerY);
                            
                            // curve midpoint
                            
                            
                            c1 = (a1.y + thisBall->position.y)/2;
                            
                            //CGContextMoveToPoint(ctx, a1.x, a1.y);
                            
                            b = true;
                        }
                    }
                }
                
                
                centerX = thisBall->position.x;
                centerY = thisBall->position.y;
                
                k = (cameraZ + thisCurve->bulge)/cameraZ;
                
                if (!b) {
                    // anchor point 1
                    a1.x = x;
                    a1.y = y;
                    
                    // control point 1
                    c1 = y + thisCurve->range/4;
                    
                }
                // draw grid line to start of new curve
                CGContextAddLineToPoint(ctx, a1.x, a1.y);
                
                // center x and y for the apex of the bulge
                a2.x = centerX + k*(x - centerX);
                a2.y = centerY + k*((y + thisCurve->range/2) - centerY);
                
                
                
                b = false;
                // check if nextCurve is non-null
                if (j < MAXIMUM_BALLS-1) {
                    nextCurve = &curveArrayX[i*MAXIMUM_BALLS+j+1];
                    if (nextCurve->bulge) {
                        
                        // check if curves overlap
                        if (nextCurve->x < thisCurve->x + thisCurve->range) {
                            // distance between curve centers
                            d = (nextCurve->x+nextCurve->range/2) - (thisCurve->x+thisCurve->range/2);
                            
                            // smooth endpoint for this curve
                            
                            x1 = thisCurve->range/2;
                            y1 = thisCurve->bulge;
                            x2 = nextCurve->range/2;
                            y2 = nextCurve->bulge;
                            
                            // get slope
                            //slope = (y2 - y1) / d;
                            
                            // get curve intersection.  that is our endpoint
                            ix = (x1*x2)/(x1*y2+x2*y1) * (y1-y2+d*(y2/x2));
                            iy = -(y1/x1) * ix + y1;
                            
                            
                            // select a new centerpoint as the average of the ball centers
                            nextBall = yBalls[j+1];
                            
                            centerX = (thisBall->position.x + nextBall->position.x)/2;
                            centerY = (thisBall->position.y + nextBall->position.y)/2;
                            
                            k = (cameraZ + iy)/cameraZ;
                            
                            
                            // curve startpoint
                            a3.x = centerX + k*(x - centerX);
                            a3.y = centerY + k*(thisCurve->x+x1+ix - centerY);
                            
                            // curve midpoint
                            
                            
                            c2 = (a3.y + thisBall->position.y)/2;
                            
                            //CGContextMoveToPoint(ctx, a1.x, a1.y);
                            
                            b = true;
                        }
                    }
                }
                
                if (!b) {
                    // endpoint
                    a3.x = x;
                    a3.y = y + thisCurve->range;
                    // control point 2
                    c2 = y + thisCurve->range*3/4;
                }
                
                
                // draw bézier curves
                CGContextAddCurveToPoint(ctx, a1.x, c1, a2.x, c1, a2.x, a2.y);
                CGContextAddCurveToPoint(ctx, a2.x, c2, a3.x, c2, a3.x, a3.y);
                
            }
            prevCurve = thisCurve;
        }
        // complete grid line to end of grid
        CGContextAddLineToPoint(ctx, x, gridSize.height);
    }
    nextCurve = NULL;
    prevCurve = NULL;
    // then y axes
    for (i=0; i<lineCountY; i++) {
        y = tickMarksY[i];
        
        CGContextMoveToPoint(ctx, 0, y);
        
        for (j=0; j<MAXIMUM_BALLS; j++) {
            
            thisCurve = &curveArrayY[i*MAXIMUM_BALLS+j];
            
            thisBall = xBalls[j];
            b = false;
            if (thisCurve->bulge) {
                x = thisCurve->x;
                
                
                // check if prevCurve is non-null
                if (j > 0) {
                    prevCurve = &curveArrayY[i*MAXIMUM_BALLS+j-1];
                    if (prevCurve->bulge) {
                        // check if curves overlap
                        if (thisCurve->x < prevCurve->x + prevCurve->range) {
                            
                            d = (thisCurve->x+thisCurve->range/2) - (prevCurve->x+prevCurve->range/2);
                            // smooth startpoint for this curve
                            
                            x1 = prevCurve->range/2;
                            y1 = prevCurve->bulge;
                            x2 = thisCurve->range/2;
                            y2 = thisCurve->bulge;
                            
                            // get slope
                            //slope = (y2 - y1) / d;
                            
                            // get curve intersection
                            ix = (x1*x2)/(x1*y2+x2*y1) * (y1-y2+d*(y2/x2));
                            iy = -(y1/x1) * ix + y1;
                            
                            // select a new centerpoint as the average of the ball centers
                            prevBall = xBalls[j-1];
                            
                            centerX = (thisBall->position.x + prevBall->position.x)/2;
                            centerY = (thisBall->position.y + prevBall->position.y)/2;
                            
                            k = (cameraZ + iy)/cameraZ;
                            
                            
                            // curve startpoint
                            a1.y = centerY + k*(y - centerY);
                            a1.x = centerX + k*(ix+x1+prevCurve->x - centerX);
                            
                            // curve midpoint
                            
                            
                            c1 = (a1.x + thisBall->position.x)/2;
                            
                            //CGContextMoveToPoint(ctx, a1.x, a1.y);
                            
                            b = true;
                        }
                    }
                }
                
                centerX = thisBall->position.x;
                centerY = thisBall->position.y;
                k = (cameraZ + thisCurve->bulge)/cameraZ;
                
                if (!b) {
                    // anchor point 1
                    a1.x = x;
                    a1.y = y;
                    
                    // control point 1
                    c1 = x + thisCurve->range/4;
                }
                
                // center x and y for the apex of the bulge
                a2.x = centerX + k*((x + thisCurve->range/2) - centerX);
                a2.y = centerY + k*(y - centerY);
                
                
                b = false;
                // check if nextCurve is non-null
                if (j < MAXIMUM_BALLS-1) {
                    nextCurve = &curveArrayY[i*MAXIMUM_BALLS+j+1];
                    if (nextCurve->bulge) {
                        
                        // check if curves overlap
                        if (nextCurve->x < thisCurve->x + thisCurve->range) {
                            // distance between curve centers
                            d = (nextCurve->x+nextCurve->range/2) - (thisCurve->x+thisCurve->range/2);
                            
                            // smooth endpoint for this curve
                            
                            x1 = thisCurve->range/2;
                            y1 = thisCurve->bulge;
                            x2 = nextCurve->range/2;
                            y2 = nextCurve->bulge;
                            
                            // get slope
                            //slope = (y2 - y1) / d;
                            
                            // get curve intersection.  that is our endpoint
                            ix = (x1*x2)/(x1*y2+x2*y1) * (y1-y2+d*(y2/x2));
                            iy = -(y1/x1) * ix + y1;
                            
                            
                            // select a new centerpoint as the average of the ball centers
                            nextBall = xBalls[j+1];
                            
                            centerX = (thisBall->position.x + nextBall->position.x)/2;
                            centerY = (thisBall->position.y + nextBall->position.y)/2;
                            
                            k = (cameraZ + iy)/cameraZ;
                            
                            
                            // curve startpoint
                            a3.y = centerY + k*(y - centerY);
                            a3.x = centerX + k*(thisCurve->x+x1+ix - centerX);
                            
                            // curve midpoint
                            
                            
                            c2 = (a3.x + thisBall->position.x)/2;
                            
                            //CGContextMoveToPoint(ctx, a1.x, a1.y);
                            
                            b = true;
                        }
                    }
                }
                
                if (!b) {
                    // endpoint
                    a3.x = x + thisCurve->range;
                    a3.y = y;
                    // control point 2
                    c2 = x + thisCurve->range*3/4;
                    
                }
                // draw grid line to start of bezier curve;
                CGContextAddLineToPoint(ctx, a1.x, a1.y);
                
                // draw bézier curves
                CGContextAddCurveToPoint(ctx, c1, a1.y, c1, a2.y, a2.x, a2.y);
                CGContextAddCurveToPoint(ctx, c2, a2.y, c2, a3.y, a3.x, a3.y);
                
            }
            
        }
        // complete grid line to end of grid
        CGContextAddLineToPoint(ctx, gridSize.width, y);
    }
    // stroke path
    CGContextStrokePath(ctx);
    
    [_scene gridDidFinishDrawing];
}

- (void)dealloc
{
    free(curveArrayX);
    free(curveArrayY);
    free(tickMarksX);
    free(tickMarksY);
    free(xBalls);
    free(yBalls);
}
@end
