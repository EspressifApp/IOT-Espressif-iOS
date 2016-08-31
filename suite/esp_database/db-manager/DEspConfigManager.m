//
//  DEspConfigManager.m
//  suite
//
//  Created by 白 桦 on 8/12/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "DEspConfigManager.h"

#define kTableName  @"DEspConfig"

@implementation DEspConfigManager

DEFINE_SINGLETON_FOR_CLASS(ConfigManager, DEsp);

#pragma -mark UPDATE VALUE

-(void) updateValue:(DEspConfig *)dEspConfig DaoEspConfig:(DaoEspConfig *)daoEspConfig
{
    dEspConfig.espConfigLastApBssid = daoEspConfig.espConfigLastApBssid;
    dEspConfig.espConfigLastUserEmail = daoEspConfig.espConfigLastUserEmail;
}

-(void) updateDao:(DaoEspConfig *)daoEspConfig DaoEspConfig:(DEspConfig *)dEspConfig
{
    daoEspConfig.espConfigLastApBssid = dEspConfig.espConfigLastApBssid;
    daoEspConfig.espConfigLastUserEmail = dEspConfig.espConfigLastUserEmail;
}


#pragma -mark QUERY

-(DEspConfig *) queryUnique
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTableName];
    
    // result
    NSArray *configs = [dataHelper.context executeFetchRequest:request error:nil];
    NSAssert(configs.count<=1, @"daoEspConfig should be unique");
    
    DEspConfig *config = configs.count==0 ? nil : configs[0];
    [dataHelper unlock];
    
    return config;
}

-(DaoEspConfig *) query
{
    DEspConfig *config = [self queryUnique];
    if (config!=nil) {
        DaoEspConfig *daoConfig = [[DaoEspConfig alloc]init];
        [self updateDao:daoConfig DaoEspConfig:config];
        return daoConfig;
    } else {
        return nil;
    }
}

#pragma -mark INSERT
-(void) insert:(DaoEspConfig *) daoEspConfig
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // insert
    DEspConfig *config = [NSEntityDescription insertNewObjectForEntityForName:kTableName inManagedObjectContext:dataHelper.context];
    // update values
    [self updateValue:config DaoEspConfig:daoEspConfig];
    [dataHelper unlock];
    
    // save
    [dataHelper saveContext];
}

#pragma -mark REMOVE
-(void) remove
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    // query
    DEspConfig *config = [self queryUnique];
    if (config!=nil) {
        [dataHelper lock];
        // delete
        [dataHelper.context deleteObject:config];
        [dataHelper unlock];
        
        // save
        [dataHelper saveContext];
    } else {
        NSLog(@"%@ %@ there are no record can be found",self.class,NSStringFromSelector(_cmd));
    }
}

#pragma -mark UPDATE
-(void) update:(DaoEspConfig *) daoEspConfig
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    // query
    DEspConfig *config = [self queryUnique];
    if (config!=nil) {
        [dataHelper lock];
        // update values
        [self updateValue:config DaoEspConfig:daoEspConfig];
        [dataHelper unlock];
        
        // save
        [dataHelper saveContext];
    } else {
        NSLog(@"%@ %@ there are no record can be found",self.class,NSStringFromSelector(_cmd));
    }
}

#pragma -mark INSERT or UPDATE
-(void) insertOrUpdate:(DaoEspConfig *) daoEspConfig
{
    // query
    DEspConfig *config = [self queryUnique];
    if (config!=nil) {
        // update
        [self update:daoEspConfig];
    } else {
        // insert
        [self insert:daoEspConfig];
    }
}

@end
