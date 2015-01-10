//
//  EntityView.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 10.01.15.
//  Copyright (c) 2015 Sergey Yuzepovich. All rights reserved.
//

#import "EntityView.h"

@implementation EntityView
{
    UIImageView *imageView;
}

-(instancetype)initWithImage:(UIImage*)image frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        frame.origin = CGPointZero;
        imageView = [[UIImageView alloc]initWithImage:image];
        [imageView setFrame:frame];
        [self addSubview: imageView];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *centeredX = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        NSLayoutConstraint *imageWidth = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetWidth(frame)];
        NSLayoutConstraint *imageHeight = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetHeight(frame)];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        
        NSLayoutConstraint *selfWidth = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetWidth(frame)];
        NSLayoutConstraint *selfHeight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:CGRectGetHeight(frame)];
        
        [self addConstraints:@[centeredX,top]];
        [self addConstraints:@[selfWidth,selfHeight]];
        [imageView addConstraints:@[imageWidth,imageHeight]];
    }
    
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touch");
}

@end
