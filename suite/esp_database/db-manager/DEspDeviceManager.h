//
//  DEspDeviceManager.h
//  suite
//
//  Created by 白 桦 on 8/14/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPSingletonMacro.h"
#import "ESPCoreDataHelper.h"
#import "DEspDevice.h"
#import "DaoEspDevice.h"

@interface DEspDeviceManager : NSObject

DEFINE_SINGLETON_FOR_HEADER(DeviceManager, DEsp);

#pragma -mark QUERY
//-(DaoEspDevice *) queryByBssid:(NSString *) dEspDeviceBssid;

-(DaoEspDevice *) queryByDeviceKey:(NSString *) dEspDeviceKey;

-(NSArray<DaoEspDevice *> *) queryByUserId:(long long) dEspUserId;
#pragma -mark INSERT
//-(void) insert:(DaoEspDevice *) daoEspDevice;

#pragma -mark REMOVE
-(void) removeByBssid:(NSString *) dEspDeviceBssid;

-(void) removeByDeviceKey:(NSString *) dEspDeviceKey;

#pragma -mark UPDATE
-(void) update:(DaoEspDevice *) daoEspDevice;

#pragma -mark INSERT or UPDATE
-(void) insertOrUpdate:(DaoEspDevice *) daoEspDevice;

@end
