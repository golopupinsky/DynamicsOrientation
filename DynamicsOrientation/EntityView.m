//
//  EntityView.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 10.01.15.
//  Copyright (c) 2015 Sergey Yuzepovich. All rights reserved.
//

#import "EntityView.h"
#import <pop/POP.h>
#import <QuartzCore/QuartzCore.h>

#define EXPANDED_SIZE MIN( CGRectGetWidth([UIScreen mainScreen].bounds)*0.95, 400.0)

@implementation EntityView
{
    UIView *container;
    UIImageView *iconView;
    UIImageView *backgroundView;
    CGFloat initialSize;
    BOOL isExpanded;
    NSLayoutConstraint *containerWidth;
    NSLayoutConstraint *containerHeight;
    NSArray *behaviours;
}

-(instancetype)initWithEntity:(StoreEntity*)entity frame:(CGRect)frame behaviours:(NSArray*)behs
{
    self = [super initWithFrame:frame];
    if(self)
    {
        behaviours = behs;
        [self initSelf:frame];
        [self initImageViews:entity];
        [self popIn];
    }
    
    return self;
}

-(void)initImageViews:(StoreEntity*)entity
{
    //setting up background
    backgroundView = [[UIImageView alloc]initWithFrame:self.frame];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundView.image = entity.blurredIcon;
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview: backgroundView];
    
    //background constraints
    NSLayoutConstraint *backgroundCenteredX = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *backgroundCenteredY = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    NSLayoutConstraint *backgroundLeft = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-80.0];
    NSLayoutConstraint *backgroundRight = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeRight multiplier:1.0 constant:80.0];
    NSLayoutConstraint *backgroundTop = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeTop multiplier:1.0 constant:-80.0];
    NSLayoutConstraint *backgroundBottom = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeBottom multiplier:1.0 constant:80.0];
    [container addConstraints:@[backgroundCenteredX,backgroundCenteredY,backgroundLeft,backgroundRight,backgroundTop,backgroundBottom]];
    
    //setting up icon
    iconView = [[UIImageView alloc]initWithImage:entity.iconMedium];
    [iconView setFrame:self.frame];
    [container addSubview: iconView];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;

    //icon constraints
    NSLayoutConstraint *iconCenteredX = [NSLayoutConstraint constraintWithItem:iconView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *iconWidth = [NSLayoutConstraint constraintWithItem:iconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetWidth(iconView.frame)];
    NSLayoutConstraint *iconHeight = [NSLayoutConstraint constraintWithItem:iconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetHeight(iconView.frame)];
    NSLayoutConstraint *iconTop = [NSLayoutConstraint constraintWithItem:iconView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [container addConstraints:@[iconCenteredX,iconTop]];
    [iconView addConstraints:@[iconWidth,iconHeight]];

    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = CGRectGetWidth(self.bounds)/5;
}

-(void)initSelf:(CGRect)frame
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetWidth(self.bounds)/5;
    self.clipsToBounds = NO;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;

    container = [[UIView alloc]init];
    container.layer.masksToBounds = YES;
    container.clipsToBounds = YES;
    container.layer.cornerRadius = CGRectGetWidth(self.bounds)/5;
    [self addSubview:container];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    container.backgroundColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [container addGestureRecognizer:tapGesture];
    
    containerWidth = [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetWidth(CGRectZero)];
    containerHeight = [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetHeight(CGRectZero)];
    [container addConstraints:@[containerWidth,containerHeight]];
    
    NSLayoutConstraint *selfWidth = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetWidth(self.frame)];
    NSLayoutConstraint *selfHeight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetHeight(self.frame)];
    [self addConstraints:@[selfWidth,selfHeight]];

    initialSize = CGRectGetWidth(self.frame);
    isExpanded = false;
}

-(void)popIn
{
    containerWidth.constant = containerHeight.constant = 0;
    
    POPBasicAnimation *layoutAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.beginTime = CACurrentMediaTime() + 0.2;//overcoming ugly poping for a moment in top corner
    layoutAnimation.toValue = @( CGRectGetWidth(self.frame) );
    [containerWidth pop_addAnimation:layoutAnimation forKey:@"containerWidthInit"];
    [containerHeight pop_addAnimation:layoutAnimation forKey:@"containerHeightInit"];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *subview in self.subviews.reverseObjectEnumerator) {
        if (CGRectContainsPoint(subview.frame, point)) {
            return subview;
        }
    }
    return [super hitTest:point withEvent:event];
}

-(void)tapped:(UITapGestureRecognizer*)tap
{
    CGFloat centerX = CGRectGetWidth( UIScreen.mainScreen.bounds ) / 2;
    CGFloat centerY = CGRectGetHeight( UIScreen.mainScreen.bounds ) / 2;
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);

    if(!isExpanded)
    {
        for(UIDynamicBehavior* beh in behaviours)
        {
            [beh performSelector:@selector(removeItem:) withObject:self];
        }
        
        CGRect rect  = CGRectMake(centerX - EXPANDED_SIZE/2, centerY - EXPANDED_SIZE/2, w, h);
        
        POPSpringAnimation *centerAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        centerAnimation.toValue = [NSValue valueWithCGRect:rect];
        [self pop_addAnimation:centerAnimation forKey:@"centerExpand"];

        self.layer.zPosition = MAXFLOAT;//the only working way of making view topmost
    }
    else
    {
        POPSpringAnimation *centerAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        centerAnimation.toValue = [NSValue valueWithCGPoint: CGPointMake(centerX, centerY) ];
        centerAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished)
        {
            for(UIDynamicBehavior* beh in behaviours)
            {
                [beh performSelector:@selector(addItem:) withObject:self];
            }
            self.layer.zPosition -= MAXFLOAT;
        };

        [self pop_addAnimation:centerAnimation forKey:@"centerShrink"];
    }

//    [self.superview bringSubviewToFront:self]; //looks ugly

    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 20.0f;
    layoutAnimation.springBounciness = 5.0f;
    layoutAnimation.toValue = @( isExpanded ? initialSize : EXPANDED_SIZE );
    layoutAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished)
    {
        isExpanded = !isExpanded;
    };
    
    [containerWidth pop_addAnimation:layoutAnimation forKey:@"containerWidthChange"];
    [containerHeight pop_addAnimation:layoutAnimation forKey:@"containerHeightChange"];
}

@end
