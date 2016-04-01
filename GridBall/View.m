//
//  View.m
//  GridBall
//
//  Created by James on 12/13/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#import "View.h"
#import "Grid.h"
@implementation View
@synthesize scene;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (scene.grid) {
        [[scene grid] drawToContext:UIGraphicsGetCurrentContext()];
    }
}


@end
