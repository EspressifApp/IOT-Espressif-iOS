//
//  ESPMeshNetUtil2.h
//  MeshProxy
//
//  Created by 白 桦 on 5/3/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPIOTAddress.h"

@interface ESPMeshNetUtil2 : NSObject

+ (ESPIOTAddress *) GetTopoIOTAddress5:(NSString *)rootInetAddress Bssid:(NSString *)bssid;

+ (NSArray *) GetTopoIOTAddressArray5:(NSString *)rootInetAddress RootBssid:(NSString *)rootBssid;

@end
