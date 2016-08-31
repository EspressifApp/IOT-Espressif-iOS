//
//  ESPMeshUpgradeServer.h
//  suite
//
//  Created by 白 桦 on 6/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPMeshUpgradeServer : NSObject

-(instancetype)initWithUser1Bin:(NSData *)user1Bin User2Bin:(NSData *)user2Bin InetAddr:(NSString *)inetAddr Bssid:(NSString *)bssid;

/**
 * request mesh device upgrading
 *
 * @param version the version of bin to be upgraded
 * @return whether the mesh device is ready to upgrade
 */
-(BOOL)requestUpgradeVersion:(NSString *)version;

-(BOOL)listen:(NSTimeInterval)timeout;

@end
