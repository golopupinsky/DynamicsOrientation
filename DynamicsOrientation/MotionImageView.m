//
//  MotionImageView.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 02.11.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "MotionImageView.h"
#import <CoreMotion/CoreMotion.h>

@implementation MotionImageView
{
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


-(void) setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processMotion:) name:@"MotionDetected" object:nil];
}

-(void)processMotion:(NSNotification*)notification
{
    CMDeviceMotion *data = notification.userInfo[@"deviceMotionData"];
    double rotation = atan2(data.gravity.x, data.gravity.y) - M_PI;
    self.transform = CGAffineTransformMakeRotation(rotation);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
