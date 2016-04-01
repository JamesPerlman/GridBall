//
//  ViewController.m
//  GridBall
//
//  Created by James on 12/13/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#import "constants.h"

#import "SceneController.h"

#import "View.h"

@interface SceneController ()

@end

@implementation SceneController
@synthesize grid;
@synthesize ballArray = balls;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self createScene];
    }
    return self;
}

- (void)createScene {
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    
    // allocate memory for balls
    balls = calloc(MAXIMUM_BALLS, sizeof(BallData));
    
    // create first ball
    BallData ball = MakeBall(50, screen.width/4.0, screen.height/4.0);
    memcpy(balls, &ball, sizeof(ball));
    
    ball = MakeBall(50, screen.width/2.0, screen.height/2.0);
    
    
    memcpy(&balls[1], &ball, sizeof(ball));
    
    // create grid
    grid = [[Grid alloc] initWithSize:screen andSquareSize:20.0];
    
    // set grid's reference to scene
    grid.scene = self;
    
    // create gravity field
    field = [[GravityField alloc] init];
    
    field.scene = self;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!gridDrawing) {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint pos = [touch locationInView:self.view];
        BallData *ball = &balls[0];
        ball->position = pos;
        
        [grid update];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    View *view = (View*)[self view];
    view.scene = self;
    [grid update];
}

- (void) gridDidFinishUpdating {
    gridDrawing = true;
    [[self view] setNeedsDisplay];
}

- (void) gridDidFinishDrawing {
    gridDrawing = false;
}

- (void) gravityFieldDidFinishProcessing {
    physicsProcessing = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    free(balls);
}
@end
