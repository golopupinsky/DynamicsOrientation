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

static const CGFloat ADDITION_DELAY = 1.0;

@interface ViewController ()
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
    
    self.searchTextView.text = @"sergey yuzepovich";
    
    [self initializeRestkit];
    [self loadEntities];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissSearchView];
    });
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panGesture];
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
    __block NSUInteger finishedRequests = 0;
    __weak typeof(self) weakSelf = self;
    void (^requestSuccessfullBlock)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) =
    ^void(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [weakSelf.entities addObjectsFromArray: mappingResult.array];

//        if (finishedRequests == 0) {
//            finishedRequests++;
//            return;
//        }
        
        for (StoreEntity *entity in mappingResult.array)
        {
            __weak typeof(entity) weakEntity = entity;
            entity.imagesLoadCompletion = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf addEntity:weakEntity];
                });
            };
        }
    };

    
    NSDictionary *queryParams = @{@"term" : self.searchTextView.text,
                                  @"media": @"software"};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/search"
                                           parameters:queryParams
                                              success:requestSuccessfullBlock
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Error occured: %@", error);
                                              }];
    queryParams = @{@"term" : self.searchTextView.text,
                      @"media" : @"software",
                      @"entity": @"iPadSoftware"};
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/search"
                                           parameters:queryParams
                                              success:requestSuccessfullBlock
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Error occured: %@", error);
                                              }];
}



-(void)addEntity:(StoreEntity*)entity
{
    static NSMutableArray *delayedEntities;
    if(delayedEntities == nil){
        delayedEntities = [[NSMutableArray alloc]init];
    }
    [delayedEntities addObject:entity];
    
    static NSTimeInterval lastAdditionTime = 0.0;
    NSTimeInterval now = CACurrentMediaTime();
    if (lastAdditionTime < 0.0001 || (now - lastAdditionTime) > ADDITION_DELAY) {

        [self performEntitiesAddition:delayedEntities withDelay:0];
        lastAdditionTime = now;
    }
    else
    {
        CGFloat delay = ADDITION_DELAY * 1.5;
        [self performEntitiesAddition:delayedEntities withDelay:delay];
        lastAdditionTime = now+delay;
    }
    
}

-(void)performEntitiesAddition:(NSMutableArray *)entities withDelay:(NSTimeInterval)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimating];
        [(MotionDynamicsView*)self.view addSubviewsWithEntities: entities totalCount:self.entities.count];
        [entities removeAllObjects];
        
    });
}

-(void)dismissSearchView
{
    POPBasicAnimation *layoutAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.toValue = @( -CGRectGetHeight(self.searchView.frame) );
    [self.searchViewTopConstraint pop_addAnimation:layoutAnimation forKey:@"searchDismiss"];
}

-(void)presentSearchView
{
    POPBasicAnimation *layoutAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.toValue = @( 0 );
    [self.searchViewTopConstraint pop_addAnimation:layoutAnimation forKey:@"searchPresent"];
}

-(void)pan:(UIPanGestureRecognizer*)pan
{
    static CGFloat startingTop;
    CGFloat h = CGRectGetHeight(self.searchView.frame);

    if (pan.state == UIGestureRecognizerStateBegan) {
        startingTop = self.searchViewTopConstraint.constant;
    }
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint panDistance = [pan translationInView:self.view];
        self.searchViewTopConstraint.constant = MIN(0, startingTop + panDistance.y);
    }
    
    if(pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateFailed || pan.state == UIGestureRecognizerStateCancelled){

        if (self.searchViewTopConstraint.constant < -h/10 ) {
            [self dismissSearchView];
        }
        else{
            [self presentSearchView];
        }
    }
}
@end
