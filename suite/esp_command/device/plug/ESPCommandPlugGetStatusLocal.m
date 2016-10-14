//
//  ESPCommandPlugGetStatusLocal.m
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandPlugGetStatusLocal.h"
#import "ESPConstantsCommand.h"
#import "ESPConstantsCommandPlug.h"
#import "ESPBaseApiUtil.h"

@implementation ESPCommandPlugGetStatusLocal

-(NSString *) getLocalUrl:(NSString *)inetAddr
{
    return [NSString stringWithFormat:@"http://%@/config?command=switch",inetAddr];
}

-(ESPStatusPlug *) resolveResponseJson:(NSDictionary *)jsonResponse DevicePlug:(ESPDevicePlug *) plug
{
    @try {
        NSDictionary *jsonResp = [jsonResponse objectForKey:KEY_RESPONSE];
        int on = [[jsonResp objectForKey:STATUS]intValue];
        ESPStatusPlug *statusPlug = [[ESPStatusPlug alloc]init];
        statusPlug.espIsOn = on == 1;
        return statusPlug;
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR %@ %@ responseJson is invalid: %@",[self class],NSStringFromSelector(_cmd),jsonResponse);
    }
    return nil;
}

/**
 * get the statusLight to the Plug by Local
 *
 * @param device the plug device
 * @return the status of the Plug
 */
-(ESPStatusPlug *) doCommandPlugGetStatusLocal:(ESPDevicePlug *)device
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
        ESPStatusPlug *status = [self resolveResponseJson:jsonResponse DevicePlug:device];
        return status;
    }
}

@end
