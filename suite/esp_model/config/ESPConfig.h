//
//  ESPConfig.h
//  suite
//
//  Created by 白 桦 on 8/18/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPSingletonMacro.h"

@interface ESPConfig : NSObject

DEFINE_SINGLETON_FOR_HEADER(Config, ESP);

@property (nonatomic, assign) BOOL espIsAppLaunched;
@property (readonly, nonatomic, strong) NSString *espConfigLastUserEmail;
@property (readonly, nonatomic, strong) NSString *espConfigLastApBssid;

-(void) loadConfig;

-(void) saveConfig;

-(void) saveApBssid:(NSString *)apBssid;

-(void) saveUserEmail:(NSString *)userEmail;

-(void) clearUserEmail;

-(NSString *) queryApPwd:(NSString *)apBssid;

@end