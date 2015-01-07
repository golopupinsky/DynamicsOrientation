//
//  ViewController.m
//  DynamicsOrientation
//
//  Created by Sergey Yuzepovich on 01.11.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "ViewController.h"
#import "MotionDynamicsView.h"

@interface ViewController ()
    @property(nonatomic, strong) NSURLRequest *jsonRequest;
    @property(nonatomic, strong) NSMutableData *responseData;
    @property(nonatomic, strong) NSMutableArray *images;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.responseData = [NSMutableData data];
    self.images = [[NSMutableArray alloc]init];
    
    self.jsonRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://itunes.apple.com/search?term=sergey+yuzepovich&media=software"
                                                     //@"https://itunes.apple.com/search?term=jack+johnson&limit=200"
                                                     ]];
    
    [[NSURLConnection alloc]initWithRequest:self.jsonRequest delegate:self];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSArray *results = [res objectForKey:@"results"];
    
    for (NSDictionary *result in results) {
        NSString *iconRef = [result objectForKey:@"artworkUrl100"];
        
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: iconRef ]]];
        [self.images addObject:img];
//            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iconRef]];
//            [[NSURLConnection alloc]initWithRequest:request delegate:self];
    }
    
    [ (MotionDynamicsView*)self.view addSubviewsWithImages: self.images ];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
