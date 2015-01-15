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
//      @"artworkUrl512":@"iconLargeURL",
      @"artistName":@"artistName",
      @"price":@"price",
      @"formattedPrice":@"formattedPrice",
      @"version":@"version",
      @"description":@"desc",
      @"currency":@"currency",
      @"trackName":@"name"};
}


-(void)setIconSmallURL:(NSURL *)iconSmallURL
{
    _iconSmallURL = iconSmallURL;
    
    [self downloadImageAsync:iconSmallURL completion:^(UIImage *image) {
        self.iconSmall = image;
        self.blurredIcon = [image   applyBlurWithRadius:5/*40*/
                                    tintColor:[UIColor colorWithWhite:0.5 alpha:0.4]
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

//-(void)setIconLargeURL:(NSURL *)iconLargeURL
//{
//    _iconLargeURL = iconLargeURL;
//    [self downloadImageAsync:iconLargeURL completion:^(UIImage *image) {
//        self.iconLarge = image;
//        imagesLoaded |= iconLarge;
//        [self attemptImagesCompletionBlock];
//    }];
//}

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
        if(connectionError == nil && block != nil)
        {
            block(img);
        }
    }];
}

-(void)attemptImagesCompletionBlock
{
    if (imagesLoaded == allImages && self.imagesLoadCompletion != nil) {
        self.imagesLoadCompletion();
    }
}

@end
