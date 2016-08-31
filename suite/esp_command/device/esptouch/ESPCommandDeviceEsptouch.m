//
//  ESPCommandDeviceEsptouch.m
//  suite
//
//  Created by 白 桦 on 7/4/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandDeviceEsptouch.h"
#import "ESPTouchTask.h"

@interface ESPCommandDeviceEsptouch()

// without the lock, if the user tap confirm and cancel quickly enough,
// the bug will arise. the reason is follows:
// 0. task is starting created, but not finished
// 1. the task is cancel for the task hasn't been created, it do nothing
// 2. task is created
// 3. Oops, the task should be cancelled, but it is running
@property(nonatomic, strong) NSObject *lock;
@property(nonatomic, strong) ESPTouchTask *esptouchTask;

@end

@implementation ESPCommandDeviceEsptouch

@synthesize isCancelled = _isCancelled;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSObject alloc]init];
        _isCancelled = NO;
        _esptouchTask = nil;
    }
    return self;
}

/**
 * Note: !!!Don't call the task at UI Main Thread or RuntimeException will be thrown Execute the Esptouch Task and
 * return the result
 *
 * Smart Config v2.4 support the API
 *
 * It will be blocked until the client receive result count >= expectTaskResultCount. If it fail, it will return one
 * fail result will be returned in the list. If it is cancelled while executing, if it has received some results,
 * all of them will be returned in the list. if it hasn't received any results, one cancel result will be returned
 * in the list.
 *
 * @param expectTaskResultCount the expect result count(if expectTaskResultCount <= 0, expectTaskResultCount =
 *            Integer.MAX_VALUE)
 * @param apSsid the Ap's ssid
 * @param apBssid the Ap's bssid
 * @param apPassword the Ap's password
 * @param isSsidHidden whether the Ap's ssid is hidden
 * @param timeoutMillisecond(it should be >= 15000+6000) millisecond of total timeout
 *
 * @return the array of ESPTouchResult
 */
-(NSArray *) doCommandDeviceEsptouchResultCount:(int)expectTaskResultCount ApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden TimeoutMillisecond:(int)timeoutMillisecond
{
    return [self doCommandDeviceEsptouchResultCount:expectTaskResultCount ApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden TimeoutMillisecond:timeoutMillisecond Delegate:nil];
}

/**
 * Note: !!!Don't call the task at UI Main Thread or RuntimeException will be thrown Execute the Esptouch Task and
 * return the result
 *
 * Smart Config v2.4 support the API
 *
 * It will be blocked until the client receive result count >= expectTaskResultCount. If it fail, it will return one
 * fail result will be returned in the list. If it is cancelled while executing, if it has received some results,
 * all of them will be returned in the list. if it hasn't received any results, one cancel result will be returned
 * in the list.
 *
 * @param expectTaskResultCount the expect result count(if expectTaskResultCount <= 0, expectTaskResultCount =
 *            Integer.MAX_VALUE)
 * @param apSsid the Ap's ssid
 * @param apBssid the Ap's bssid
 * @param apPassword the Ap's password
 * @param isSsidHidden whether the Ap's ssid is hidden
 * @param timeoutMillisecond(it should be >= 15000+6000) millisecond of total timeout
 * @param delegate when one device is connected to the Ap, it will be called back
 *
 * @return the array of ESPTouchResult
 */
-(NSArray *) doCommandDeviceEsptouchResultCount:(int)expectTaskResultCount ApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden TimeoutMillisecond:(int)timeoutMillisecond Delegate:(id<ESPTouchDelegate>)delegate
{
    @synchronized(_lock) {
        if (_isCancelled) {
            return nil;
        }
        _esptouchTask = [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPassword andIsSsidHiden:isSsidHidden andTimeoutMillisecond:timeoutMillisecond];
        [_esptouchTask setEsptouchDelegate:delegate];
    }
    return [_esptouchTask executeForResults:expectTaskResultCount];
}

/**
 * the same as this{@link #doCommandDeviceEsptouch(int, String, String, String, boolean, int)}, except
 * timeoutMillisecond = 60000
 *
 * @param expectTaskResultCount the expect result count(if expectTaskResultCount <= 0, expectTaskResultCount =
 *            Integer.MAX_VALUE)
 * @param apSsid the Ap's ssid
 * @param apBssid the Ap's bssid
 * @param apPassword the Ap's password
 * @param isSsidHidden whether the Ap's ssid is hidden
 *
 * @return the array of ESPTouchResult
 */
-(NSArray *) doCommandDeviceEsptouchResultCount:(int)expectTaskResultCount ApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden
{
    return [self doCommandDeviceEsptouchResultCount:expectTaskResultCount ApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden Delegate:nil];
}

/**
 * the same as this{@link #doCommandDeviceEsptouch(int, String, String, String, boolean, int)}, except
 * timeoutMillisecond = 60000
 *
 * @param expectTaskResultCount the expect result count(if expectTaskResultCount <= 0, expectTaskResultCount =
 *            Integer.MAX_VALUE)
 * @param apSsid the Ap's ssid
 * @param apBssid the Ap's bssid
 * @param apPassword the Ap's password
 * @param isSsidHidden whether the Ap's ssid is hidden
 * @param delegate when one device is connected to the Ap, it will be called back
 *
 * @return the array of ESPTouchResult
 */
-(NSArray *) doCommandDeviceEsptouchResultCount:(int)expectTaskResultCount ApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden Delegate:(id<ESPTouchDelegate>)delegate
{
    @synchronized(_lock) {
        if (_isCancelled) {
            return nil;
        }
        _esptouchTask = [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPassword andIsSsidHiden:isSsidHidden];
        [_esptouchTask setEsptouchDelegate:delegate];
    }
    return [_esptouchTask executeForResults:expectTaskResultCount];
}

/**
 * check whether the Command Device Esptouch is cancelled
 *
 * @return whether the Command Device Esptouch is cancelled
 */
-(BOOL) isCancelled
{
    @synchronized(_lock) {
        return _isCancelled;
    }
}

/**
 * cancel the command
 */
-(void) cancel
{
    @synchronized(_lock) {
        if (_esptouchTask!=nil) {
            [_esptouchTask interrupt];
        }
        _isCancelled = YES;
    }
}

@end
