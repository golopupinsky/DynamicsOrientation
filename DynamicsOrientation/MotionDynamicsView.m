//
//  MotionDynamicsView.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 02.11.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "MotionDynamicsView.h"
#import <CoreMotion/CoreMotion.h>
#import "EntityView.h"

@implementation MotionDynamicsView
{
    UIDynamicAnimator* _animator;
    UIGravityBehavior* _gravity;
    UICollisionBehavior* _collision;
    UIDynamicItemBehavior* _rotationRestrict;
    NSUInteger _totalCount;
    NSTimer *_elementsPositionsFixTimer;
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
    
    _elementsPositionsFixTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(fixPositions) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_elementsPositionsFixTimer forMode:NSRunLoopCommonModes];
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    _gravity = [[UIGravityBehavior alloc] initWithItems:nil];
    [_animator addBehavior:_gravity];
    
    _collision = [[UICollisionBehavior alloc] initWithItems:nil];
    _collision.translatesReferenceBoundsIntoBoundary = YES;
    [_animator addBehavior:_collision];
    
    _rotationRestrict = [[UIDynamicItemBehavior alloc] initWithItems:nil];
    _rotationRestrict.elasticity = 0.6;
    _rotationRestrict.allowsRotation = false;
    [_animator addBehavior:_rotationRestrict];
}

-(void)fixPositions
{
    CGRect screen = [UIScreen mainScreen].bounds;

    for (UIView* i in _gravity.items) {
        CGRect rectToTest = CGRectInset(i.frame,CGRectGetWidth(i.frame)/2, CGRectGetHeight(i.frame)/2);
        
        if (!CGRectContainsRect(screen,  rectToTest)) {
            [self removeItem:i];
            i.frame = CGRectMake(CGRectGetWidth(screen)/2, CGRectGetHeight(screen)/2, CGRectGetWidth(i.bounds), CGRectGetHeight(i.bounds));
            [self addItem:i];
        }
    }
}


-(void)removeItem:(UIView*)i
{
    [_gravity removeItem:i];
    [_collision removeItem:i];
    [_rotationRestrict removeItem:i];
}

-(void)addItem:(UIView*)i
{
    [_gravity addItem:i];
    [_collision addItem:i];
    [_rotationRestrict addItem:i];
}

-(void) addSubviewsWithImages:(NSArray*)images totalCount:(NSUInteger)count;
{
    _totalCount = count;
    
    for(int i=0; i< [images count]; i++)
    {
        NSUInteger sz = CGRectGetWidth([UIScreen mainScreen].bounds) * CGRectGetHeight([UIScreen mainScreen].bounds) / MAX(5,_totalCount);
        sz = MIN(80, sz);
        EntityView *square = [[EntityView alloc] initWithImage:images[i]
                                                frame:CGRectMake(drand48() * 500,drand48() * 500, sz, sz)];
        square.layer.masksToBounds = YES;
        square.layer.cornerRadius = CGRectGetWidth(square.bounds)/5;
        square.backgroundColor = [UIColor grayColor];
        [self insertSubview:square atIndex:[self.subviews count] ];
        [self addItem:square];
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
    [_elementsPositionsFixTimer invalidate];
}


@end
