//
//  DEspUserManager.m
//  suite
//
//  Created by 白 桦 on 8/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "DEspUserManager.h"

#define kTableName  @"DEspUser"

@implementation DEspUserManager

DEFINE_SINGLETON_FOR_CLASS(UserManager, DEsp);

#pragma -mark UPDATE VALUE

-(void) updateValue:(DEspUser *)dEspUser DaoEspUser:(DaoEspUser *)daoEspUser
{
    dEspUser.espUserEmail = daoEspUser.espUserEmail;
    dEspUser.espUserId = daoEspUser.espUserId;
    dEspUser.espUserKey = daoEspUser.espUserKey;
    dEspUser.espUserName = daoEspUser.espUserName;
}

-(void) updateDao:(DaoEspUser *)daoEspUser DEspUser:(DEspUser *)dEspUser
{
    daoEspUser.espUserEmail = dEspUser.espUserEmail;
    daoEspUser.espUserName = dEspUser.espUserName;
    daoEspUser.espUserKey = dEspUser.espUserKey;
    daoEspUser.espUserId = dEspUser.espUserId;
}

#pragma -mark QUERY

-(DEspUser *) queryUniqueByUserId:(long long) dEspUserId
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTableName];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"espUserId == %lld",dEspUserId];
    [request setPredicate:filter];
    
    // result
    NSArray *users = [dataHelper.context executeFetchRequest:request error:nil];
    NSAssert(users.count<=1, @"espUserId is Primary Key");
    DEspUser *user = users.count==0 ? nil : users[0];
    [dataHelper unlock];
    
    return user;
}

-(DEspUser *) queryUniqueByEmail:(NSString *) dEspUserEmail
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTableName];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"espUserEmail == %@",dEspUserEmail];
    [request setPredicate:filter];
    
    // result
    NSArray *users = [dataHelper.context executeFetchRequest:request error:nil];
    NSAssert(users.count<=1, @"dEspUserEmail is Unique");
    DEspUser *user = users.count==0 ? nil : users[0];
    [dataHelper unlock];
    
    return user;
}

-(DaoEspUser *) queryByEmail:(NSString *) dEspUserEmail
{
    DEspUser *user = [self queryUniqueByEmail:dEspUserEmail];
    if (user!=nil) {
        DaoEspUser *daoUser = [[DaoEspUser alloc]init];
        [self updateDao:daoUser DEspUser:user];
        return daoUser;
    } else {
        return nil;
    }
}


#pragma -mark INSERT

-(void) insert:(DaoEspUser *) daoEspUser
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    [dataHelper lock];
    // insert
    DEspUser *user = [NSEntityDescription insertNewObjectForEntityForName:kTableName inManagedObjectContext:dataHelper.context];
    // update values
    [self updateValue:user DaoEspUser:daoEspUser];
    [dataHelper unlock];
    
    // save
    [dataHelper saveContext];
}


#pragma -mark REMOVE

-(void) removeById:(long long) dEspUserId
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];

    // query
    DEspUser *user = [self queryUniqueByUserId:dEspUserId];
    if (user!=nil) {
        [dataHelper lock];
        // delete
        [dataHelper.context deleteObject:user];
        [dataHelper unlock];
        
        // save
        [dataHelper saveContext];
    } else {
        NSLog(@"%@ %@ dEspUserId=%lld can't be found",self.class,NSStringFromSelector(_cmd),dEspUserId);
    }
}


#pragma -mark UPDATE

-(void) update:(DaoEspUser *) daoEspUser
{
    ESPCoreDataHelper *dataHelper = [ESPCoreDataHelper sharedCoreDataHelper];
    
    // query
    DEspUser *user = [self queryUniqueByUserId:[daoEspUser.espUserId longLongValue]];
    if (user!=nil) {
        [dataHelper lock];
        // update values
        [self updateValue:user DaoEspUser:daoEspUser];
        [dataHelper unlock];
        
        // save
        [dataHelper saveContext];
    } else {
        NSLog(@"%@ %@ dEspUserId=%lld can't be found",self.class,NSStringFromSelector(_cmd),[daoEspUser.espUserId longLongValue]);
    }
}


#pragma -mark INSERT or UPDATE

-(void) insertOrUpdate:(DaoEspUser *) daoEspUser
{
    // query
    DEspUser *user = [self queryUniqueByUserId:[daoEspUser.espUserId longLongValue]];
    if (user!=nil) {
        // update
        [self update:daoEspUser];
    } else {
        // insert
        [self insert:daoEspUser];
    }
}


@end