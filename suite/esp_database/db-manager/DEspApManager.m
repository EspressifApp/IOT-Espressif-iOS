//
//  DEspApManager.m
//  suite
//
//  Created by 白 桦 on 8/12/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "DEspApManager.h"

#define kTableName  @"DEspAp"

@implementation DEspApManager

DEFINE_SINGLETON_FOR_CLASS(ApManager, DEsp);

#pragma -mark UPDATE VALUE

-(void) updateValue:(DEspAp *)dEspAp DaoEspAp:(DaoEspAp *)daoEspAp
{
    dEspAp.espApSsid = daoEspAp.espApSsid;
    dEspAp.espApPwd = daoEspAp.espApPwd;
    dEspAp.espApBssid = daoEspAp.espApBssid;
}

-(void) updateDao:(DaoEspAp *)daoEspAp DEspUser:(DEspAp *)dEspAp
{
    daoEspAp.espApSsid = dEspAp.espApSsid;
    daoEspAp.espApPwd = dEspAp.espApPwd;
    daoEspAp.espApBssid = dEspAp.espApBssid;
}


#pragma -mark QUERY

-(DEspAp *) queryUniqueByBssid:(NSString *) dEspApBssid
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTableName];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"espApBssid == %@",dEspApBssid];
    [request setPredicate:filter];
    
    // result
    NSArray *aps = [dataHelper.context executeFetchRequest:request error:nil];
    NSAssert(aps.count<=1, @"espApBssid should be unique");
    
    DEspAp *ap = aps.count==0 ? nil : aps[0];
    [dataHelper unlock];
    
    return ap;
}

-(DaoEspAp *) queryByBssid:(NSString *) dEspApBssid
{
    DEspAp *ap = [self queryUniqueByBssid:dEspApBssid];
    if (ap!=nil) {
        DaoEspAp *daoAp = [[DaoEspAp alloc]init];
        [self updateDao:daoAp DEspUser:ap];
        return daoAp;
    } else {
        return nil;
    }
}

#pragma -mark INSERT

-(void) insert:(DaoEspAp *) daoEspAp
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // insert
    DEspAp *ap = [NSEntityDescription insertNewObjectForEntityForName:kTableName inManagedObjectContext:dataHelper.context];
    // update values
    [self updateValue:ap DaoEspAp:daoEspAp];
    [dataHelper unlock];
    
    // save
    [dataHelper saveContext];
}


#pragma -mark REMOVE

-(void) removeByBssid:(NSString *) dEspApBssid
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    // query
    DEspAp *ap = [self queryUniqueByBssid:dEspApBssid];
    if (ap!=nil) {
        [dataHelper lock];
        // delete
        [dataHelper.context deleteObject:ap];
        [dataHelper unlock];
        
        // save
        [dataHelper saveContext];
    } else {
        NSLog(@"%@ %@ dEspApBssid=%@ can't be found",self.class,NSStringFromSelector(_cmd),dEspApBssid);
    }
}


#pragma -mark UPDATE

-(void) update:(DaoEspAp *) daoEspAp
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    // query
    DEspAp *ap = [self queryUniqueByBssid:daoEspAp.espApBssid];
    if (ap!=nil) {
        [dataHelper lock];
        // update values
        [self updateValue:ap DaoEspAp:daoEspAp];
        [dataHelper unlock];
        
        // save
        [dataHelper saveContext];
    } else {
        NSLog(@"%@ %@ dEspApBssid=%@ can't be found",self.class,NSStringFromSelector(_cmd),daoEspAp.espApBssid);
    }
}


#pragma -mark INSERT or UPDATE

-(void) insertOrUpdate:(DaoEspAp *) daoEspAp
{
    // query
    DEspAp *ap = [self queryUniqueByBssid:daoEspAp.espApBssid];
    if (ap!=nil) {
        // update
        [self update:daoEspAp];
    } else {
        // insert
        [self insert:daoEspAp];
    }
}

@end
