//
//  ESPCommandPlugPostStatusLocal.m
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandPlugPostStatusLocal.h"
#import "ESPBaseApiUtil.h"
#import "ESPConstantsCommand.h"

@implementation ESPCommandPlugPostStatusLocal

- (NSString *) getLocalUrl:(NSString *)inetAddr
{
    return [NSString stringWithFormat:@"http://%@/config?command=switch",inetAddr];
}

- (BOOL) postPlugStatusInetAddr:(NSString *)inetAddr JsonRequest:(NSDictionary *)jsonRequest Bssid:(NSString *)bssid IsMeshDevice:(BOOL)isMeshDevice
{
    NSString *url = [self getLocalUrl:inetAddr];
    NSDictionary *result = nil;
    if (bssid==nil || !isMeshDevice) {
        result = [ESPBaseApiUtil Post:url Json:jsonRequest Headers:nil];
    } else {
        result = [ESPBaseApiUtil PostForJson:url Bssid:bssid Json:jsonRequest Headers:nil];
    }
    return result!=nil;
}

- (NSDictionary *) getRequestJsonStatusPlug:(ESPStatusPlug *)statusPlug DevicePlug:(ESPDevicePlug *)plug
{
    NSMutableDictionary *requestJson = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *responseJson = [[NSMutableDictionary alloc]init];
    int status = statusPlug.espIsOn ? 1 : 0;
    [responseJson setObject:[NSNumber numberWithInt:status] forKey:STATUS];
    [requestJson setObject:responseJson forKey:RESPONSE];
    return requestJson;
}


/**
 * post the statusPlug to the Plug by Local
 *
 * @param device the plug device
 * @param statusPlug the status of Light
 * @return whether the command executed suc
 */
-(BOOL) doCommandLightPostStatusLocal:(ESPDevicePlug *)device StatusPlug:(ESPStatusPlug *)statusPlug
{
    NSString *inetAddr = device.espInetAddress;
    NSString *bssid = device.espBssid;
    BOOL isMeshDevice = device.espIsMeshDevice;
    NSDictionary *jsonRequest = [self getRequestJsonStatusPlug:statusPlug DevicePlug:device];
    BOOL result = [self postPlugStatusInetAddr:inetAddr JsonRequest:jsonRequest Bssid:bssid IsMeshDevice:isMeshDevice];
    return result;
}

@end
