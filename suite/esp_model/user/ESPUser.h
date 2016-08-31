//
//  ESPUser.h
//  suite
//
//  Created by 白 桦 on 5/23/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPSingletonMacro.h"
#import "ESPLoginResult.h"
#import "ESPRegisterResult.h"
#import "ESPDevice.h"
#import "ESPDeviceStatus.h"
#import "ESPTouchDelegate.h"

#define ESP_USER_ID_GUEST       -1
#define ESP_USER_KEY_GUEST      @"guest-key"
#define ESP_USER_EMAIL_GUEST    @"guest-email"
#define ESP_USER_NAME_GUEST     @"guest-name"

@interface ESPUser : NSObject

DEFINE_SINGLETON_FOR_HEADER(User, ESP)

@property (nonatomic, assign) long long espUserId;
@property (nonatomic, strong) NSString *espUserKey;
@property (nonatomic, strong) NSString *espUserName;
@property (nonatomic, strong) NSString *espUserEmail;
@property (readonly, nonatomic, assign) BOOL espIsLogined;

// the device array to be displayed on main UI
@property (readonly, nonatomic, strong) NSMutableArray *espDeviceArray;

- (void) addDeviceLocal:(ESPDevice *)deviceLocal;
- (void) updateDeviceLocalArray:(NSArray *)deviceLocalArray;
- (void) addDeviceInternet:(ESPDevice *)deviceInternet;
- (void) updateDeviceInternetArray:(NSArray *)deviceInternetArray;
- (void) addDeviceTransform:(ESPDevice *)deviceTransformArray;
- (void) addDeviceTransformArray:(NSArray *)deviceTransformArray;
- (void) addDeviceTempArray:(NSArray *)deviceTempArray;

/**
 * get the current status of device(via local or internet) if local it will use local first
 *
 * @param device the device
 * @return whether the get action is suc
 */
-(BOOL) doActionGetDeviceStatusDevice:(ESPDevice *)device;

/**
 * post the status to device(via local or internet) if local it will use local first
 *
 * @param device the device
 * @param status the new status
 * @return whether the post action is suc
 */
-(BOOL) doActionPostDeviceStatusDevice:(ESPDevice *)device Status:(ESPDeviceStatus *)status;

/**
 * an easy API for doActionRefreshDevices:(BOOL) and doActionRefreshStaDevices:(BOOL)
 * after logining, doActionRefreshDevices:(BOOL) will be invoked, vice versa
 *
 * @param isSyn whether execute it syn or asyn
 */
-(void) doActionRefreshAllDevices:(BOOL) isSyn;

/**
 * refresh the devices's status belong to the Player. it will check whether the device is Local , Internet ,
 * Offline, or Coexist of Local and Internet in the background thread. after it is finished, the NSNotification of
 * DEVICES_ARRIVE (@see ESPConstantsNotification) will sent. when ESPUser receive the broadcast, he should
 * refresh the UI
 *
 * @param isSyn whether execute the it syn or asyn
 */
-(void) doActionRefreshDevices:(BOOL) isSyn;

/**
 * it is like {@link #doActionRefreshDevices()}, but it only refresh sta devices
 *
 * @param isSyn whether execute it syn or asyn
 */
-(void) doActionRefreshStaDevices:(BOOL) isSyn;

/**
 * upgrade the device by local
 *
 * @param device the device to be upgraded
 * @return whether the device upgrade local suc
 */
-(BOOL) doActionUpgradeDeviceLocal:(ESPDevice *)device;

/**
 * upgrade the device by internet
 *
 * @param device the device to be upgraded
 * @return whether the device upgrade internet suc
 */
-(BOOL) doActionUpgradeDeviceInternet:(ESPDevice *)device;

/**
 * rename device internet(user) or local(guest)
 *
 * @param device the device to be renamed
 * @param deviceName the device's new name
 * @param instantly rename device name instantly or not
 */
-(void) doActionRenameDevice:(ESPDevice *)device DeviceName:(NSString *)deviceName Instantly:(BOOL)instantly;

/**
 * delete device internet(user) or local(guest)
 * 
 * @param device the device to be deleted
 * @param instantly delete device instantly or not
 */
-(void) doActionDeleteDevice:(ESPDevice *)device Instantly:(BOOL)instantly;

/**
 * login by Internet
 *
 * @param userEmail user's email
 * @param userPassword user's password
 * @return ESPLoginResult
 */
-(ESPLoginResult *) doActionUserLoginInternetUserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword;

/**
 * register user account with email by Internet
 *
 * @param userName user's name
 * @param userEmail user's email
 * @param userPassword user's password
 * @return ESPRegisterResult
 */
-(ESPRegisterResult *) doActionUserRegisterInternetUserName:(NSString *)userName UserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword;

/**
 * activate device
 *
 * @param device device to be activated
 * @return whether the device is executed suc
 */
-(BOOL) activateDeviceSync:(ESPDevice *)device;

/**
 * add all devices in SmartConfig connect to the AP which the phone is connected, if requiredActivate is true, it
 * will make device avaliable on server. all of the tasks are syn.
 *
 * @param apSsid the Ap's ssid
 * @param apBssid the Ap's bssid
 * @param apPassword the Ap's password
 * @param isSsidHidden whether the Ap's ssid is hidden
 * @param requiredActivate whether activate the devices automatically
 * @param esptouchListener when one device is connected to the Ap, it will be called back
 *
 * @return whether the task is executed suc(if there's another task executing, it will return false,and don't start the task)
 */
-(BOOL) addDevicesSyncApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden RequiredActivate:(BOOL)requiredActivate Delegate:(id<ESPTouchDelegate>)delegate;
/**
 * add one device in SmartConfig connect to the AP which the phone is connected, if requiredActivate is true, it
 * will make device available on server. the task is syn
 *
 * @param apSsid the Ap's ssid
 * @param apBssid the Ap's bssid
 * @param apPassword the Ap's password
 * @param isSsidHidden whether the Ap's ssid is hidden
 * @param requiredActivate whether activate the devices automatically
 * @param esptouchListener when one device is connected to the Ap, it will be called back
 *
 * @return whether the task is executed suc
 */
-(BOOL) addDeviceSyncApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden RequiredActivate:(BOOL)requiredActivate Delegate:(id<ESPTouchDelegate>)delegate;

/**
 * send DEVICES_ARRIVE notifications
 */
-(void) notifyDevicesArrive;

/**
 * save devices into db
 */
-(void) saveDevices;

/**
 * load devices from db
 */
-(void) loadDevices;

/**
 * save user into db
 */
-(void) saveUser;

/**
 * load user from db
 */
-(void) loadUser;

/**
 * load user guest
 */
-(void) loadGuest;

/**
 * logout
 */
-(void) logout;

@end
