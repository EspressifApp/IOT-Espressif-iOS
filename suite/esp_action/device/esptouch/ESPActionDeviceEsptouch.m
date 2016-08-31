//
//  ESPActionDeviceEsptouch.m
//  suite
//
//  Created by 白 桦 on 7/29/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDeviceEsptouch.h"
#import "ESPCommandDeviceEsptouch.h"

@interface ESPActionDeviceEsptouch()

@property (nonatomic, strong) ESPCommandDeviceEsptouch *espCommandEsptouch;
@property (atomic, assign) BOOL espIsDone;

@end

@implementation ESPActionDeviceEsptouch

#define kESPActionRunningLockKey    @"kESPActionRunningLockKey"
#define kESPActionRunningBoolKey    @"kESPActionRunningBoolKey"

+ (NSMutableDictionary *) EspIsActionRunning
{
    __block NSMutableDictionary *actionRunning = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        actionRunning = [[NSMutableDictionary alloc]init];
        NSObject *lock = [[NSObject alloc]init];
        NSNumber *state = [[NSNumber alloc]initWithBool:NO];
        [actionRunning setObject:lock forKey:kESPActionRunningLockKey];
        [actionRunning setObject:state forKey:kESPActionRunningBoolKey];
    });
    return actionRunning;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _espCommandEsptouch = [[ESPCommandDeviceEsptouch alloc]init];
        _espIsDone = NO;
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

-(NSArray *) doActionDeviceEsptouchResultCount:(int)expectTaskResultCount ApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden TimeoutMillisecond:(int)timeoutMillisecond
{
    NSMutableDictionary *isActionRunning = [ESPActionDeviceEsptouch EspIsActionRunning];
    NSObject *lock = [isActionRunning objectForKey:kESPActionRunningLockKey];
    @synchronized(lock) {
        NSNumber *isRunning = [isActionRunning objectForKey:kESPActionRunningBoolKey];
        if (isRunning.boolValue) {
            // for the esptouch will occupy the fix port, so if you call it more than once at the same time,
            // except the first time, other time will be failed forever. to prevent you from the abnormal situation,
            // we return null
            return nil;
        }
    }
    @synchronized(lock) {
        NSNumber *setRunning = [NSNumber numberWithBool:YES];
        [isActionRunning setObject:setRunning forKey:kESPActionRunningBoolKey];
    }
    NSArray *result = [self.espCommandEsptouch doCommandDeviceEsptouchResultCount:expectTaskResultCount ApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden TimeoutMillisecond:timeoutMillisecond];
    @synchronized(lock) {
        NSNumber *clearRunning = [NSNumber numberWithBool:NO];
        [isActionRunning setObject:clearRunning forKey:kESPActionRunningBoolKey];
    }
    return result;
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
 * @param esptouchListener when one device is connected to the Ap, it will be called back
 *
 * @return the array of ESPTouchResult
 */
-(NSArray *) doActionDeviceEsptouchResultCount:(int)expectTaskResultCount ApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden TimeoutMillisecond:(int)timeoutMillisecond Delegate:(id<ESPTouchDelegate>)delegate
{
    NSMutableDictionary *isActionRunning = [ESPActionDeviceEsptouch EspIsActionRunning];
    NSObject *lock = [isActionRunning objectForKey:kESPActionRunningLockKey];
    @synchronized(lock) {
        NSNumber *isRunning = [isActionRunning objectForKey:kESPActionRunningBoolKey];
        if (isRunning.boolValue) {
            // for the esptouch will occupy the fix port, so if you call it more than once at the same time,
            // except the first time, other time will be failed forever. to prevent you from the abnormal situation,
            // we return null
            return nil;
        }
    }
    @synchronized(lock) {
        NSNumber *setRunning = [NSNumber numberWithBool:YES];
        [isActionRunning setObject:setRunning forKey:kESPActionRunningBoolKey];
    }
    NSArray *result = [self.espCommandEsptouch doCommandDeviceEsptouchResultCount:expectTaskResultCount ApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden TimeoutMillisecond:timeoutMillisecond Delegate:delegate];
    @synchronized(lock) {
        NSNumber *clearRunning = [NSNumber numberWithBool:NO];
        [isActionRunning setObject:clearRunning forKey:kESPActionRunningBoolKey];
    }
    return result;
}

/**
 * the same as this{@link #doActionDeviceEsptouch(int, String, String, String, boolean, int)}, except
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
-(NSArray *) doActionDeviceEsptouchResultCount:(int)expectTaskResultCount ApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden
{
    NSMutableDictionary *isActionRunning = [ESPActionDeviceEsptouch EspIsActionRunning];
    NSObject *lock = [isActionRunning objectForKey:kESPActionRunningLockKey];
    @synchronized(lock) {
        NSNumber *isRunning = [isActionRunning objectForKey:kESPActionRunningBoolKey];
        if (isRunning.boolValue) {
            // for the esptouch will occupy the fix port, so if you call it more than once at the same time,
            // except the first time, other time will be failed forever. to prevent you from the abnormal situation,
            // we return null
            return nil;
        }
    }
    @synchronized(lock) {
        NSNumber *setRunning = [NSNumber numberWithBool:YES];
        [isActionRunning setObject:setRunning forKey:kESPActionRunningBoolKey];
    }
    NSArray *result = [self.espCommandEsptouch doCommandDeviceEsptouchResultCount:expectTaskResultCount ApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden];
    @synchronized(lock) {
        NSNumber *clearRunning = [NSNumber numberWithBool:NO];
        [isActionRunning setObject:clearRunning forKey:kESPActionRunningBoolKey];
    }
    return result;
}

/**
 * the same as this{@link #doActionDeviceEsptouch(int, String, String, String, boolean, int)}, except
 * timeoutMillisecond = 60000
 *
 * @param expectTaskResultCount the expect result count(if expectTaskResultCount <= 0, expectTaskResultCount =
 *            Integer.MAX_VALUE)
 * @param apSsid the Ap's ssid
 * @param apBssid the Ap's bssid
 * @param apPassword the Ap's password
 * @param isSsidHidden whether the Ap's ssid is hidden
 * @param esptouchListener when one device is connected to the Ap, it will be called back
 *
 * @return the array of ESPTouchResult
 */
-(NSArray *) doActionDeviceEsptouchResultCount:(int)expectTaskResultCount ApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden Delegate:(id<ESPTouchDelegate>)delegate
{
    NSMutableDictionary *isActionRunning = [ESPActionDeviceEsptouch EspIsActionRunning];
    NSObject *lock = [isActionRunning objectForKey:kESPActionRunningLockKey];
    @synchronized(lock) {
        NSNumber *isRunning = [isActionRunning objectForKey:kESPActionRunningBoolKey];
        if (isRunning.boolValue) {
            // for the esptouch will occupy the fix port, so if you call it more than once at the same time,
            // except the first time, other time will be failed forever. to prevent you from the abnormal situation,
            // we return null
            return nil;
        }
    }
    @synchronized(lock) {
        NSNumber *setRunning = [NSNumber numberWithBool:YES];
        [isActionRunning setObject:setRunning forKey:kESPActionRunningBoolKey];
    }
    NSArray *result = [self.espCommandEsptouch doCommandDeviceEsptouchResultCount:expectTaskResultCount ApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden Delegate:delegate];
    @synchronized(lock) {
        NSNumber *clearRunning = [NSNumber numberWithBool:NO];
        [isActionRunning setObject:clearRunning forKey:kESPActionRunningBoolKey];
    }
    return result;
}

/**
 * check whether the Action Device Esptouch is cancelled
 *
 * @return whether the Action Device Esptouch is cancelled
 */
-(BOOL) isCancelled
{
    return self.espCommandEsptouch.isCancelled;
}

/**
 * cancel the action
 */
-(void) cancel
{
    [self.espCommandEsptouch cancel];
}

/**
 * check whether exist Action Device Esptouch running
 *
 * @return whether exist Action Device Esptouch running
 */
-(BOOL) isExecuted
{
    NSMutableDictionary *isActionRunning = [ESPActionDeviceEsptouch EspIsActionRunning];
    NSObject *lock = [isActionRunning objectForKey:kESPActionRunningLockKey];
    @synchronized(lock) {
        NSNumber *isRunning = [isActionRunning objectForKey:kESPActionRunningBoolKey];
        return isRunning.boolValue;
    }
}

/**
 * finish esptouch instantly
 */
-(void) done
{
    [self cancel];
    self.espIsDone = YES;
}

/**
 * check whether the esptouch is done
 *
 * @return whether the esptouch is done
 */
-(BOOL) isDone
{
    return self.espIsDone;
}

@end
