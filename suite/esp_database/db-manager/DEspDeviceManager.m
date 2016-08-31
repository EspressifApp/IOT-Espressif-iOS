//
//  DEspDeviceManager.m
//  suite
//
//  Created by 白 桦 on 8/14/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "DEspDeviceManager.h"

#define kTableName  @"DEspDevice"

@implementation DEspDeviceManager

DEFINE_SINGLETON_FOR_CLASS(DeviceManager, DEsp);

#pragma -mark UPDATE VALUE

-(void) updateValue:(DEspDevice *)dEspDevice DaoEspDevice:(DaoEspDevice *)daoEspDevice
{
    dEspDevice.espDeviceId = daoEspDevice.espDeviceId;
    dEspDevice.espPKUserId = daoEspDevice.espPKUserId;
    dEspDevice.espDeviceKey = daoEspDevice.espDeviceKey;
    dEspDevice.espDeviceName = daoEspDevice.espDeviceName;
    dEspDevice.espDeviceType = daoEspDevice.espDeviceType;
    dEspDevice.espDeviceBssid = daoEspDevice.espDeviceBssid;
    dEspDevice.espDeviceState = daoEspDevice.espDeviceState;
    dEspDevice.espDeviceRomCur = daoEspDevice.espDeviceRomCur;
    dEspDevice.espDeviceRomLat = daoEspDevice.espDeviceRomLat;
    dEspDevice.espDeviceIsOwner = daoEspDevice.espDeviceIsOwner;
    dEspDevice.espDeviceActivatedTimestamp = daoEspDevice.espDeviceActivatedTimestamp;
}

-(void) updateDao:(DaoEspDevice *)daoEspDevice DEspDevice:(DEspDevice *)dEspDevice
{
    daoEspDevice.espDeviceId = dEspDevice.espDeviceId;
    daoEspDevice.espPKUserId = dEspDevice.espPKUserId;
    daoEspDevice.espDeviceKey = dEspDevice.espDeviceKey;
    daoEspDevice.espDeviceName = dEspDevice.espDeviceName;
    daoEspDevice.espDeviceType = dEspDevice.espDeviceType;
    daoEspDevice.espDeviceBssid = dEspDevice.espDeviceBssid;
    daoEspDevice.espDeviceState = dEspDevice.espDeviceState;
    daoEspDevice.espDeviceRomCur = dEspDevice.espDeviceRomCur;
    daoEspDevice.espDeviceRomLat = dEspDevice.espDeviceRomLat;
    daoEspDevice.espDeviceIsOwner = dEspDevice.espDeviceIsOwner;
    daoEspDevice.espDeviceActivatedTimestamp = dEspDevice.espDeviceActivatedTimestamp;
}


#pragma -mark QUERY

-(DEspDevice *) queryUniqueByBssid:(NSString *) dEspDeviceBssid
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTableName];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"espDeviceBssid == %@",dEspDeviceBssid];
    [request setPredicate:filter];
    
    // result
    NSArray *devices = [dataHelper.context executeFetchRequest:request error:nil];
    NSAssert(devices.count<=1, @"espDeviceBssid should be unique");
    
    DEspDevice *device = devices.count==0 ? nil : devices[0];
    [dataHelper unlock];
    
    return device;
}

-(NSArray<DEspDevice *>*) queryDevicesByBssid:(NSString *) dEspDeviceBssid
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTableName];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"espDeviceBssid == %@",dEspDeviceBssid];
    [request setPredicate:filter];
    
    // result
    NSArray *devices = [dataHelper.context executeFetchRequest:request error:nil];
    
    [dataHelper unlock];
    
    return devices;
}

-(DEspDevice *) queryUniqueByDeviceKey:(NSString *) dEspDeviceKey
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTableName];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"espDeviceKey == %@",dEspDeviceKey];
    [request setPredicate:filter];
    
    // result
    NSArray *devices = [dataHelper.context executeFetchRequest:request error:nil];
    NSAssert(devices.count<=1, @"dEspDeviceKey should be unique");
    
    DEspDevice *device = devices.count==0 ? nil : devices[0];
    [dataHelper unlock];
    
    return device;
}

-(NSArray<DEspDevice *> *) queryDevicesByUserId:(long long) dEspUserId
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTableName];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"espPKUserId == %lld",dEspUserId];
    [request setPredicate:filter];
    
    // result
    NSArray *devices = [dataHelper.context executeFetchRequest:request error:nil];
    [dataHelper unlock];
    
    return devices;
}

-(DaoEspDevice *) queryByBssid:(NSString *) dEspDeviceBssid
{
    DEspDevice *device = [self queryUniqueByBssid:dEspDeviceBssid];
    if (device!=nil) {
        DaoEspDevice *daoDevice = [[DaoEspDevice alloc]init];
        [self updateDao:daoDevice DEspDevice:device];
        return daoDevice;
    } else {
        return nil;
    }
}

-(DaoEspDevice *) queryByDeviceKey:(NSString *) dEspDeviceKey
{
    DEspDevice *device = [self queryUniqueByDeviceKey:dEspDeviceKey];
    if (device!=nil) {
        DaoEspDevice *daoDevice = [[DaoEspDevice alloc]init];
        [self updateDao:daoDevice DEspDevice:device];
        return daoDevice;
    } else {
        return nil;
    }
}

-(NSArray<DaoEspDevice *> *) queryByUserId:(long long) dEspUserId
{
    NSArray<DEspDevice *> *devices = [self queryDevicesByUserId:dEspUserId];
    NSMutableArray<DaoEspDevice *> *daoDevices = [[NSMutableArray<DaoEspDevice *> alloc]init];
    for (DEspDevice *device in devices) {
        DaoEspDevice *daoDevice = [[DaoEspDevice alloc]init];
        [self updateDao:daoDevice DEspDevice:device];
        [daoDevices addObject:daoDevice];
    }
    return daoDevices;
}


#pragma -mark INSERT

-(void) insert:(DaoEspDevice *) daoEspDevice
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // insert
    DEspDevice *device = [NSEntityDescription insertNewObjectForEntityForName:kTableName inManagedObjectContext:dataHelper.context];
    // update values
    [self updateValue:device DaoEspDevice:daoEspDevice];
    [dataHelper unlock];
    
    // save
    [dataHelper saveContext];
}


#pragma -mark REMOVE

-(void) removeByBssid:(NSString *) dEspDeviceBssid
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    // query
    NSArray<DEspDevice *> *devices = [self queryDevicesByBssid:dEspDeviceBssid];
    if (devices.count>0) {
        [dataHelper lock];
        // delete
        for (DEspDevice *device in devices) {
            [dataHelper.context deleteObject:device];
        }
        [dataHelper unlock];
        
        // save
        [dataHelper saveContext];
    } else {
        NSLog(@"%@ %@ dEspDeviceBssid=%@ can't be found",self.class,NSStringFromSelector(_cmd),dEspDeviceBssid);
    }
}

-(void) removeByDeviceKey:(NSString *) dEspDeviceKey
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    // query
    DEspDevice *device = [self queryUniqueByDeviceKey:dEspDeviceKey];
    if (device!=nil) {
        [dataHelper lock];
        // delete
        [dataHelper.context deleteObject:device];
        [dataHelper unlock];
        
        // save
        [dataHelper saveContext];
    } else {
        NSLog(@"%@ %@ dEspDeviceKey=%@ can't be found",self.class,NSStringFromSelector(_cmd),dEspDeviceKey);
    }
}


#pragma -mark UPDATE

-(void) update:(DaoEspDevice *) daoEspDevice
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    // query
    DEspDevice *device = [self queryUniqueByDeviceKey:daoEspDevice.espDeviceKey];
    if (device!=nil) {
        [dataHelper lock];
        // update values
        [self updateValue:device DaoEspDevice:daoEspDevice];
        [dataHelper unlock];
        
        // save
        [dataHelper saveContext];
    } else {
        NSLog(@"%@ %@ dEspDeviceBssid=%@ can't be found",self.class,NSStringFromSelector(_cmd),daoEspDevice.espDeviceBssid);
    }
}


#pragma -mark INSERT or UPDATE

-(void) insertOrUpdate:(DaoEspDevice *) daoEspDevice
{
    // query
    DEspDevice *device = [self queryUniqueByDeviceKey:daoEspDevice.espDeviceKey];
    if (device!=nil) {
        // update
        [self update:daoEspDevice];
    } else {
        // insert
        [self insert:daoEspDevice];
    }
}
@end
