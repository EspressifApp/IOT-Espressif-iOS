//
//  ESPActionDeviceActivateInternet.m
//  suite
//
//  Created by 白 桦 on 7/27/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDeviceActivateInternet.h"
#import "ESPCommandDeviceActivateInternet.h"

@implementation ESPActionDeviceActivateInternet

- (ESPDevice *) doActionDeviceActivateInternetUserId:(long long)userId UserKey:(NSString *)userKey RandomToken:(NSString *)randomToken
{
    ESPCommandDeviceActivateInternet *command = [[ESPCommandDeviceActivateInternet alloc]init];
    return [command doCommandDeviceActivateInternetUserId:userId UserKey:userKey RandomToken:randomToken];
}

@end
