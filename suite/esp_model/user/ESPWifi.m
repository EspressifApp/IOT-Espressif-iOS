//
//  ESPWifi.m
//  suite
//
//  Created by 白 桦 on 7/6/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPWifi.h"

#import <SystemConfiguration/CaptiveNetwork.h>

@implementation ESPWifi

DEFINE_SINGLETON_FOR_CLASS(Wifi, ESP)

- (void)update
{
    NSDictionary *netInfo = [self fetchNetInfo];
    _espSsid = [netInfo objectForKey:@"SSID"];
    _espBssid = [netInfo objectForKey:@"BSSID"];
}

- (BOOL)espIsSsidExist
{
    NSLog(@"_espSsid:%@",_espSsid);
    return _espSsid!=nil;
}

// refer to http://stackoverflow.com/questions/5198716/iphone-get-ssid-without-private-library
- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

@end
