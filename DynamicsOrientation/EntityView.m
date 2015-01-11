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
    UIImageView *imageView;
    CGFloat initialSize;
    BOOL isExpanded;
    NSLayoutConstraint *selfWidth;
    NSLayoutConstraint *selfHeight;
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
    
    [self addSubview: imageView];

    imageView.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *centeredX = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *imageWidth = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetWidth(imageView.frame)];
    NSLayoutConstraint *imageHeight = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetHeight(imageView.frame)];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];

    [self addConstraints:@[centeredX,top]];
    [imageView addConstraints:@[imageWidth,imageHeight]];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = CGRectGetWidth(self.bounds)/5;
}

-(void)initSelf
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetWidth(self.bounds)/5;
    self.backgroundColor = [UIColor grayColor];

    self.translatesAutoresizingMaskIntoConstraints = NO;
    selfWidth = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetWidth(self.frame)];
    selfHeight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetHeight(self.frame)];
    [self addConstraints:@[selfWidth,selfHeight]];
    initialSize = CGRectGetWidth(self.frame);
    isExpanded = false;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBounds];
//    anim.toValue = [NSValue valueWithCGRect:isExpanded ? initialSize : CGRectMake(0, 0, 400, 400)];
//    [self pop_addAnimation:anim forKey:@"size"];
    
    if(!isExpanded)
    {
        for(UIDynamicBehavior* beh in behaviours)
        {
            [beh performSelector:@selector(removeItem:) withObject:self];
        }
    }
    else
    {
        for(UIDynamicBehavior* beh in behaviours)
        {
            [beh performSelector:@selector(addItem:) withObject:self];
        }
    }
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
//    layoutAnimation.springSpeed = 20.0f;
//    layoutAnimation.springBounciness = 15.0f;
    layoutAnimation.toValue = @( isExpanded ? initialSize : 400 );
    [selfWidth pop_addAnimation:layoutAnimation forKey:@"selfWidth"];
    [selfHeight pop_addAnimation:layoutAnimation forKey:@"selfHeight"];
    isExpanded = !isExpanded;
}

@end
