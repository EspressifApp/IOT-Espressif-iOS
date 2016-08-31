//
//  ESPCommandLightPostStatusInternet.m
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandLightPostStatusInternet.h"
#import "ESPConstantsCommandInternet.h"
#import "ESPConstantsCommand.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPBaseApiUtil.h"
#import "ESPVersionUtil.h"
#import "ESPConstantsCommandLight.h"
#import "ESPLightStatusUtil.h"

@implementation ESPCommandLightPostStatusInternet

-(NSDictionary *)getRequestJson:(ESPStatusLight *)statusLight DeviceLight:(ESPDeviceLight *)light
{
    NSString *version = light.espRomVersionCurrent;
    // new protocol
    if ([ESPVersionUtil resolveValue:version]>=[ESPVersionUtil resolveValue:ESP_LIGHT_VERSION_NEW_PROTOCOL])
    {
        NSMutableDictionary *jsonRequest = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *jsonData = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *jsonColor = [[NSMutableDictionary alloc]init];
        [jsonData setObject:[NSNumber numberWithInt:statusLight.espStatus] forKey:X];
        [jsonData setObject:[NSNumber numberWithInt:ESP_LIGHT_PERIOD_DEFAULT] forKey:Y];
        switch (light.espStatusLight.espStatus) {
            case ESP_STATUS_LIGHT_ON:
            case ESP_STATUS_LIGHT_OFF:
                break;
            case ESP_STATUS_LIGHT_COLOR:
                [jsonColor setObject:[NSNumber numberWithInt:statusLight.espRed] forKey:KEY_RED];
                [jsonColor setObject:[NSNumber numberWithInt:statusLight.espGreen] forKey:KEY_GREEN];
                [jsonColor setObject:[NSNumber numberWithInt:statusLight.espBlue] forKey:KEY_BLUE];
                [jsonData setObject:jsonColor forKey:Z];
                break;
            case ESP_STATUS_LIGHT_WHITE:
                [jsonColor setObject:[NSNumber numberWithInt:statusLight.espWhite] forKey:KEY_WHITE];
                [jsonData setObject:jsonColor forKey:Z];
                break;
        }
        [jsonRequest setObject:jsonData forKey:DATAPOINT];
        return jsonRequest;
    }
    // old protocol
    else
    {
        statusLight = [ESPLightStatusUtil ui2device:statusLight];
        NSMutableDictionary *jsonRequest = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *jsonX = [[NSMutableDictionary alloc]init];
        [jsonX setValue:[NSNumber numberWithInt:statusLight.espPeriod] forKey:X];
        [jsonX setValue:[NSNumber numberWithInt:statusLight.espRed] forKey:Y];
        [jsonX setValue:[NSNumber numberWithInt:statusLight.espGreen] forKey:Z];
        [jsonX setValue:[NSNumber numberWithInt:statusLight.espBlue] forKey:K];
        [jsonX setValue:[NSNumber numberWithInt:statusLight.espCwhite] forKey:L];
        [jsonRequest setObject:jsonX forKey:DATAPOINT];
        return jsonRequest;
    }
    return nil;
}

-(BOOL) postCurrentLightStatusDeviceLight:(ESPDeviceLight *)light StatusLight:(ESPStatusLight *)statusLight
{
    NSString *deviceKey = light.espDeviceKey;
    NSString *headerKey = AUTHORIZATION;
    NSString *headerValue = [NSString stringWithFormat:@"%@ %@",TOKEN,deviceKey];
    NSDictionary *headers = @{headerKey:headerValue};
    NSDictionary *requestJson = [self getRequestJson:statusLight DeviceLight:light];
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
 * post the statusLight to the Light by Internet
 *
 * @param device the light device
 * @param statusLight the status of Light
 * @return whether the command executed suc
 */
-(BOOL) doCommandLightPostStatusInternet:(ESPDeviceLight *)device StatusLight:(ESPStatusLight *)statusLight
{
    BOOL result = [self postCurrentLightStatusDeviceLight:device StatusLight:statusLight];
    return result;
}

@end
