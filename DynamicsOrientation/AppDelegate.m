//
//  AppDelegate.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 01.11.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreMotion/CoreMotion.h>

@interface AppDelegate ()
{
    CMMotionManager *manager;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupMotionObserving];
    return YES;
}

-(void)setupMotionObserving
{
    manager = [[CMMotionManager alloc]init];
    
    if (manager.deviceMotionAvailable) {
        manager.deviceMotionUpdateInterval = 0.1f;//0.01f;
        [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                     withHandler:^(CMDeviceMotion *data, NSError *error) {
                                         
                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"MotionDetected" object:nil userInfo:@{@"deviceMotionData":data}];
                                     }];
    }
    

}
@end
