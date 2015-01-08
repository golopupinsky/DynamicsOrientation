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
    UIDynamicItemBehavior* _rotationRestrict;
    NSUInteger _totalCount;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

-(void) setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processMotion:) name:@"MotionDetected" object:nil];
}

-(void) addSubviewsWithImages:(NSArray*)images totalCount:(NSUInteger)count;
{
    _totalCount = count;
    NSMutableArray *newItems = [[NSMutableArray alloc]init];
    [self createDynamicViews:images views:newItems];
    
    if (_animator == nil) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        _gravity = [[UIGravityBehavior alloc] initWithItems:newItems];
        [_animator addBehavior:_gravity];
        
        _collision = [[UICollisionBehavior alloc] initWithItems:newItems];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        [_animator addBehavior:_collision];
        
        _rotationRestrict = [[UIDynamicItemBehavior alloc] initWithItems:newItems];
        _rotationRestrict.elasticity = 0.6;
        _rotationRestrict.allowsRotation = false;
        [_animator addBehavior:_rotationRestrict];
    }
    
    for(id i in newItems)
    {
        [_gravity addItem:i];
        [_collision addItem:i];
        [_rotationRestrict addItem:i];
    }

}

-(void) createDynamicViews:(NSArray*)images views:(NSMutableArray*)dynamicViews
{
    
    for(int i=0; i< [images count]; i++)
    {
        NSUInteger sz = CGRectGetWidth([UIScreen mainScreen].bounds) * CGRectGetHeight([UIScreen mainScreen].bounds) / MAX(5,_totalCount);
        sz = MIN(80, sz);
        UIImageView *square = [[UIImageView alloc]initWithFrame:CGRectMake(drand48() * 500,
                                                                           drand48() * 500,
                                                                           sz,
                                                                           sz)];
        square.layer.masksToBounds = YES;
        square.image = images[i];
        square.layer.cornerRadius = CGRectGetWidth(square.bounds)/5;
        
        square.backgroundColor = [UIColor grayColor];
        [self insertSubview:square atIndex:[self.subviews count] ];
        [dynamicViews addObject:square];
    }
}

-(void)processMotion:(NSNotification*)notification
{
    const float USER_ACCELERATION_MULTIPLIER = 4;//incerasing user input weight gives nicer effect
    
    CMDeviceMotion *data = notification.userInfo[@"deviceMotionData"];

    CGVector v;

    v.dx = data.gravity.x + (data.userAcceleration.y + data.userAcceleration.x) * USER_ACCELERATION_MULTIPLIER;
    v.dy = -data.gravity.y + (data.userAcceleration.y + data.userAcceleration.x) * USER_ACCELERATION_MULTIPLIER;
    
    _gravity.gravityDirection = v;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
