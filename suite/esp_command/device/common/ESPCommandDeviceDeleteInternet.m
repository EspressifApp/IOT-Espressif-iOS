//
//  ESPCommandDeviceDeleteInternet.m
//  suite
//
//  Created by 白 桦 on 8/16/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandDeviceDeleteInternet.h"
#import "ESPConstantsCommand.h"
#import "ESPConstantsCommandInternet.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPBaseApiUtil.h"


#define URL @"https://iot.espressif.cn//v1/key/?method=DELETE"

@implementation ESPCommandDeviceDeleteInternet

-(BOOL) deleteDevice:(ESPDevice *)device
{
    NSString *headerKey = AUTHORIZATION;
    NSString *headerValue = [NSString stringWithFormat:@"%@ %@",TOKEN,device.espDeviceKey];
    NSDictionary *header = @{headerKey:headerValue};
    
    NSDictionary *jsonResponse = [ESPBaseApiUtil Post:URL Json:nil Headers:header];
    
    int status = -1;
    
    @try {
        if (jsonResponse != nil) {
            status = [[jsonResponse objectForKey:STATUS]intValue];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@ %@ exception:%@",self.class,NSStringFromSelector(_cmd),exception);
    }
    
    // if status was FORBIDDEN(403) implied that the device has been deleted on server already before long
    return status == HTTP_STATUS_OK || status == HTTP_STATUS_FORBIDDEN;
}

/**
 * delete the device on Server
 * @param device the device to be deleted
 *
 * @return whether the command executed suc
 */
- (BOOL) doCommandDeviceRenameInternet:(ESPDevice *)device
{
    return [self deleteDevice:device];
}

@end
