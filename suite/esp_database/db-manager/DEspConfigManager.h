//
//  DEspConfigManager.h
//  suite
//
//  Created by 白 桦 on 8/12/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ESPSingletonMacro.h"
#import "ESPCoreDataHelper.h"
#import "DEspConfig.h"
#import "DaoEspConfig.h"

/**
 * DEspConfigManager is special, no more than one record is in it
 */
@interface DEspConfigManager : NSObject

DEFINE_SINGLETON_FOR_HEADER(ConfigManager, DEsp);

#pragma -mark QUERY
-(DaoEspConfig *) query;

#pragma -mark INSERT
//-(void) insert:(DEspConfig *) daoEspConfig;

#pragma -mark REMOVE
-(void) remove;

#pragma -mark UPDATE
-(void) update:(DaoEspConfig *) daoEspConfig;

#pragma -mark INSERT or UPDATE
-(void) insertOrUpdate:(DaoEspConfig *) daoEspConfig;

@end
