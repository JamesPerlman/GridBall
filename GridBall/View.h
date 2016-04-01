//
//  View.h
//  GridBall
//
//  Created by James on 12/13/14.
//  Copyright (c) 2014 James. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SceneProtocol.h"

@interface View : UIView

@property (nonatomic, weak) id<Scene> scene;

@end