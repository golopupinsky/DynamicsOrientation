//
//  StoreEntity.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 07.01.15.
//  Copyright (c) 2015 Sergey Yuzepovich. All rights reserved.
//

#import "StoreEntity.h"
#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"

@implementation StoreEntity
{
    ImagesLoadingStatus imagesLoaded;
}
+(NSDictionary*)attributeMapping
{
    return
    @{@"trackId":@"ID",
      @"screenshotUrls":@"phoneScreenshotURLs",
      @"ipadScreenshotUrls":@"tabletScreenshotURLs",
      @"artworkUrl60":@"iconSmallURL",
      @"artworkUrl100":@"iconMediumURL",
      @"artistName":@"artistName",
      @"price":@"price",
      @"formattedPrice":@"formattedPrice",
      @"version":@"version",
      @"description":@"desc",
      @"currency":@"currency",
      @"trackName":@"name",
      @"supportedDevices":@"supportedDevices"};
}


-(void)setIconSmallURL:(NSURL *)iconSmallURL
{
    _iconSmallURL = iconSmallURL;
    
    [self downloadImageAsync:iconSmallURL completion:^(UIImage *image) {
        self.iconSmall = image;
        self.blurredIcon = [image   applyBlurWithRadius:5/*40*/
                                    tintColor:[UIColor colorWithWhite:0.2 alpha:0.4]
                                    saturationDeltaFactor:1.8
                                    maskImage:nil];

        imagesLoaded |= iconSmall;
        [self attemptImagesCompletionBlock];
    }];
}

-(void)setIconMediumURL:(NSURL *)iconMediumURL
{
    _iconMediumURL = iconMediumURL;
    
    [self downloadImageAsync:iconMediumURL completion:^(UIImage *image) {
        self.iconMedium = image;
        imagesLoaded |= iconMedium;
        [self attemptImagesCompletionBlock];
    }];
}


-(void)setPhoneScreenshotURLs:(NSArray *)phoneScreenshotURLs
{
    _phoneScreenshotURLs = phoneScreenshotURLs;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.phoneScreenshots = [[NSMutableArray alloc]initWithCapacity:_phoneScreenshotURLs.count];
        for (NSString *url in _phoneScreenshotURLs) {
            [self downloadImageAsync:[NSURL URLWithString: url] completion:^(UIImage *image) {
                [self.phoneScreenshots addObject:image];
            }];
        }
    }
}

-(void)setTabletScreenshotURLs:(NSArray *)tabletScreenshotURLs
{
    _tabletScreenshotURLs = tabletScreenshotURLs;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.tabletScreenshots = [[NSMutableArray alloc]initWithCapacity:_tabletScreenshotURLs.count];
        for(NSString *url in _tabletScreenshotURLs)
        {
            [self downloadImageAsync:[NSURL URLWithString: url] completion:^(UIImage *image) {
                [self.tabletScreenshots addObject:image];
            }];
        }
    }
}

-(void)downloadImageAsync:(NSURL*)url completion:(void(^)(UIImage *image))block
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:
    ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        UIImage *img = [UIImage imageWithData:data];
        if(connectionError == nil)
        {
            if(block)
                block(img);
        }
        else
        {
            NSLog(@"%@",connectionError.localizedDescription);
        }
    }];
}

-(void)attemptImagesCompletionBlock
{
    if (imagesLoaded == allImages && self.imagesLoadCompletion != nil) {
        self.imagesLoadCompletion();
    }
}

-(BOOL)isTabletOnly
{
    if ([self.phoneScreenshotURLs count] == 0) {
        return true;
    }
    return false;
}

-(BOOL)isUniversal
{
    if([self.phoneScreenshotURLs count] != 0 && [self.tabletScreenshotURLs count] != 0){
        return true;
    }
    return false;
}

-(NSString *)formattedDeviceSupport
{
    if (self.isUniversal) {
        return @"Universal app";
    }
    if(self.isTabletOnly)
    {
        return @"iPad app";
    }
    
    return @"iPhone app";
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else {
        if(self.class != ((NSObject*)other).class){
            return NO;
        }
        
        return self.ID == ((StoreEntity*)other).ID;
    }
}

- (NSUInteger)hash
{
    return [[NSNumber numberWithUnsignedInteger:self.ID] hash];
}

@end
