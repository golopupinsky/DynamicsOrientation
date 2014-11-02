//
//  MotionDynamicsView.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 02.11.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "MotionDynamicsView.h"
#import <CoreMotion/CoreMotion.h>

@implementation MotionDynamicsView
{
    UIDynamicAnimator* _animator;
    UIGravityBehavior* _gravity;
    UICollisionBehavior* _collision;
    NSMutableArray *dynamicItems;

}

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
    
    [self createDynamicViews];
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    _gravity = [[UIGravityBehavior alloc] initWithItems:dynamicItems];
    [_animator addBehavior:_gravity];
    
    _collision = [[UICollisionBehavior alloc]
                  initWithItems:dynamicItems];
    _collision.translatesReferenceBoundsIntoBoundary = YES;
    [_animator addBehavior:_collision];


}

-(void) createDynamicViews
{
    const NSUInteger N = 15;
    
    dynamicItems = [[NSMutableArray alloc]initWithCapacity:N];
    
    for(int i=0; i< N; i++)
    {
        
        UIView* square = [[UIView alloc] initWithFrame:CGRectMake(drand48() * 100,
                                                                  drand48() * 100,
                                                                  20 + drand48() * 100,
                                                                  20 + drand48() * 100)];
        square.layer.cornerRadius = 8;
        
        square.backgroundColor = [UIColor grayColor];
        [self insertSubview:square atIndex:[self.subviews count] ];
        [dynamicItems addObject: square];
    }
}

-(void)processMotion:(NSNotification*)notification
{
    const float USER_ACCELERATION_MULTIPLIER = 4;//incerasing user input weight gives nicer effect
    
    CMDeviceMotion *data = notification.userInfo[@"deviceMotionData"];

    CGVector v;

    v.dx = data.gravity.x + (data.userAcceleration.y + data.userAcceleration.x) * USER_ACCELERATION_MULTIPLIER;
    v.dy = -data.gravity.y + (data.userAcceleration.y + data.userAcceleration.x) * USER_ACCELERATION_MULTIPLIER;
    
    //normalizing - does not work well
//    float sum = abs( v.dx ) + abs( v.dy );;
//    if(sum > 0.01)
//    {
//        v.dx /= sum;
//        v.dy /= sum;
//    }
    
    _gravity.gravityDirection = v;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
