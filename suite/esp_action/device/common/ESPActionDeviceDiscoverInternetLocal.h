//
//  ESPActionDeviceDiscoverInternetLocal.h
//  suite
//
//  Created by 白 桦 on 6/2/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

// The min times that send UDP Broadcast when onRefreshing
#define UDP_EXECUTE_MIN_TIMES   1

// The max times that send UDP Broadcast when onRefreshing
#define UDP_EXECUTE_MAX_TIMES   5

@interface ESPActionDeviceDiscoverInternetLocal : NSObject

/**
 * discover devices from internet and local
 *
 * @param isSyn whether execute the it syn or asyn
 * @param userKey the user key
 */
- (void) doActionDeviceDiscoverInternetLocal:(BOOL)isSyn UserKey:(NSString *)userKey;

/**
 * discover devices from local
 *
 * @param isSyn whether execute the it syn or asyn
 */
- (void) doActionDeviceDiscoverLocal:(BOOL)isSyn;

/**
 * discover devices from internet
 *
 * @param isSyn whether execute the it syn or asyn
 * @param userKey the user key
 */
- (void) doActionDeviceDiscoverInternet:(BOOL)isSyn UserKey:(NSString *)userKey;

@end
