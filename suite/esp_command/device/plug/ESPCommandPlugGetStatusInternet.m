//
//  ESPCommandPlugGetStatusInternet.m
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandPlugGetStatusInternet.h"
#import "ESPConstantsCommand.h"
#import "ESPConstantsCommandInternet.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPConstantsCommandLight.h"
#import "ESPBaseApiUtil.h"
#import "ESPVersionUtil.h"
#import "ESPLightStatusUtil.h"

@implementation ESPCommandPlugGetStatusInternet

-(NSDictionary *)sendRequest:(ESPDevicePlug *)plug
{
    NSString *deviceKey = plug.espDeviceKey;
    NSString *headerKey = AUTHORIZATION;
    NSString *headerValue = [NSString stringWithFormat:@"%@ %@",TOKEN,deviceKey];
    NSDictionary *headers = @{headerKey:headerValue};
    NSDictionary *result = [ESPBaseApiUtil Get:URL Headers:headers];
    return result;
}

-(ESPStatusPlug *) resolveResponseJson:(NSDictionary *)jsonResponse DevicePlug:(ESPDevicePlug *) plug
{
    @try {
        int status = -1;
        status = [[jsonResponse objectForKey:STATUS]intValue];
        if (status==HTTP_STATUS_OK) {
            NSDictionary *data = [jsonResponse objectForKey:DATAPOINT];
            int x = [[data objectForKey:X]intValue];
            ESPStatusPlug *statusPlug = [[ESPStatusPlug alloc]init];
            statusPlug.espIsOn = x == 1;
            return statusPlug;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR: %@ %@ invalid response:%@",[self class],NSStringFromSelector(_cmd),jsonResponse);
    }
    return nil;
}


/**
 * get the statusPlug to the Plug by Internet
 *
 * @param device the plug device
 * @return the status of the Plug
 */
-(ESPStatusPlug *)doCommandPlugGetStatusInternet:(ESPDevicePlug *)device
{
    NSDictionary *responseJson = [self sendRequest:device];
    if (responseJson==nil) {
        return nil;
    }
    ESPStatusPlug *status = [self resolveResponseJson:responseJson DevicePlug:device];
    return status;

}


@end
