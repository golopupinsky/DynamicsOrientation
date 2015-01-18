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
#import <QuartzCore/CAAnimation.h>
#import <pop/POP.h>

static NSString *LAST_QUERY = @"LAST_QUERY";

@interface ViewController ()<UITextFieldDelegate>
    @property(nonatomic, strong) NSMutableArray *entities;
    @property(weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
    @property (weak, nonatomic) IBOutlet UIView *searchView;
    @property (weak, nonatomic) IBOutlet UITextField *searchTextView;
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewTopConstraint;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.entities = [[NSMutableArray alloc]init];

    //@"https://itunes.apple.com/search?term=jack+johnson&limit=200"
    
    self.searchTextView.delegate = self;
    self.searchTextView.text = [self fetchLastSearchQuery];
    
    [self initializeRestkit];
    [self loadEntities];
}

-(NSString*)fetchLastSearchQuery
{
    NSString *lastQuery = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:LAST_QUERY];
    if (lastQuery == nil) {
        lastQuery = @"sergey yuzepovich";
    }
    
    return lastQuery;
}

-(void)storeLastSearchQuery:(NSString*)query
{
    [[NSUserDefaults standardUserDefaults] setObject:query forKey:LAST_QUERY];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

-(void)loadEntities
{
    [(MotionDynamicsView*)self.view removeEntities];
    [self.loadingIndicator startAnimating];
    
    void (^requestSuccessfullBlock)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) =
    ^void(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        for (StoreEntity *entity in mappingResult.array)
        {
            if( ![self.entities containsObject:entity] )
            {
                [self.entities addObject:entity];
                
                __weak typeof(entity) weakEntity = entity;
                entity.imagesLoadCompletion = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addEntity:weakEntity];
                    });
                };
            }
        }
    };
    void (^requestFailureBlock)(RKObjectRequestOperation *operation, NSError *error) =
    ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error occured: %@", error);
    };

    NSDictionary *queryParams = @{@"term" : self.searchTextView.text,
                                  @"media": @"software"};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/search"
                                           parameters:queryParams
                                              success:requestSuccessfullBlock
                                              failure:requestFailureBlock];
    
    NSDictionary *queryParams2 = @{@"term" : self.searchTextView.text,
                                   @"media" : @"software",
                                   @"entity": @"iPadSoftware"};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/search"
                                           parameters:queryParams2
                                              success:requestSuccessfullBlock
                                              failure:requestFailureBlock];

    [self storeLastSearchQuery:self.searchTextView.text];
}



-(void)addEntity:(StoreEntity*)entity
{
    [self.loadingIndicator stopAnimating];
    [(MotionDynamicsView*)self.view addSubviewsWithEntities: @[entity] totalCount:self.entities.count];
    [self.view bringSubviewToFront: self.searchView.superview];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [self.searchTextView resignFirstResponder];
    [self loadEntities];
    
    return YES;
}

@end
