//
//  DEspUserManager.h
//  suite
//
//  Created by 白 桦 on 8/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ESPSingletonMacro.h"
#import "ESPCoreDataHelper.h"
#import "DEspUser.h"
#import "DaoEspUser.h"

@interface DEspUserManager : NSObject

DEFINE_SINGLETON_FOR_HEADER(UserManager, DEsp);

#pragma -mark QUERY
-(DaoEspUser *) queryByEmail:(NSString *) dEspUserEmail;

#pragma -mark INSERT
//-(void) insert:(DaoEspUser *) daoEspUser;

#pragma -mark REMOVE
-(void) removeById:(long long) dEspUserId;

#pragma -mark UPDATE
-(void) update:(DaoEspUser *) daoEspUser;

#pragma -mark INSERT or UPDATE
-(void) insertOrUpdate:(DaoEspUser *) daoEspUser;

@end
