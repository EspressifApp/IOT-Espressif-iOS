//
//  DEspApManager.h
//  suite
//
//  Created by 白 桦 on 8/12/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ESPSingletonMacro.h"
#import "ESPCoreDataHelper.h"
#import "DEspAp.h"
#import "DaoEspAp.h"

@interface DEspApManager : NSObject

DEFINE_SINGLETON_FOR_HEADER(ApManager, DEsp);

#pragma -mark QUERY
-(DaoEspAp *) queryByBssid:(NSString *) dEspApBssid;

#pragma -mark INSERT
//-(void) insert:(DaoEspAp *) daoEspAp;

#pragma -mark REMOVE
-(void) removeByBssid:(NSString *) dEspApBssid;

#pragma -mark UPDATE
-(void) update:(DaoEspAp *) daoEspAp;

#pragma -mark INSERT or UPDATE
-(void) insertOrUpdate:(DaoEspAp *) daoEspAp;

@end
