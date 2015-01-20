//
//  DownloadManager.h
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 20.01.15.
//  Copyright (c) 2015 Sergey Yuzepovich. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Download : NSObject
@property(nonatomic) NSURL *url;
@property(nonatomic,copy) void(^completion)(NSData *data);

-(instancetype)initWithUrl:(NSURL*)url completion:(void(^)(NSData *data))block;
@end


@interface DownloadManager : NSObject
+(void)enqueueDonwload:(Download*)download;
+(void)cancelAll;
@end
