//
//  EntityView.h
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 10.01.15.
//  Copyright (c) 2015 Sergey Yuzepovich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreEntity.h"

@interface EntityView : UIView

-(instancetype)initWithEntity:(StoreEntity*)entity frame:(CGRect)frame behaviours:(NSArray*)behaviours;

@end
