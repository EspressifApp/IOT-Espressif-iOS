//
//  ESPCommandDeviceRenameInternet.m
//  suite
//
//  Created by 白 桦 on 8/16/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandDeviceRenameInternet.h"
#import "ESPConstantsCommand.h"
#import "ESPConstantsCommandInternet.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPBaseApiUtil.h"

#define URL @"https://iot.espressif.cn/v1/device/?method=PUT"

@implementation ESPCommandDeviceRenameInternet

- (BOOL) renameDevice:(ESPDevice *)device DeviceName:(NSString *)deviceName
{
    NSMutableDictionary *jsonRequest = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *jsonRequestDeviceName = [[NSMutableDictionary alloc]init];
    NSString *headerKey = AUTHORIZATION;
    NSString *headerValue = [NSString stringWithFormat:@"%@ %@",TOKEN,device.espDeviceKey];
    NSDictionary *header = @{headerKey:headerValue};
    
    [jsonRequestDeviceName setObject:deviceName forKey:NAME];
    [jsonRequest setObject:jsonRequestDeviceName forKey:DEVICE];
    
    NSDictionary *jsonResponse = [ESPBaseApiUtil Post:URL Json:jsonRequest Headers:header];
    
    int status = -1;
    
    @try {
        if (jsonResponse != nil) {
            status = [[jsonResponse objectForKey:STATUS]intValue];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@ %@ exception:%@",self.class,NSStringFromSelector(_cmd),exception);
    }
    
    return status == HTTP_STATUS_OK;
}

/**
 * rename the device on Server
 * @param device the device to be renamed
 * @param deviceName the device's new name
 *
 * @return whether the command executed suc
 */
- (BOOL) doCommandDeviceRenameInternet:(ESPDevice *)device DeviceName:(NSString *)deviceName
{
    return [self renameDevice:device DeviceName:deviceName];
}

@end
