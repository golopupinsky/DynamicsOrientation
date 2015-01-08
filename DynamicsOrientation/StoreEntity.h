//
//  StoreEntity.h
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 07.01.15.
//  Copyright (c) 2015 Sergey Yuzepovich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StoreEntity : NSObject

@property(nonatomic) NSUInteger ID;
@property(nonatomic) NSArray *phoneScreenshotURLs;
@property(nonatomic) NSArray *tabletScreenshotURLs;
//@property(nonatomic) NSURL *iconSmallURL;
@property(nonatomic) NSURL *iconMediumURL;
//@property(nonatomic) NSURL *iconLargeURL;
@property(nonatomic) NSString *artistName;
@property(nonatomic) float price;
@property(nonatomic) NSString *formattedPrice;
@property(nonatomic) NSString *version;
@property(nonatomic) NSString *desc;
@property(nonatomic) NSString *currency;
@property(nonatomic) NSString *name;

//@property(nonatomic) UIImage *iconSmall;
@property(nonatomic) UIImage *iconMedium;
//@property(nonatomic) UIImage *iconLarge;

@property(nonatomic) NSMutableArray *phoneScreenshots;
@property(nonatomic) NSMutableArray *tabletScreenshots;

//@property (nonatomic, copy) void (^smallIconLoaded)(void);
@property (nonatomic, copy) void (^mediumIconLoaded)(void);
//@property (nonatomic, copy) void (^largeIconLoaded)(void);

+(NSDictionary*)attributeMapping;

@end
