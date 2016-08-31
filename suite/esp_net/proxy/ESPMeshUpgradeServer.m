//
//  ESPMeshUpgradeServer.m
//  suite
//
//  Created by 白 桦 on 6/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshUpgradeServer.h"
#import "ESPHttpRequestEntity.h"
#import "ESPHttpResponseEntity.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPMeshCommunicationUtils.h"

#define ESCAPE                  @"\r\n"
#define ACTION                  @"action"
#define DOWNLOAD_ROM_BASE64     @"download_rom_base64"
#define DEVICE_UPGRADE_SUC      @"device_upgrade_success"
#define DEVICE_UPGRADE_FAIL     @"device_upgrade_failed"
#define OFFSET                  @"offset"
#define TOTAL                   @"total"
#define SIZE                    @"size"
#define SIZE_BASE64             @"size_base64"
#define VERSION                 @"version"
#define SYS_UPGRADE             @"sys_upgrade"
#define DELIVER_TO_DEVICE       @"deliver_to_device"
#define ESP_TRUE                @"true"
#define STATUS                  @"status"
#define FILE_NAME               @"filename"
#define USER1_BIN               @"user1.bin"
#define USER2_BIN               @"user2.bin"
#define MAC                     @"mdev_mac"
#define DEVICE_ROM              @"device_rom"
#define ROM_BASE64              @"rom_base64"
#define GET                     @"get"
#define SPORT                   @"sport"
#define SIP                     @"sip"
#define MESH_PORT               8000

@interface ESPMeshUpgradeServer()

@property(nonatomic, strong) NSData *user1Bin;
@property(nonatomic, strong) NSData *user2Bin;
@property(nonatomic, assign) BOOL isFirstPackage;
@property(nonatomic, assign) BOOL isFinished;
@property(nonatomic, strong) NSString *inetAddr;
@property(nonatomic, strong) NSString *bssid;
@property(nonatomic, assign) BOOL isSuc;
// for mesh device upgrade local require the socket keep connection all the time,
// mSerial is the tag to differ different sockets
@property(nonatomic, assign) int serial;

@end

typedef enum ESPRequestTypeEnum{
    INVALID_ESP_RequestType, MESH_DEVICE_UPGRADE_LOCAL_ESP_RequestType, MESH_DEVICE_UPGRADE_LOCAL_SUC_ESP_RequestType, MESH_DEVICE_UPGRADE_LOCAL_FAIL_ESP_RequestType
}ESPRequestTypeEnum;

@implementation ESPMeshUpgradeServer

- (instancetype)init
{
    abort();
}

- (instancetype)initWithUser1Bin:(NSData *)user1Bin User2Bin:(NSData *)user2Bin InetAddr:(NSString *)inetAddr Bssid:(NSString *)bssid
{
    self = [super init];
    if (self) {
        self.user1Bin = user1Bin;
        self.user2Bin = user2Bin;
        self.inetAddr = inetAddr;
        self.bssid = bssid;
    }
    return self;
}

/**
 * build mesh device upgrade request which is sent to mesh device
 *
 * @param url the url of the request
 * @param version the version of the upgrade bin
 * @return the request which is sent to mesh device
 */
-(NSString *)buildMeshDeviceUpgradeRequest1Url:(NSString *)url Version:(NSString *)version
{
    NSString *method = GET;
    ESPHttpRequestEntity *requestEntity = [[ESPHttpRequestEntity alloc]initWithMethod:method UrlString:url];
    [requestEntity.queries setObject:SYS_UPGRADE forKey:ACTION];
    [requestEntity.queries setObject:version forKey:VERSION];
    [requestEntity.queries setObject:ESP_TRUE forKey:DELIVER_TO_DEVICE];
    return [requestEntity description];
}

/**
 * analyze mesh device upgrading response
 *
 * @param respJson the response sent by mesh device
 * @return whether the mesh device is ready to upgrade
 */
-(BOOL)analyzeUpgradeResponse1:(NSDictionary * )respJson
{
    ESPHttpResponseEntity *responseEntity = [[ESPHttpResponseEntity alloc]initWithJson:respJson];
    return responseEntity.isValid && responseEntity.status == HTTP_STATUS_OK;
}

// generate long socket serial for long socket tag
-(void) generateLonSocketSerial
{
    self.serial = [ESPMeshCommunicationUtils GenerateLongSocketSerial];
}

/**
 * request mesh device upgrading
 *
 * @param version the version of bin to be upgraded
 * @return whether the mesh device is ready to upgrade
 */
-(BOOL)requestUpgradeVersion:(NSString *)version
{
    [self generateLonSocketSerial];
    NSString *url = [NSString stringWithFormat:@"http://%@/v1/device/rpc/",self.inetAddr];
    // build request
    NSString *request = [self buildMeshDeviceUpgradeRequest1Url:url Version:version];
    NSData *requestData = [request dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *postJson = [NSJSONSerialization JSONObjectWithData:requestData options:kNilOptions error:&error];
    if (error!=nil) {
#ifdef DEBUG
        NSLog(@"%@ %@ request isn't json :%@",[self class],NSStringFromSelector(_cmd),request);
#endif
        abort();
    }
    // send request to mesh device and receive the response
    NSString *bssid = self.bssid;
    int serial = self.serial;
    NSDictionary *responseJson = [ESPMeshCommunicationUtils JsonPost:url Bssid:bssid Serial:serial Json:postJson Headers:nil];
    if (responseJson==nil) {
#ifdef DEBUG
        NSLog(@"%@ %@ fail",[self class],NSStringFromSelector(_cmd));
#endif
        return NO;
    }
    // analyze the response
    BOOL isResponseSuc = [self analyzeUpgradeResponse1:responseJson];
#ifdef DEBUG
    NSLog(@"%@ %@ isResponseSuc:%@",[self class],NSStringFromSelector(_cmd),isResponseSuc?@"YES":@"NO");
#endif
    return isResponseSuc;
}

/**
 * analyze mesh device upgrading request
 *
 * @param requestJson the request sent by mesh device
 * @return the request type
 */
-(ESPRequestTypeEnum) analyzeUpgradeRequest1:(NSDictionary *)requestJson
{
    @try {
        NSDictionary *jsonGet = [requestJson objectForKey:GET];
        NSString *action = [jsonGet objectForKey:ACTION];
        if ([action isEqualToString:DOWNLOAD_ROM_BASE64]) {
            return MESH_DEVICE_UPGRADE_LOCAL_ESP_RequestType;
        } else if ([action isEqualToString:DEVICE_UPGRADE_SUC]) {
            return MESH_DEVICE_UPGRADE_LOCAL_SUC_ESP_RequestType;
        } else if ([action isEqualToString:DEVICE_UPGRADE_FAIL]) {
            return MESH_DEVICE_UPGRADE_LOCAL_FAIL_ESP_RequestType;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@ %@ exception:%@",[self class],NSStringFromSelector(_cmd),exception);
    }
    return INVALID_ESP_RequestType;
}

/**
 * execute mesh device upgrade local
 *
 * @param requestJson the request from mesh device
 * @return the response to be sent to mesh device
 */
-(NSString *) executeMeshDeviceUpgradeLocal:(NSDictionary *)requestJson
{
    @try {
        NSDictionary *jsonGet = [requestJson objectForKey:GET];
        NSString *action = [jsonGet objectForKey:ACTION];
        NSString *filename = [jsonGet objectForKey:FILE_NAME];
        NSString *version = [jsonGet objectForKey:VERSION];
        NSData *bin = nil;
        if ([filename isEqualToString:USER1_BIN]) {
            bin = self.user1Bin;
        } else if([filename isEqualToString:USER2_BIN]) {
            bin = self.user2Bin;
        } else {
            NSLog(@"ERROR %@ %@ filename: %@ is invalid, isn't 'user1.bin' or 'user2.bin'",[self class],NSStringFromSelector(_cmd),filename);
            return nil;
        }
        int total = (int)[bin length];
        int offset = [[jsonGet objectForKey:OFFSET]intValue];
        int size = [[jsonGet objectForKey:SIZE]intValue];
#ifdef DEBUG
        NSLog(@"%@ %@ offset = %d,size = %d",[self class],NSStringFromSelector(_cmd), offset,size);
#endif
        if (offset + size > total) {
            size = total - offset;
        }
        NSData *subBin = [bin subdataWithRange:NSMakeRange(offset, size)];
        NSData *encoded = [subBin base64EncodedDataWithOptions:kNilOptions];
        int size_base64 = (int)[encoded length];
        // Response is like this:
        // {"status": 200, "device_rom": {"rom_base64":
        // "6QMAAAQAEEAAABBAQGYAAAQOAEASwfAJAw==",
        // "filename": "user1.bin", "version": "v1.2", "offset": 0, "action":
        NSMutableDictionary *jsonResponse = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *jsonDeviceRom = [[NSMutableDictionary alloc]init];
        [jsonDeviceRom setObject:filename forKey:FILE_NAME];
        [jsonDeviceRom setObject:version forKey:VERSION];
        [jsonDeviceRom setObject:[NSNumber numberWithInt:offset] forKey:OFFSET];
        [jsonDeviceRom setObject:[NSNumber numberWithInt:total] forKey:TOTAL];
        [jsonDeviceRom setObject:[NSNumber numberWithInt:size] forKey:SIZE];
        [jsonDeviceRom setObject:[NSNumber numberWithInt:size_base64] forKey:SIZE_BASE64];
        [jsonDeviceRom setObject:action forKey:ACTION];
        [jsonDeviceRom setObject:@"__rombase64" forKey:ROM_BASE64];
        [jsonResponse setObject:jsonDeviceRom forKey:DEVICE_ROM];
        [jsonResponse setObject:[NSNumber numberWithInt:200] forKey:STATUS];
        
        NSString *encodedStr = [[NSString alloc]initWithData:encoded encoding:NSUTF8StringEncoding];
        
        NSData* responseData = [NSJSONSerialization dataWithJSONObject:jsonResponse options:kNilOptions error:nil];
        NSString *responseStr = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        responseStr = [responseStr stringByReplacingOccurrencesOfString:@"__rombase64" withString:encodedStr];
        return responseStr;
    }
    @catch (NSException *exception) {
        NSLog(@"%@ %@ exception:%@",[self class],NSStringFromSelector(_cmd),exception);
    }
    return nil;
}

/**
 * execute mesh device upgrade local suc
 *
 * @return the response to be sent to mesh device
 */
-(NSString *) executeMeshDeviceUpgradeLocalSuc
{
    // set isFinished and isSuc
    self.isFinished = YES;
    self.isSuc = YES;
    // build reset request as the mesh device's response
    NSString *urlStr = [NSString stringWithFormat:@"http://%@/upgrade?action=sys_reboot",self.inetAddr];
    NSString *method = @"POST";
    ESPHttpRequestEntity *requestEntity = [[ESPHttpRequestEntity alloc]initWithMethod:method UrlString:urlStr];
    return [requestEntity description];
}

/**
 * execute mesh device upgrade local fail
 */
-(void) executeMeshDeviceUpgradeLocalFail
{
    // set isFinished and isSuc
    self.isFinished = YES;
    self.isSuc = NO;
}

/**
 * handle one request
 *
 * @return whether handle suc
 */
-(BOOL) handle
{
    NSString *url = [NSString stringWithFormat:@"http://%@/v1/device/rpc/",self.inetAddr];
    NSString *bssid = self.bssid;
    int serial = self.serial;
    // for device requirement, taskTimeout has to be set 15 seconds, but it won't take so much time except first 2 packages
    int taskTimeout = 15000;
    if (self.isFirstPackage) {
        taskTimeout = 15000;
        self.isFirstPackage = NO;
    }
    // receive request from the mesh device
    NSDictionary *requestJson = [ESPMeshCommunicationUtils JsonReadOnly:url Bssid:bssid Serial:serial TaskTimeout:taskTimeout Headers:nil];
    if (requestJson==nil) {
#ifdef DEBUG
        NSLog(@"ERROR %@ %@ requestJson is nil",[self class],NSStringFromSelector(_cmd));
#endif
        return NO;
    }
#ifdef DEBUG
    NSLog(@"%@ %@ receive request from mesh device:%@",[self class],NSStringFromSelector(_cmd),requestJson);
#endif
    // analyze the request and build the response
    ESPRequestTypeEnum requestType = [self analyzeUpgradeRequest1:requestJson];
    NSString *response = nil;
    switch (requestType) {
        case INVALID_ESP_RequestType:
#ifdef DEBUG
            NSLog(@"%@ %@ requestType is INVALID",[self class],NSStringFromSelector(_cmd));
#endif
            return NO;
        case MESH_DEVICE_UPGRADE_LOCAL_ESP_RequestType:
#ifdef DEBUG
            NSLog(@"%@ %@ requestType is LOCAL",[self class],NSStringFromSelector(_cmd));
#endif
            response = [self executeMeshDeviceUpgradeLocal:requestJson];
            break;
        case MESH_DEVICE_UPGRADE_LOCAL_FAIL_ESP_RequestType:
#ifdef DEBUG
            NSLog(@"%@ %@ requestType is LOCAL FAIL",[self class],NSStringFromSelector(_cmd));
#endif
            [self executeMeshDeviceUpgradeLocalFail];
            break;
        case MESH_DEVICE_UPGRADE_LOCAL_SUC_ESP_RequestType:
#ifdef DEBUG
            NSLog(@"%@ %@ requestType is LOCAL SUC",[self class],NSStringFromSelector(_cmd));
#endif
            response = [self executeMeshDeviceUpgradeLocalSuc];
            break;
    }
    // send the response to the mesh device
    if (response != nil) {
#ifdef DEBUG
        NSLog(@"%@ %@ send response to mesh device:%@",[self class],NSStringFromSelector(_cmd),response);
#endif
        NSDictionary *postJson = nil;
        NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        postJson = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        if (error!=nil) {
            NSLog(@"ERROR %@ %@ error:%@,response:%@",[self class],NSStringFromSelector(_cmd),error,response);
            abort();
        }
        BOOL isWriteSuc = [ESPMeshCommunicationUtils JsonNonResponsePost:url Bssid:bssid Serial:serial Json:postJson]!=nil;
#ifdef DEBUG
        NSLog(@"%@ %@ send response to mesh device isSuc:%@",[self class],NSStringFromSelector(_cmd),isWriteSuc?@"YES":@"NO");
#endif
        return isWriteSuc;
    }
    return NO;
}

-(BOOL)listen:(NSTimeInterval)timeout
{
    // clear isSuc and isFinished
    self.isSuc = NO;
    self.isFinished = NO;
    self.isFirstPackage = YES;
    
    NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
    while (!self.isFinished && [[NSDate date] timeIntervalSince1970] - start < timeout)
    {
        if (![self handle]) {
#ifdef DEBUG
            NSLog(@"ERROR %@ %@ handle() fail",[self class],NSStringFromSelector(_cmd));
#endif
            [self executeMeshDeviceUpgradeLocalFail];
            break;
        }
    }
    
    if (!self.isFinished && !self.isSuc) {
#ifdef DEBUG
        NSLog(@"ERROR %@ %@ fail for timeout:%f s",[self class],NSStringFromSelector(_cmd),timeout);
#endif
    }
    
    return self.isSuc;
}

@end
