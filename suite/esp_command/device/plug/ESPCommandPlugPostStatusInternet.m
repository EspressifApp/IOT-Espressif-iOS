//
//  ESPCommandPlugPostStatusInternet.m
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandPlugPostStatusInternet.h"
#import "ESPConstantsCommandInternet.h"
#import "ESPConstantsCommand.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPBaseApiUtil.h"

@implementation ESPCommandPlugPostStatusInternet

-(NSDictionary *)getRequestJson:(ESPStatusPlug *)statusPlug DevicePlug:(ESPDevicePlug *)plug
{
    NSDictionary *jsonObject = [[NSMutableDictionary alloc]init];
    NSDictionary *jsonObjectX = [[NSMutableDictionary alloc]init];
    if(statusPlug.espIsOn) {
        [jsonObjectX setValue:[NSNumber numberWithInt:1] forKey:X];
    } else {
        [jsonObjectX setValue:[NSNumber numberWithInt:0] forKey:X];
    }
    [jsonObject setValue:jsonObjectX forKey:DATAPOINT];
    return jsonObject;
}

-(BOOL) postCurrentPlugStatusDeviceLight:(ESPDevicePlug *)plug StatusPlug:(ESPStatusPlug *)statusPlug
{
    NSString *deviceKey = plug.espDeviceKey;
    NSString *headerKey = AUTHORIZATION;
    NSString *headerValue = [NSString stringWithFormat:@"%@ %@",TOKEN,deviceKey];
    NSDictionary *headers = @{headerKey:headerValue};
    NSDictionary *requestJson = [self getRequestJson:statusPlug DevicePlug:plug];
    NSDictionary *result = [ESPBaseApiUtil Post:URL Json:requestJson Headers:headers];
    if (result==nil) {
        return NO;
    }
    int status = -1;
    if (result!=nil) {
        @try {
            status = [[result objectForKey:STATUS]intValue];
        }
        @catch (NSException *exception) {
            NSLog(@"ERROR %@ %@ result:%@",[self class],NSStringFromSelector(_cmd),result);
        }
    }
    if (status == HTTP_STATUS_OK) {
        return YES;
    } else {
        return NO;
    }
}

/**
 * post the statusPlug to the Plug by Internet
 *
 * @param device the plug device
 * @param statusPlug the status of Plug
 * @return whether the command executed suc
 */
-(BOOL) doCommandPlugPostStatusInternet:(ESPDevicePlug *)device StatusPlug:(ESPStatusPlug *)statusPlug
{
    BOOL result = [self postCurrentPlugStatusDeviceLight:device StatusPlug:statusPlug];
    return result;
}

@end
