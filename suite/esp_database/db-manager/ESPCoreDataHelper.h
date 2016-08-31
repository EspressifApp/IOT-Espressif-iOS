//
//  ESPCoreDataHelper.h
//  CoreDataWarehouse
//
//  Created by 白 桦 on 8/9/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ESPSingletonMacro.h"

/**
 * ESPCoreDataHelper make CoreData easy to be used.
 *
 * for concurrent issues, the developer who use ESPCoreDataHelper has the duty
 * in calling lock: at sometime and unlock as well
 *
 */
@interface ESPCoreDataHelper : NSObject

DEFINE_SINGLETON_FOR_HEADER(CoreDataHelper, ESP);

@property (nonatomic, readonly) NSManagedObjectContext *context;

/**
 * save the NSManagedObjectContext to persistent store.
 * (lock: and unlock: are called in it)
 */
-(void)saveContext;

/**
 * lock which should be called before adding,deleting,updaing and querying NSManagedObjectContext
 */
-(void)lock;

/**
 * unlock which should be called after  adding,deleting,updaing and querying NSManagedObjectContext
 */
-(void)unlock;

@end
