//
//  StoreEntity.h
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 07.01.15.
//  Copyright (c) 2015 Sergey Yuzepovich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    iconSmall           =   (1 << 0),
    iconMedium          =   (1 << 1),
//    phoneScreenshots    =   (1 << 3),
//    padScreenshots      =   (1 << 4),
    allImages           =   iconSmall|iconMedium//|phoneScreenshots|padScreenshots
} ImagesLoadingStatus;

@interface StoreEntity : NSObject

@property(nonatomic) NSUInteger ID;
@property(nonatomic) NSArray *phoneScreenshotURLs;
@property(nonatomic) NSArray *tabletScreenshotURLs;
@property(nonatomic) NSURL *iconSmallURL;
@property(nonatomic) NSURL *iconMediumURL;
@property(nonatomic) NSString *artistName;
@property(nonatomic) CGFloat price;
@property(nonatomic) NSString *formattedPrice;
@property(nonatomic) NSString *version;
@property(nonatomic) NSString *desc;
@property(nonatomic) NSString *currency;
@property(nonatomic) NSString *name;
@property(nonatomic) NSArray *supportedDevices;

@property(nonatomic) UIImage *iconSmall;
@property(nonatomic) UIImage *iconMedium;
@property(nonatomic) UIImage *blurredIcon;

@property(nonatomic) NSMutableArray *screenshots;

@property(nonatomic) BOOL isTabletOnly;
@property(nonatomic) BOOL isUniversal;
@property(nonatomic) NSString *formattedDeviceSupport;

@property (nonatomic, copy) void (^imagesLoadCompletion)(void);

+(NSDictionary*)attributeMapping;

@end
