//
//  DownloadManager.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 20.01.15.
//  Copyright (c) 2015 Sergey Yuzepovich. All rights reserved.
//

#import "DownloadManager.h"

static const NSUInteger MAX_CONCURRENT_DOWNLOADS = 10;

@implementation Download
-(instancetype)initWithUrl:(NSURL*)url completion:(void(^)(NSData *data))block
{
    self = [super init];
    if(self){
        self.url = url;
        self.completion = block;
    }
    return self;
}
@end


@implementation DownloadManager
{
    NSMutableArray *queuedDownloads;
    NSMutableArray *startedDownloads;
    NSLock *lock;
    NSOperationQueue *downloadsQueue;
}

-(instancetype)init
{
    self = [super init];
    
    if(self)
    {
        queuedDownloads = [[NSMutableArray alloc]init];
        startedDownloads = [[NSMutableArray alloc]init];
        lock = [[NSLock alloc]init];
        downloadsQueue = [[NSOperationQueue alloc]init];
    }
    return self;
}

+(instancetype)instance
{
    static DownloadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    
    return instance;
}

+(void)enqueueDonwload:(Download*)download
{
    [[DownloadManager instance]->queuedDownloads addObject:download];
    [[DownloadManager instance] attemptNewDownload];
}

+(void)cancelAll
{
    [[DownloadManager instance]->queuedDownloads removeAllObjects];
}


-(NSURL*)dequeueDownload
{
    id obj = nil;
    if( [[DownloadManager instance]->queuedDownloads count] != 0){
        obj = [[DownloadManager instance]->queuedDownloads firstObject];
        [[DownloadManager instance]->queuedDownloads removeObject:obj];
        NSLog(@"Queued downloads:%ld",[[DownloadManager instance]->queuedDownloads count]);
    }
    
    return obj;
}

-(void)downloadFinished:(Download*)download
{
    [lock lock];
        [startedDownloads removeObject:download];
    [lock unlock];
    
    NSLog(@"Downloads in progress:%ld",[[DownloadManager instance]->startedDownloads count]);
    [self attemptNewDownload];
}

-(void)attemptNewDownload
{
    [lock lock];
        if( [startedDownloads count] < MAX_CONCURRENT_DOWNLOADS ){
            id newDownload = [self dequeueDownload];
            if(newDownload != nil){
                [self startNewDownload:newDownload];
            }
        }
    [lock unlock];
}

-(void)startNewDownload:(Download*)download
{
    [startedDownloads addObject:download];
    [self downloadAsync:download.url completion:^(NSData *data) {
        [self downloadFinished:download];
        if(download.completion != nil)
        {
            download.completion(data);
        }
    }];
    
}

-(void)downloadAsync:(NSURL*)url completion:(void(^)(NSData *data))block
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:downloadsQueue completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {

         if(connectionError == nil)
         {
             if(block)
                 block(data);
         }
         else
         {
             NSLog(@"%@",connectionError.localizedDescription);
         }
     }];
}

@end
