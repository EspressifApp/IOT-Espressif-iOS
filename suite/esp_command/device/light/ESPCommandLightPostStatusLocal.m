//
//  ESPCommandLightPostStatusLocal.m
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandLightPostStatusLocal.h"
#import "ESPConstantsCommandLight.h"
#import "ESPBaseApiUtil.h"
#import "ESPVersionUtil.h"
#import "ESPLightStatusUtil.h"
#import "ESPConstantsCommand.h"
#import "ESPConstantsCommandLight.h"
#import "ESPConstantsCommandInternet.h"

@implementation ESPCommandLightPostStatusLocal

- (NSString *) getLocalUrl:(NSString *)inetAddr
{
    return [NSString stringWithFormat:@"http://%@/config?command=light",inetAddr];
}

- (BOOL) postLightStatusInetAddr:(NSString *)inetAddr JsonRequest:(NSDictionary *)jsonRequest Bssid:(NSString *)bssid IsMeshDevice:(BOOL)isMeshDevice IsResponseRequired:(BOOL)isResponseRequired
{
    NSString *url = [self getLocalUrl:inetAddr];
    NSDictionary *result = nil;
    if (isResponseRequired) {
        if (bssid==nil || !isMeshDevice) {
            result = [ESPBaseApiUtil Post:url Json:jsonRequest Headers:nil];
        } else {
            result = [ESPBaseApiUtil PostForJson:url Bssid:bssid Json:jsonRequest Headers:nil];
        }
        return result!=nil;
    } else {
        // don't support isResponseRequired = NO at the moment
        abort();
    }
    return NO;
}


- (NSDictionary *) getRequestJsonStatusLight:(ESPStatusLight *)statusLight IsResponseRequired:(BOOL)isResponseRequired DeviceLight:(ESPDeviceLight *)light
{
    NSString *version = light.espRomVersionCurrent;
    // new protocol
    if ([ESPVersionUtil resolveValue:version]>=[ESPVersionUtil resolveValue:ESP_LIGHT_VERSION_NEW_PROTOCOL])
    {
        NSMutableDictionary *requestJson = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *rgbJson = [[NSMutableDictionary alloc]init];
        [requestJson setValue:[NSNumber numberWithInt:statusLight.espStatus] forKey:KEY_STATUS];
        [requestJson setValue:[NSNumber numberWithInt:ESP_LIGHT_PERIOD_DEFAULT] forKey:KEY_PERIOD];
        switch (statusLight.espStatus) {
            case ESP_STATUS_LIGHT_NULL:
            case ESP_STATUS_LIGHT_ON:
            case ESP_STATUS_LIGHT_OFF:
                break;
            case ESP_STATUS_LIGHT_COLOR:
                [rgbJson setValue:[NSNumber numberWithInt:statusLight.espRed] forKey:KEY_RED];
                [rgbJson setValue:[NSNumber numberWithInt:statusLight.espGreen] forKey:KEY_GREEN];
                [rgbJson setValue:[NSNumber numberWithInt:statusLight.espBlue] forKey:KEY_BLUE];
                [requestJson setValue:rgbJson forKey:KEY_COLOR];
                break;
            case ESP_STATUS_LIGHT_WHITE:
                [rgbJson setValue:[NSNumber numberWithInt:statusLight.espWhite] forKey:KEY_WHITE];
                [requestJson setValue:rgbJson forKey:KEY_COLOR];
                break;
        }
        if (isResponseRequired) {
            [requestJson setValue:[NSNumber numberWithInt:1] forKey:RESPONSE];
        } else {
            [requestJson setValue:[NSNumber numberWithInt:0] forKey:RESPONSE];
        }
        return requestJson;
    }
    // old protocol
    else
    {
        statusLight = [ESPLightStatusUtil ui2device:statusLight];
        NSMutableDictionary *requestJson = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *rgbJson = [[NSMutableDictionary alloc]init];
        [rgbJson setValue:[NSNumber numberWithInt:statusLight.espRed] forKey:RED];
        [rgbJson setValue:[NSNumber numberWithInt:statusLight.espGreen] forKey:GREEN];
        [rgbJson setValue:[NSNumber numberWithInt:statusLight.espBlue] forKey:BLUE];
        [rgbJson setValue:[NSNumber numberWithInt:statusLight.espCwhite] forKey:CWHITE];
        [rgbJson setValue:[NSNumber numberWithInt:statusLight.espWwhite] forKey:WWHITE];
        [requestJson setValue:[NSNumber numberWithInt:statusLight.espPeriod] forKey:PERIOD];
        [requestJson setValue:rgbJson forKey:RGB];
        if (isResponseRequired) {
            [requestJson setValue:[NSNumber numberWithInt:1] forKey:RESPONSE];
        } else {
            [requestJson setValue:[NSNumber numberWithInt:0] forKey:RESPONSE];
        }
        return requestJson;
    }
    return nil;
}

/**
 * post the statusLight to the Light by Local
 *
 * @param device the light device
 * @param statusLight the status of Light
 * @return whether the command executed suc
 */
-(BOOL) doCommandLightPostStatusLocal:(ESPDeviceLight *)device StatusLight:(ESPStatusLight *)statusLight
{
    NSString *inetAddr = device.espInetAddress;
    NSString *bssid = device.espBssid;
    BOOL isMeshDevice = device.espIsMeshDevice;
    BOOL isResponseRequired = YES;
    NSDictionary *jsonRequest = [self getRequestJsonStatusLight:statusLight IsResponseRequired:isResponseRequired DeviceLight:device];
    BOOL result = [self postLightStatusInetAddr:inetAddr JsonRequest:jsonRequest Bssid:bssid IsMeshDevice:isMeshDevice IsResponseRequired:isResponseRequired];
    return result;
}

@end
