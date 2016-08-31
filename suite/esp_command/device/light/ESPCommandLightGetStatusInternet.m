
//
//  ESPCommandLightGetStatusInternet.m
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandLightGetStatusInternet.h"
#import "ESPConstantsCommand.h"
#import "ESPConstantsCommandInternet.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPConstantsCommandLight.h"
#import "ESPBaseApiUtil.h"
#import "ESPVersionUtil.h"
#import "ESPLightStatusUtil.h"

@implementation ESPCommandLightGetStatusInternet

-(ESPStatusLight *) resolveResponseJson:(NSDictionary *)jsonResponse DeviceLight:(ESPDeviceLight *) light
{
    @try {
        int status = -1;
        status = [[jsonResponse objectForKey:STATUS]intValue];
        if (status==HTTP_STATUS_OK) {
            NSString *version = light.espRomVersionCurrent;
            // new protocol
            if ([ESPVersionUtil resolveValue:version]>=[ESPVersionUtil resolveValue:ESP_LIGHT_VERSION_NEW_PROTOCOL]){
                NSDictionary *data = [jsonResponse objectForKey:DATAPOINT];
                int statusValue = [[data objectForKey:X]intValue];
                // period is 1000 forever for Y
                int period = ESP_LIGHT_PERIOD_DEFAULT;
                NSDictionary *color = [data objectForKey:Z];
                int red = [[color objectForKey:KEY_RED]intValue];
                int green = [[color objectForKey:KEY_GREEN]intValue];
                int blue = [[color objectForKey:KEY_BLUE]intValue];
                int white = [[color objectForKey:KEY_WHITE]intValue];
                ESPStatusLight *statusLight = [[ESPStatusLight alloc]init];
                statusLight.espStatus = statusValue;
                statusLight.espPeriod = period;
                statusLight.espRed = red;
                statusLight.espGreen = green;
                statusLight.espBlue = blue;
                statusLight.espWhite = white;
                return statusLight;
            }
            // old protocol
            else {
                NSDictionary *data = [jsonResponse objectForKey:DATAPOINT];
                int period = [[data objectForKey:X]intValue];
                int red = [[data objectForKey:Y]intValue];
                int green = [[data objectForKey:Z]intValue];
                int blue = [[data objectForKey:K]intValue];
                int white = [[data objectForKey:L]intValue];
                ESPStatusLight *statusLight = [[ESPStatusLight alloc]init];
                statusLight.espPeriod = period;
                statusLight.espRed = red;
                statusLight.espGreen = green;
                statusLight.espBlue = blue;
                statusLight.espCwhite = white;
                statusLight.espWwhite = white;
                statusLight = [ESPLightStatusUtil device2ui:statusLight];
                return statusLight;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR: %@ %@ invalid response:%@",[self class],NSStringFromSelector(_cmd),jsonResponse);
    }
    return nil;
}

-(NSDictionary *)sendRequest:(ESPDeviceLight *)light
{
    NSString *deviceKey = light.espDeviceKey;
    NSString *headerKey = AUTHORIZATION;
    NSString *headerValue = [NSString stringWithFormat:@"%@ %@",TOKEN,deviceKey];
    NSDictionary *headers = @{headerKey:headerValue};
    NSDictionary *result = [ESPBaseApiUtil Get:URL Headers:headers];
    return result;
}

/**
 * get the statusLight to the Light by Internet
 *
 * @param device the light device
 * @return the status of the Light
 */
-(ESPStatusLight *)doCommandLightGetStatusInternet:(ESPDeviceLight *)device
{
    NSDictionary *responseJson = [self sendRequest:device];
    if (responseJson==nil) {
        return nil;
    }
    ESPStatusLight *status = [self resolveResponseJson:responseJson DeviceLight:device];
    return status!=nil ? [ESPLightStatusUtil constrain:status] : nil;
}

@end
