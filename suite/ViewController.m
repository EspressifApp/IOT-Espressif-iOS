//
//  ViewController.m
//  suite
//
//  Created by 白 桦 on 5/16/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ViewController.h"
#import "ESPBaseApiUtil.h"

#import "ESPVersionMacro.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequestTest:(dispatch_semaphore_t) semaphore
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue currentQueue]];
    NSLog(@"haha:%@",[NSOperationQueue currentQueue]);
    
    NSURL *url = [NSURL URLWithString:@"http://192.168.20.198:8000/ping"];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        NSLog(@"SYSTEM >= 9.0");
        NSDictionary *parameters = @{@"jack":@"write"};
        NSData* data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        url = [NSURL URLWithDataRepresentation:data relativeToURL:url];
        NSLog(@"url: %@",url);
    }
    
//    [delegateFreeSession dataTaskWithRequest:<#(nonnull NSURLRequest *)#> completionHandler:<#^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)completionHandler#>]
    
    [[delegateFreeSession dataTaskWithURL: url
                        completionHandler:^(NSData *data, NSURLResponse *response,
                                            NSError *error) {
                            NSLog(@"Got response %@ with error %@.\n", response, error);
                            NSLog(@"DATA:\n%@\nEND DATA\n",
                                  [[NSString alloc] initWithData: data
                                                        encoding: NSUTF8StringEncoding]);
//                            NSLog(@"dispatch_resume");
                            [NSThread sleepForTimeInterval:0.5];
                            NSLog(@"dispatch_semaphore_signal");
                            dispatch_semaphore_signal(semaphore);
                        }] resume];
}

- (IBAction)tapTestBtn:(id)sender {
    if(1==0){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(queue, ^{
            //        for (int i = 0; i<3; ++i) {
            //            NSString *url = @"http://192.168.20.198:8000/ping";
            //            [ESPBaseApiUtil Get:url Headers:nil];
            //            [NSThread sleepForTimeInterval:20];
            //        }
            [self sendRequestTest:semaphore];
            NSLog(@"dispatch_semaphore_wait");
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"send request end1");
        });
        dispatch_barrier_sync(queue, ^{
            NSLog(@"send request end2");
        });
    }
    else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSDictionary *result = [ESPBaseApiUtil Get:@"http://192.168.20.198:8000/ping" Headers:nil];
            NSLog(@"result: %@",result);
        });
    }
}

@end
