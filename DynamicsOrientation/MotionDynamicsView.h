//
//  MotionDynamicsView.h
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 02.11.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MotionDynamicsView : UIView

-(void) addSubviewsWithEntities:(NSArray*)entities totalCount:(NSUInteger)count;
-(void) removeEntities;

@end
