//
//  ESPConfig.m
//  suite
//
//  Created by 白 桦 on 8/18/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPConfig.h"
#import "DEspConfigManager.h"
#import "DEspApManager.h"
#import "ESPGlobalTaskHandler.h"

@implementation ESPConfig

DEFINE_SINGLETON_FOR_CLASS(Config, ESP);

-(DaoEspConfig *) daoEspConfig
{
    DaoEspConfig *daoEspConfig = [[DaoEspConfig alloc]init];
    daoEspConfig.espConfigLastApBssid = _espConfigLastApBssid;
    daoEspConfig.espConfigLastUserEmail = _espConfigLastUserEmail;
    return daoEspConfig;
}

-(void) loadConfig
{
    DEspConfigManager *configManager = [DEspConfigManager sharedConfigManager];
    DaoEspConfig *daoEspConfig = [configManager query];
    if (daoEspConfig!=nil) {
        _espConfigLastApBssid = daoEspConfig.espConfigLastApBssid;
        _espConfigLastUserEmail = daoEspConfig.espConfigLastUserEmail;
    }
}

-(void) saveConfig
{
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        DEspConfigManager *configManager = [DEspConfigManager sharedConfigManager];
        DaoEspConfig *daoEspConfig = self.daoEspConfig;
        [configManager insertOrUpdate:daoEspConfig];
    };
    
    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    [handler submit:task];
}

-(void) saveApBssid:(NSString *)apBssid
{
    _espConfigLastApBssid = apBssid;
    [self saveConfig];
}

-(void) saveUserEmail:(NSString *)userEmail
{
    _espConfigLastUserEmail = userEmail;
    [self saveConfig];
}

-(void) clearUserEmail
{
    _espConfigLastUserEmail = nil;
    [self saveConfig];
}

-(NSString *) queryApPwd:(NSString *)apBssid
{
    DEspApManager *apManager = [DEspApManager sharedApManager];
    DaoEspAp *daoAp = [apManager queryByBssid:apBssid];
    if (daoAp!=nil) {
        return daoAp.espApPwd;
    } else {
        return nil;
    }
}

-(NSString *) description
{
    NSString *descriptionSuper = [super description];
    return [NSString stringWithFormat:@"%@:[isAppLaunched=%@,lastUserEmail=%@,lastApBssid=%@]",descriptionSuper,_espIsAppLaunched?@"YES":@"NO",_espConfigLastUserEmail,_espConfigLastApBssid];
}

@end
