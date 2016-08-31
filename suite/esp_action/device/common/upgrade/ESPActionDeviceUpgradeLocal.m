//
//  ESPActionDeviceUpgradeLocal.m
//  suite
//
//  Created by 白 桦 on 6/21/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDeviceUpgradeLocal.h"

#import "ESPVersionMacro.h"
#import "ESPBaseApiUtil.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPUser.h"
#import "ESPMeshUpgradeServer.h"

#define AUTHORIZATION       @"Authorization"
#define USER_BIN            @"user_bin"
#define USER1_BIN           @"user1.bin"
#define USER2_BIN           @"user2.bin"
#define TOKEN               @"token"
#define URL_DOWNLOAD_BIN    @"https://iot.espressif.cn/v1/device/rom/"
#define DOWNLOAD_TIMEOUT    30
#define PUSH_TIMEOUT        30
#define SLEEP_TIMEOUT       3

#define TIMEOUT_SECONDS     600

@interface ESPActionDeviceUpgradeLocal()

@end

@implementation ESPActionDeviceUpgradeLocal

#pragma mark - upgrade local common source code

/**
 * file system src start
 */
- (NSString *) getBasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (NSData *) openFilePath:(NSString *)filePath FileName:(NSString *)fileName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *basePath = [self getBasePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",basePath,filePath,fileName];
    if (![fm fileExistsAtPath:path]) {
        return nil;
    } else {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return data;
    }
}

- (BOOL) saveFilePath:(NSString *)filePath FileName:(NSString *)fileName Data:(NSData *)data
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *basePath = [self getBasePath];
    filePath = [NSString stringWithFormat:@"%@/%@",basePath,filePath];
    if (![fm fileExistsAtPath:filePath]) {
        BOOL isCreated = [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreated) {
            NSLog(@"ERROR %@ %@ create directory at path:%@ fail",[self class],NSStringFromSelector(_cmd),filePath);
            return NO;
        }
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@",filePath,fileName];
    BOOL isSaved = [data writeToFile:path atomically:YES];
    if (!isSaved) {
        NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSLog(@"ERROR %@ %@ write to path:%@ fail",[self class],NSStringFromSelector(_cmd),path);
    }
#ifdef DEBUG
    NSLog(@"%@ %@ path:%@ suc",[self class],NSStringFromSelector(_cmd),path);
#endif
    return isSaved;
}

- (BOOL) deleteFilePath:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *basePath = [self getBasePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",basePath,filePath];
    NSError *error = nil;
    BOOL isRemoved = [fm removeItemAtPath:path error:&error];
    if (error!=nil) {
        NSLog(@"ERROR %@ %@ delete path:%@ fail",[self class],NSStringFromSelector(_cmd),path);
        NSLog(@"error:%@",error);
    }
    return isRemoved;
}
/**
 * file system src end
 */

/**
 * get user bin start
 */
- (NSData *) downloadUrl:(NSString *)url HeaderDict:(NSDictionary *)headers FolderPath:(NSString *)folderPath FileName:(NSString *)fileName
{
    NSData *received = [ESPBaseApiUtil downloadUrl:url headers:headers timeoutSeconds:DOWNLOAD_TIMEOUT];
    if (received==nil) {
#ifdef DEBUG
        NSLog(@"%@ %@ fail",[self class],NSStringFromSelector(_cmd));
#endif
        return nil;
    } else {
        BOOL isSuc = [self saveFilePath:folderPath FileName:fileName Data:received];
        if (!isSuc) {
#ifdef DEBUG
            NSLog(@"%@ %@ save fail",[self class],NSStringFromSelector(_cmd));
#endif
        }
        return received;
    }
}

- (NSString *) getDownloadUrlVersion:(NSString *)version FileName:(NSString *)fileName
{
    return [NSString stringWithFormat:@"%@?action=download_rom&version=%@&filename=%@",URL_DOWNLOAD_BIN,version,fileName];
}

- (NSData *) getUserBinFromLocalIsUser1:(BOOL) isUser1 RomVersion:(NSString *)romVersion
{
    NSString *folerPath = [NSString stringWithFormat:@"bin/%@",romVersion];
    NSString *filename = isUser1 ? USER1_BIN : USER2_BIN;
    NSData *userData = [self openFilePath:folerPath FileName:filename];
    return userData;
}

- (NSData *) getUserBinFromInternetIsUser1:(BOOL) isUser1 DeviceKey:(NSString *)deviceKey RomVersion:(NSString *)romVersion
{
    // download user1.bin and save into file system
    NSString *headerKey = AUTHORIZATION;
    NSString *headerValue = [NSString stringWithFormat:@"%@ %@",TOKEN,deviceKey];
    NSString *url = [self getDownloadUrlVersion:romVersion FileName:USER1_BIN];
    NSString *folderPath = [NSString stringWithFormat:@"bin/%@",romVersion];
    NSString *filename = USER1_BIN;
    NSData *user1Data = [self downloadUrl:url HeaderDict:@{headerKey:headerValue} FolderPath:folderPath FileName:filename];
    if (user1Data!=nil) {
#ifdef DEBUG
        NSLog(@"%@ %@ download user1.bin suc",[self class],NSStringFromSelector(_cmd));
#endif
    } else {
#ifdef DEBUG
        NSLog(@"%@ %@ download user1.bin fail",[self class],NSStringFromSelector(_cmd));
#endif
        return nil;
    }
    // download user2.bin and save into file system
    filename = USER2_BIN;
    url = [self getDownloadUrlVersion:romVersion FileName:USER2_BIN];
    NSData *user2Data = [self downloadUrl:url HeaderDict:@{headerKey:headerValue} FolderPath:folderPath FileName:filename];
    if (user2Data!=nil) {
#ifdef DEBUG
        NSLog(@"%@ %@ download user2.bin suc",[self class],NSStringFromSelector(_cmd));
#endif
    } else {
#ifdef DEBUG
        NSLog(@"%@ %@ download user2.bin fail",[self class],NSStringFromSelector(_cmd));
#endif
        return nil;
    }
    return isUser1 ? user1Data : user2Data;
}

- (NSData *) getUserBinIsUser1:(BOOL) isUser1 DeviceKey:(NSString *)deviceKey RomVersion:(NSString *)romVersion
{
    NSData *userBinData = [self getUserBinFromLocalIsUser1:isUser1 RomVersion:romVersion];
    if(userBinData==nil) {
        userBinData = [self getUserBinFromInternetIsUser1:isUser1 DeviceKey:deviceKey RomVersion:romVersion];
    }
    return userBinData;
}
/**
 * get user bin end
 */

#pragma mark - upgrade local non-mesh

/**
 * get user running start
 */
- (NSString *) getUserRunningUrl:(NSString *)inetAddr
{
    return [NSString stringWithFormat:@"http://%@/upgrade?command=getuser",inetAddr];
}

- (NSNumber *) isUser1Running:(NSString *)inetAddr
{
    NSString *url = [self getUserRunningUrl:inetAddr];
    NSDictionary *responseJson = [ESPBaseApiUtil Get:url Headers:nil];
    if (responseJson==nil) {
        NSLog(@"%@ %@ inetAddr:%@ fail, return nil",[self class],NSStringFromSelector(_cmd),inetAddr);
        return nil;
    }
    @try {
        NSString *userRunningStr = [responseJson objectForKey:USER_BIN];
        if ([userRunningStr isEqualToString:USER1_BIN]) {
            return [NSNumber numberWithBool:YES];
        } else if([userRunningStr isEqualToString:USER2_BIN]) {
            return [NSNumber numberWithBool:NO];
        } else {
            NSLog(@"%@ %@ userRunningStr: %@ is invalid",[self class],NSStringFromSelector(_cmd),userRunningStr);
            return nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@ %@ exception:%@",[self class],NSStringFromSelector(_cmd),exception);
        return nil;
    }
    return nil;
}
/**
 * get user running end
 */

/**
 * execute post for NSURLResponse start
 */
- (NSURLSessionConfiguration *) DEFAULT_SESSION_CONFIGURATION
{
    static dispatch_once_t predicate;
    static NSURLSessionConfiguration *DEFAULT_SESSION_CONFIGURATION;
    dispatch_once(&predicate, ^{
        DEFAULT_SESSION_CONFIGURATION = [NSURLSessionConfiguration defaultSessionConfiguration];
    });
    return DEFAULT_SESSION_CONFIGURATION;
}

- (NSURLResponse *) executePostForNSULResponseURL:(NSURL *)url Data:(NSData *)data TimeoutInterval:(NSTimeInterval) timeoutInterval
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeoutInterval];
    // don't use cookie
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPMethod:@"POST"];
    // set HTTP Body(JSONObject)
    if(data!=nil)
    {
        [request setHTTPBody:data];
    }
    __block NSURLResponse *response = nil;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
#pragma clang diagnostic pop
    } else {
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[self DEFAULT_SESSION_CONFIGURATION] delegate:nil delegateQueue:[NSOperationQueue currentQueue]];
        __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *responseInner, NSError *error){
            if (error !=nil ){
                NSLog(@"ERROR %@ %@::error=%@",[self class],NSStringFromSelector(_cmd),error);
            } else {
                response = responseInner;
                if (error!=nil){
                    NSLog(@"ERROR %@ %@::error=%@",[self class],NSStringFromSelector(_cmd),error);
                }
            }
            dispatch_semaphore_signal(semaphore);
        }] resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }

    return response;
}
/**
 * execute post for NSURLResponse end
 */

/**
 * post upgrade start start
 */
- (NSString *) getUpgradeStartUrl:(NSString *)inetAddr
{
    return [NSString stringWithFormat:@"http://%@/upgrade?command=start",inetAddr];
}

- (BOOL) postUpgradeStart:(NSString *)inetAddr
{
    NSString *urlStr = [self getUpgradeStartUrl:inetAddr];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSTimeInterval timeoutSeconds = 4;
    NSURLResponse *response = [self executePostForNSULResponseURL:url Data:nil TimeoutInterval:timeoutSeconds];
    
    if (response==nil) {
        return NO;
    } else {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        int statusCode = (int)httpResponse.statusCode;
        return statusCode == HTTP_STATUS_OK;
    }
}
/**
 * post upgrade start end
 */

/**
 * push user bin start
 */
- (NSString *) getPushUserBinUrl:(NSString *)inetAddr IsUser1:(BOOL)isUser1
{
    return [NSString stringWithFormat:@"http://%@/device/bin/ugprade/?bin=user%d.bin",inetAddr,isUser1?1:2];
}

- (BOOL) pushUserBin:(NSString *)inetAddr IsUser1:(BOOL)isUser1 UserBin:(NSData *)userBin
{
    NSString *urlStr = [self getPushUserBinUrl:inetAddr IsUser1:isUser1];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLResponse *response = [self executePostForNSULResponseURL:url Data:userBin TimeoutInterval:PUSH_TIMEOUT];
    if (response==nil) {
        return NO;
    } else {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        int statusCode = (int)httpResponse.statusCode;
        return statusCode == HTTP_STATUS_OK;
    }
}
/**
 * push user bin end
 */

/**
 * reboot non-mesh device start
 */
- (NSString *) getRebootUrl:(NSString *)inetAddr
{
    return [NSString stringWithFormat:@"http://%@/upgrade?command=reset",inetAddr];
}

- (BOOL) rebootNonMeshDevice:(NSString *)inetAddr
{
    NSString *url = [self getRebootUrl:inetAddr];
    [ESPBaseApiUtil Post:url Json:nil Headers:nil];
    /**
     * for some reason, after receiving reboot command, the device will reboot and phone won't get response from
     * device. in almost all of situations, the reset command will suc, so return true forever
     */
    return YES;
}
/**
 * reboot non-mesh device device end
 */

- (BOOL) executeUpgradeLocalNonMeshDevice:(ESPDevice *)device
{
    NSString *inetAddr = device.espInetAddress;
    // check which user.bin is running
    NSNumber *isUser1RunningNumber = [self isUser1Running:inetAddr];
    BOOL isSuc = NO;
    if (isUser1RunningNumber==nil) {
        NSLog(@"%@ %@ device:%@ fail for get user running",[self class],NSStringFromSelector(_cmd),device);
        return NO;
    }
    BOOL isUser1Running = [isUser1RunningNumber boolValue];
    // get user1.bin or user2.bin
    NSString *deviceKey = device.espDeviceKey;
    NSString *romVersion = device.espRomVersionLatest;
    NSData *userBin = [self getUserBinIsUser1:!isUser1Running DeviceKey:deviceKey RomVersion:romVersion];
    if (userBin==nil) {
        NSLog(@"%@ %@ device:%@ fail for get user bin",[self class],NSStringFromSelector(_cmd),device);
        return NO;
    }
    // post upgrade start
    isSuc = [self postUpgradeStart:inetAddr];
    if (!isSuc) {
        NSLog(@"%@ %@ device:%@ fail for post upgrade start",[self class],NSStringFromSelector(_cmd),device);
        return NO;
    }
    // push user1.bin or user2.bin
    isSuc = [self pushUserBin:inetAddr IsUser1:!isUser1Running UserBin:userBin];
    if (!isSuc) {
        NSLog(@"%@ %@ device:%@ fail for push user%d.bin",[self class],NSStringFromSelector(_cmd),device,isUser1Running?1:2);
        return NO;
    }
    // reboot non-mesh device
    isSuc = [self rebootNonMeshDevice:inetAddr];
    if (!isSuc) {
        NSLog(@"%@ %@ device:%@ fail for reboot non-mesh device",[self class],NSStringFromSelector(_cmd),device);
        return NO;
    }
    return YES;
}

- (BOOL) doUpgradeLocalNonMeshDevice:(ESPDevice *)device
{
    BOOL isSuc = [self executeUpgradeLocalNonMeshDevice:device];
#ifdef DEBUG
    NSLog(@"%@ %@ device:%@ result:%@",[self class],NSStringFromSelector(_cmd),device,isSuc?@"SUC":@"FAIL");
#endif
    return isSuc;
}

#pragma mark - upgrace local mesh
- (BOOL) doUpgradeLocalMeshDevice:(ESPDevice *)device
{
    NSString *deviceKey = device.espDeviceKey;
    NSString *romVersion = device.espRomVersionLatest;
    NSString *inetAddr = device.espInetAddress;
    NSString *bssid = device.espBssid;
    // get user1.bin and user2.bin
    NSData *user1Bin = [self getUserBinIsUser1:YES DeviceKey:deviceKey RomVersion:romVersion];
    if (user1Bin==nil) {
#ifdef DEBUG
        NSLog(@"%@ %@ get user1.bin fail",[self class],NSStringFromSelector(_cmd));
#endif
        return NO;
    }
    NSData *user2Bin = [self getUserBinIsUser1:NO DeviceKey:deviceKey RomVersion:romVersion];
    if (user2Bin==nil) {
#ifdef DEBUG
        NSLog(@"%@ %@ get user2.bin fail",[self class],NSStringFromSelector(_cmd));
#endif
        return NO;
    }
    // connect to mesh device
    const int retryTime = 3;
    ESPMeshUpgradeServer *server = [[ESPMeshUpgradeServer alloc]initWithUser1Bin:user1Bin User2Bin:user2Bin InetAddr:inetAddr Bssid:bssid];
    // send upgrade start
    BOOL isUpgradeStartSuc = NO;
    for (int retry = 0; !isUpgradeStartSuc && retry < retryTime; retry++) {
        isUpgradeStartSuc = [server requestUpgradeVersion:romVersion];
    }
    if (!isUpgradeStartSuc) {
#ifdef DEBUG
        NSLog(@"%@ %@ upgraeStart fail",[self class],NSStringFromSelector(_cmd));
#endif
        return NO;
    }
    // listen device request
    BOOL isListenSuc = [server listen:TIMEOUT_SECONDS];
    if (!isListenSuc) {
#ifdef DEBUG
        NSLog(@"%@ %@ listen fail",[self class],NSStringFromSelector(_cmd));
#endif
    }
#ifdef DEBUG
    NSLog(@"%@ %@ device:%@ result:%@",[self class],NSStringFromSelector(_cmd),device,isListenSuc?@"SUC":@"FAIL");
#endif
    return isListenSuc;
}

#pragma mark - upgrade api

/**
 * upgrade device by local
 *
 * @param device the device to be upgraded
 * @return whether device upgrade local suc or fail
 */
- (BOOL) doUpgradeLocalDevice:(ESPDevice *)device
{
    ESPUser *user = [ESPUser sharedUser];
    // 1. push current device
    ESPDevice *currentDevice = [device copy];
    // 2. transform current device(isUsing=YES and deviceState=upgradeLocal)
    ESPDevice *upgradingDevice = [device copy];
    upgradingDevice.espIsUsing = YES;
    [upgradingDevice.espDeviceState clearState];
    [upgradingDevice.espDeviceState addStateUpgradeLocal];
    [user addDeviceTransform:upgradingDevice];
    [user notifyDevicesArrive];
    // 3. do upgrading by local
    BOOL isSuc = device.espIsMeshDevice ? [self doUpgradeLocalMeshDevice:device] : [self doUpgradeLocalNonMeshDevice:device];
    if (isSuc) {
        // sleep some seconds let device connect to AP
        [NSThread sleepForTimeInterval:SLEEP_TIMEOUT];
    }
    // 4. pop current device and transform current device(isUsing=NO and deviceState=offline and other origin device states)
    // it should be NO even we don't set it
    currentDevice.espIsUsing = NO;
    [currentDevice.espDeviceState clearStateLocal];
    [currentDevice.espDeviceState clearStateInternet];
    [currentDevice.espDeviceState addStateOffline];
    [user addDeviceTransform:currentDevice];
    // 5. discover devices local and internet
    [user doActionRefreshAllDevices:YES];
    [user notifyDevicesArrive];
    
    return isSuc;
}

@end
