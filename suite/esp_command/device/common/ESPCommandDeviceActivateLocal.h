//
//  ESPCommandDeviceActivateLocal.h
//  suite
//
//  Created by 白 桦 on 7/26/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPCommandDeviceActivateLocal : NSObject

/**
 * make the device activate on Server
 *
 * @param inetAddress the device's ip address
 * @param randomToken 40 randomToken
 * @return whether the command executed suc
 */
-(BOOL) doCommandDeviceActivateLocalInetAddr:(NSString *)inetAddr RandomToken:(NSString *)randomToken;

/**
 * make the mesh device activate on Server
 *
 * @param bssid the mesh device's bssid
 * @param inetAddr the mesh device's ip address
 * @param randomToken 40 randomToken
 * @return whether the command executed suc
 */
-(BOOL) doCommandMeshDeviceActivateLoalBssid:(NSString *)bssid InetAddr:(NSString *)inetAddr RandomToken:(NSString *)randomToken;

@end
