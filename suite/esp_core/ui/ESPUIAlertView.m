//
//  ESPUIAlertView.m
//  suite
//
//  Created by 白 桦 on 8/1/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPUIAlertView.h"


#define DEBUG_ON_ESP_UIALERTVIEW

@interface ESPUIAlertView()

@property (nonatomic, strong) UIAlertView *espAlertView;
@property (nonatomic, assign) NSUInteger *espShowCount;

@property (nonatomic, strong) NSMutableArray *espTitles;
@property (nonatomic, strong) NSMutableArray *espMessages;
@property (nonatomic, strong) NSMutableArray *espTimeIntervals;

@end

@implementation ESPUIAlertView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _espTitle = nil;
        _espMessage = nil;
        _espShowCount = 0;
        _espTitles = [[NSMutableArray alloc]init];
        _espMessages = [[NSMutableArray alloc]init];
        _espTimeIntervals = [[NSMutableArray alloc]init];
    }
    return self;
}

// dismiss alert view
- (void) dismissCounted:(BOOL)counted
{
#ifdef DEBUG_ON_ESP_UIALERTVIEW
    NSLog(@"%@ %@ counted:%@",self.class,NSStringFromSelector(_cmd),counted?@"YES":@"NO");
#endif
    if (counted)
    {
        --self.espShowCount;
    }
    if ((self.espShowCount==0||!counted)&&self.espAlertView!=nil) {
#ifdef DEBUG_ON_ESP_UIALERTVIEW
        NSLog(@"%@ %@ dismissed",self.class,NSStringFromSelector(_cmd));
#endif
        
        UIAlertView *alertView = self.espAlertView;
        [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
        
        self.espAlertView = nil;
        
        if (self.espTitles.count>0) {
            self.espTitle = self.espTitles[0];
            self.espMessage = self.espMessages[0];
            NSTimeInterval timeInterval = [self.espTimeIntervals[0]doubleValue];
            [self.espTitles removeObjectAtIndex:0];
            [self.espMessages removeObjectAtIndex:0];
            [self.espTimeIntervals removeObjectAtIndex:0];
            [self showTimeInterval:timeInterval Instant:NO];
        }
    }
}

// show alert view
- (void) showAlertView
{
#ifdef DEBUG_ON_ESP_UIALERTVIEW
    NSLog(@"%@ %@",self.class,NSStringFromSelector(_cmd));
#endif
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:self.espTitle message:self.espMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    self.espAlertView = alertView;
    [alertView show];
    ++self.espShowCount;
}

// dismiss alert view later
- (void) dismissAlertViewLater:(NSTimeInterval) timeInterval
{
#ifdef DEBUG_ON_ESP_UIALERTVIEW
    NSLog(@"%@ %@",self.class,NSStringFromSelector(_cmd));
#endif
    dispatch_time_t later = dispatch_time(DISPATCH_TIME_NOW, timeInterval * NSEC_PER_SEC);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_after(later, mainQueue, ^{
        [self dismissCounted:YES];
    });
}

- (void) clearAlertViews
{
#ifdef DEBUG_ON_ESP_UIALERTVIEW
    NSLog(@"%@ %@",self.class,NSStringFromSelector(_cmd));
#endif
    [_espTitles removeAllObjects];
    [_espMessages removeAllObjects];
    [_espTimeIntervals removeAllObjects];
}

- (void) showTimeIntervalCurrent:(NSTimeInterval)timeInterval
{
#ifdef DEBUG_ON_ESP_UIALERTVIEW
    NSLog(@"%@ %@",self.class,NSStringFromSelector(_cmd));
#endif
    NSThread *currentThread = [NSThread currentThread];
    NSThread *mainThread = [NSThread mainThread];
    NSAssert(currentThread==mainThread, @"it should be called in UI main thread");
    NSAssert(self.espShowCount>=0,@"espShowCount should be >= 0");
    if (self.espShowCount>0&&self.espAlertView!=nil) {
        // dismiss previous alert view
        [self dismissCounted:NO];
    } else if (self.espShowCount==0&&self.espAlertView==nil) {
        
    } else {
        abort();
    }
    // show current alert view
    [self showAlertView];
    // dismiss alert view later
    [self dismissAlertViewLater:timeInterval];
}

- (void) showTimeInterval:(NSTimeInterval) timeInterval Instant:(BOOL) isInstant
{
    if (isInstant||_espShowCount==0) {
        [self showTimeIntervalCurrent:timeInterval];
        if (isInstant) {
            [self clearAlertViews];
        }
    } else {
#ifdef DEBUG_ON_ESP_UIALERTVIEW
        NSLog(@"%@ %@ store alertview",self.class,NSStringFromSelector(_cmd));
#endif
        [self.espMessages addObject:self.espMessage];
        [self.espTitles addObject:self.espTitle];
        [self.espTimeIntervals addObject:[NSNumber numberWithDouble:timeInterval]];
    }
}

@end
