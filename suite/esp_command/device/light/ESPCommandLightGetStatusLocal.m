//
//  ESPCommandLightGetStatusLocal.m
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandLightGetStatusLocal.h"
#import "ESPConstantsCommandLight.h"
#import "ESPBaseApiUtil.h"
#import "ESPVersionUtil.h"
#import "ESPLightStatusUtil.h"

@implementation ESPCommandLightGetStatusLocal

-(NSString *) getLocalUrl:(NSString *)inetAddr
{
    return [NSString stringWithFormat:@"http://%@/config?command=light",inetAddr];
}

-(ESPStatusLight *) resolveResponseJson:(NSDictionary *)jsonResponse DeviceLight:(ESPDeviceLight *) light
{
    @try {
        NSString *version = light.espRomVersionCurrent;
        // new protocol
        if ([ESPVersionUtil resolveValue:version]>=[ESPVersionUtil resolveValue:ESP_LIGHT_VERSION_NEW_PROTOCOL]) {
            int statusValue = [[jsonResponse objectForKey:KEY_STATUS]intValue];
            int period = ESP_LIGHT_PERIOD_DEFAULT;
            NSDictionary *jsonColor = [jsonResponse objectForKey:KEY_COLOR];
            int red = [[jsonColor objectForKey:KEY_RED]intValue];
            int green = [[jsonColor objectForKey:KEY_GREEN]intValue];
            int blue = [[jsonColor objectForKey:KEY_BLUE]intValue];
            int white = [[jsonColor objectForKey:KEY_WHITE]intValue];
            ESPStatusLight *status = [[ESPStatusLight alloc]init];
            status.espStatus = statusValue;
            status.espPeriod = period;
            status.espRed = red;
            status.espGreen = green;
            status.espBlue = blue;
            status.espWhite = white;
            return status;
        }
        // old protocol
        else {
            int period = [[jsonResponse objectForKey:PERIOD]intValue];
            NSDictionary *rgbJson = [jsonResponse objectForKey:RGB];
            int red = [[rgbJson objectForKey:RED]intValue];
            int green = [[rgbJson objectForKey:GREEN]intValue];
            int blue = [[rgbJson objectForKey:BLUE]intValue];
            int cwhite = [[rgbJson objectForKey:CWHITE]intValue];
            int wwhite = [[rgbJson objectForKey:WWHITE]intValue];
            ESPStatusLight *status = [[ESPStatusLight alloc]init];
            status.espPeriod = period;
            status.espRed = red;
            status.espGreen = green;
            status.espBlue = blue;
            status.espCwhite = cwhite;
            status.espWwhite = wwhite;
            status = [ESPLightStatusUtil device2ui:status];
            return status;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR %@ %@ responseJson is invalid: %@",[self class],NSStringFromSelector(_cmd),jsonResponse);
    }
    return nil;
}

/**
 * get the statusLight to the Light by Local
 *
 * @param device the light device
 * @return the status of the Light
 */
-(ESPStatusLight *) doCommandLightGetStatusLocal:(ESPDeviceLight *)device
{
    NSString *inetAddr = device.espInetAddress;
    NSString *bssid = device.espBssid;
    BOOL isMeshDevice = device.espIsMeshDevice;
    
    NSString *url = [self getLocalUrl:inetAddr];
    NSDictionary *jsonResponse = nil;
    if (bssid==nil || !isMeshDevice) {
        jsonResponse = [ESPBaseApiUtil Get:url Headers:nil];
    } else {
        jsonResponse = [ESPBaseApiUtil GetForJson:url Bssid:bssid Headers:nil];
    }
    if (jsonResponse==nil) {
        return nil;
    } else {
        ESPStatusLight *status = [self resolveResponseJson:jsonResponse DeviceLight:device];
        return [ESPLightStatusUtil constrain:status];
    }
}
@end
