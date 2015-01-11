//
//  EntityView.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 10.01.15.
//  Copyright (c) 2015 Sergey Yuzepovich. All rights reserved.
//

#import "EntityView.h"
#import <pop/POP.h>

@implementation EntityView
{
    UIView *container;
    UIImageView *imageView;
    CGFloat initialSize;
    BOOL isExpanded;
    NSLayoutConstraint *containerWidth;
    NSLayoutConstraint *containerHeight;
    NSArray *behaviours;
}

-(instancetype)initWithImage:(UIImage*)image frame:(CGRect)frame behaviours:(NSArray*)behs
{
    self = [super initWithFrame:frame];
    if(self)
    {
        behaviours = behs;
        [self initSelf];
        [self initImageView:image];
    }
    
    return self;
}

-(void)initImageView:(UIImage*)image
{
    imageView = [[UIImageView alloc]initWithImage:image];
    [imageView setFrame:self.frame];
    
    [container addSubview: imageView];

    imageView.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *centeredX = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *imageWidth = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetWidth(imageView.frame)];
    NSLayoutConstraint *imageHeight = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetHeight(imageView.frame)];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];

    [container addConstraints:@[centeredX,top]];
    [imageView addConstraints:@[imageWidth,imageHeight]];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = CGRectGetWidth(self.bounds)/5;
}

-(void)initSelf
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetWidth(self.bounds)/5;
    self.clipsToBounds = NO;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;

    container = [[UIView alloc]init];
    container.layer.masksToBounds = YES;
    container.layer.cornerRadius = CGRectGetWidth(self.bounds)/5;
    [self addSubview:container];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    container.backgroundColor = [UIColor lightGrayColor];

    containerWidth = [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetWidth(self.frame)];
    containerHeight = [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetHeight(self.frame)];
    [container addConstraints:@[containerWidth,containerHeight]];
    
    NSLayoutConstraint *selfWidth = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetWidth(self.frame)];
    NSLayoutConstraint *selfHeight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetHeight(self.frame)];
    [self addConstraints:@[selfWidth,selfHeight]];

    initialSize = CGRectGetWidth(self.frame);
    isExpanded = false;
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if(!isExpanded)
//    {
//        for(UIDynamicBehavior* beh in behaviours)
//        {
//            [beh performSelector:@selector(removeItem:) withObject:self];
//        }
//    }
//    else
//    {
//        for(UIDynamicBehavior* beh in behaviours)
//        {
//            [beh performSelector:@selector(addItem:) withObject:self];
//        }
//    }
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
//    layoutAnimation.springSpeed = 20.0f;
//    layoutAnimation.springBounciness = 15.0f;
    layoutAnimation.toValue = @( isExpanded ? initialSize : 400 );
    [containerWidth pop_addAnimation:layoutAnimation forKey:@"selfWidth"];
    [containerHeight pop_addAnimation:layoutAnimation forKey:@"selfHeight"];
    isExpanded = !isExpanded;
}

@end
