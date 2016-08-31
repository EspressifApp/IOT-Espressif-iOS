//
//  ESPDevice.h
//  suite
//
//  Created by 白 桦 on 5/25/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDeviceType.h"
#import "ESPDeviceState.h"
#import "ESPIOTAddress.h"
#import "DaoEspDevice.h"

@interface ESPDevice : NSObject<NSCopying>

@property (nonatomic, strong) NSString *espBssid;
@property (nonatomic, assign) long long espDeviceId;
@property (nonatomic, strong) NSString *espDeviceKey;
@property (nonatomic, assign) BOOL espIsOwner;
@property (nonatomic, strong) NSString *espDeviceName;
@property (nonatomic, strong) NSString *espRomVersionCurrent;
@property (nonatomic, strong) NSString *espRomVersionLatest;
@property (nonatomic, assign) long long espUserId;
@property (nonatomic, strong) ESPDeviceType *espDeviceType;
@property (nonatomic, strong) ESPDeviceState *espDeviceState;
@property (nonatomic, strong) NSString *espInetAddress;
@property (nonatomic, assign) BOOL espIsMeshDevice;
@property (nonatomic, strong) NSString *espParentDeviceBssid;
@property (nonatomic, strong) NSString *espRootDeviceBssid;

@property (nonatomic, strong) NSDate *espDeviceActivatedTimestamp;
// whether the device is using
@property (nonatomic, assign) BOOL espIsUsing;
/**
 * _espIsRenamedJustNow is used to resolve the conflict between:
 * rename action and discover device from internet
 *
 * work flow: a. set _espIsRenamedJustNow and renamed state
 *            b. rename device on server
 *            c. if suc, clear _espIsRenamedJustNow
 *            d. discover device from internet check _espIsRenamedJustNow and process it
 */
// whether the device is rename just now
@property (nonatomic, assign) BOOL _espIsRenamedJustNow;

// whether the device is local or offline and from database
@property (nonatomic, assign) BOOL _espIsFromDatabase;

// init deviece with device(like copying)
- (instancetype) initWithDevice:(ESPDevice *)espDevice;

// init sta device with IOTAddress
- (instancetype) initWithIOTAddress:(ESPIOTAddress *)espIotAddress;

// init device according to info from server
- (instancetype) initWithDeviceName:(NSString *)deviceName DeviceId:(long long)deviceId DeviceKey:(NSString *)deviceKey IsOwner:(BOOL)isOwner Bssid:(NSString *)bssid DeviceState:(ESPDeviceState *)deviceState DeviceType:(ESPDeviceType *)deviceType RomVersion:(NSString *)romVersion LatestRomVersion:(NSString *)latestRomVersion UserId:(long long)userId IsMeshDevice:(BOOL) isMeshDevice ParentBssid:(NSString *)parentBssid ActivatedTimestamp:(NSDate *)deviceActivatedTimestamp;

// init device according to local database
- (instancetype) initWithDaoDevice:(DaoEspDevice *)daoDevice;

// Sentry for User can't find local device in the AP
+ (ESPDevice *) ESP_DEVICE_LOCAL_EMPTY;
// Sentry for User haven't his own device in Server
+ (ESPDevice *) ESP_DEVICE_INTERNET_EMPTY;
// Sentry for Internet unaccessible
+ (ESPDevice *) ESP_DEVICE_INTERNET_UNACCESSIBLE;

/**
 * check whether the device is activated
 *
 * @return whether the device is activated
 */
-(BOOL) isActivated;

/**
 * activate device local(make device activate to server)
 *
 * @param randomKey the random 40 key
 * @return whether activate device local suc(make device activate to server)
 */
- (BOOL) doActionDeviceActivateLocalRandomKey:(NSString *)randomKey;

/**
 * activate device internet(make user become the device owner on server)
 *
 * @param randomKey the random 40 key
 * @param userKey the user key
 * @param userId the user id
 *
 * @return the activate device from server or nil
 */
- (ESPDevice *) doActionDeviceActivateInternetRandomKey:(NSString *)randomKey UserKey:(NSString *)userKey UserId:(long long)userId;

- (DaoEspDevice *) espDaoEspDevice;

/**
 * save device into local database
 */
- (void) save;

/**
 * remove device from local database(automatically choose by bssid or by device key)
 * (user login choose removeByBssid: while guest login choose removeByDeviceKey:)
 */
-(void) remove;

/**
 * remove device from local database by bssid(all devices of the bssid will be removed
 * ,count>=0)
 */
- (void) removeByBssid;

/**
 * remove device from local database by device key(one device of the device key will be removed
 * ,0<=count<=1)
 */
-(void) removeByDeviceKey;

@end
