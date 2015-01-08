//
//  ViewController.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 01.11.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "ViewController.h"
#import "MotionDynamicsView.h"
#import <RestKit/RestKit.h>
#import "StoreEntity.h"

@interface ViewController ()
    @property(nonatomic, strong) NSMutableArray *entities;
    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.entities = [[NSMutableArray alloc]init];

    //@"https://itunes.apple.com/search?term=jack+johnson&limit=200"
    
    [self initializeRestkit];
    [self loadApps];
}


-(void)initializeRestkit
{
    NSURL *apiUrl = [NSURL URLWithString:@"https://itunes.apple.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:apiUrl];
    RKObjectManager *objectManager = [[RKObjectManager alloc]initWithHTTPClient:client];
    RKObjectMapping *storeEntityMapping = [RKObjectMapping mappingForClass:[StoreEntity class]];
    [storeEntityMapping addAttributeMappingsFromDictionary:[StoreEntity attributeMapping]];
    
    RKResponseDescriptor *responseDescriptor =  [RKResponseDescriptor    responseDescriptorWithMapping:storeEntityMapping
                                                                        method:RKRequestMethodGET
                                                                        pathPattern:@"/search"
                                                                            keyPath:@"results"
                                                                        statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:responseDescriptor];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/javascript"];
}

-(void)loadApps
{
    __block NSUInteger finishedRequests = 0;
    __weak typeof(self) weakSelf = self;
    void (^requestSuccessfullBlock)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) =
    ^void(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [weakSelf.entities addObjectsFromArray: mappingResult.array];

        if (finishedRequests == 0) {
            finishedRequests++;
            return;
        }
        
        for (StoreEntity *entity in self.entities)
        {
            __weak typeof(entity) weakEntity = entity;
            entity.mediumIconLoaded = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf addIcon:weakEntity.iconMedium];
                });
            };
        }
    };

    
    NSString *name = @"yuzepovich";
    
    NSDictionary *queryParams = @{@"term" : name,
                                  @"media" : @"software"};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/search"
                                           parameters:queryParams
                                              success: requestSuccessfullBlock
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Error occured: %@", error);
                                              }];
    queryParams = @{@"term" : name,
                      @"media" : @"software",
                      @"entity": @"iPadSoftware"};
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/search"
                                           parameters:queryParams
                                              success: requestSuccessfullBlock
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Error occured: %@", error);
                                              }];

}



-(void)addIcon:(UIImage*)icon
{
    [(MotionDynamicsView*)self.view addSubviewsWithImages: @[icon] totalCount:self.entities.count];
    [self.loadingIndicator stopAnimating];
}
@end
