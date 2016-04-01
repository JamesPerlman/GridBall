//
//  ViewController.h
//  GridBall
//
//  Created by James on 12/13/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CADisplayLink.h>
#import "Grid.h"
#import "GravityField.h"

@interface SceneController : UIViewController<Scene> {
    CADisplayLink   *timer;
    BallData        *balls;
    Grid            *grid;
    GravityField    *field;
    bool            gridDrawing, physicsProcessing;
}

- (void) createScene;

- (void) gridDidFinishUpdating;

- (void) gridDidFinishDrawing;

- (void) physicsDidFinishProcessing;


@property (nonatomic, readonly) BallData *ballArray;

@end

