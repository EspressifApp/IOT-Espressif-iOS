//
//  DEspTester.m
//  suite
//
//  Created by 白 桦 on 8/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "DEspTester.h"
#import "DaoEspUser.h"
#import "DEspUserManager.h"
#import "DaoEspAp.h"
#import "DEspApManager.h"
#import "DaoEspConfig.h"
#import "DEspConfigManager.h"
#import "DaoEspDevice.h"
#import "DEspDeviceManager.h"

@implementation DEspTester

#pragma -mark USER

+(void)testUserManagerInsertOrUpdate
{
    DEspUserManager *userManager = [DEspUserManager sharedUserManager];

    DaoEspUser *daoUser = [[DaoEspUser alloc]init];
    daoUser.espUserEmail = @"user@email.com";
    daoUser.espUserId = [NSNumber numberWithLongLong:12345];
    daoUser.espUserKey = @"user12345-key";
    daoUser.espUserName = @"user12345-name";
    
    [userManager insertOrUpdate:daoUser];
}

+(void)testUserManagerRemove
{
    DEspUserManager *userManager = [DEspUserManager sharedUserManager];
    
    [userManager removeById:-1];
}

+(void)testUserManagerUpdate
{
    DEspUserManager *userManager = [DEspUserManager sharedUserManager];
    
    DaoEspUser *daoUser = [[DaoEspUser alloc]init];
    daoUser.espUserEmail = @"user-update@email.com";
    daoUser.espUserId = [NSNumber numberWithLongLong:12345];
    daoUser.espUserKey = @"user12345-key";
    daoUser.espUserName = @"user12345-name";
    
    [userManager update:daoUser];
}

+(void)testUserManagerQuery
{
    DEspUserManager *userManager = [DEspUserManager sharedUserManager];
    
    DaoEspUser *daoUser = [userManager queryByEmail:@"user-update@email.com"];
    NSLog(@"daoUser:%@",daoUser);
}

+(void)testUserManager
{
    [self testUserManagerInsertOrUpdate];
    [self testUserManagerRemove];
    [self testUserManagerUpdate];
    [self testUserManagerQuery];
}

#pragma -mark AP

+(void)testApManagerInsertOrUpdate
{
    DEspApManager *apManager = [DEspApManager sharedApManager];
    
    DaoEspAp *daoAp = [[DaoEspAp alloc]init];
    
    daoAp.espApPwd = @"apPwd";
    daoAp.espApSsid = @"apSsid";
    daoAp.espApBssid = @"apBssid";
    
    [apManager insertOrUpdate:daoAp];
}

+(void)testApManagerRemove
{
    DEspApManager *apManager = [DEspApManager sharedApManager];
    
    [apManager removeByBssid:@"apBssid"];
}

+(void)testApManagerUpdate
{
    DEspApManager *apManager = [DEspApManager sharedApManager];
    
    DaoEspAp *daoAp = [[DaoEspAp alloc]init];
    
    daoAp.espApPwd = @"apPwd-update";
    daoAp.espApSsid = @"apSsid-update";
    daoAp.espApBssid = @"apBssid-null";
    
    [apManager update:daoAp];
}

+(void)testApManagerQuery
{
    DEspApManager *apManager = [DEspApManager sharedApManager];
    
    DaoEspAp *daoAp = [apManager queryByBssid:@"apBssid"];
    NSLog(@"daoAp:%@",daoAp);
}

+(void)testApManager
{
    [self testApManagerInsertOrUpdate];
    [self testApManagerRemove];
    [self testApManagerUpdate];
    [self testApManagerQuery];
}

#pragma -mark CONFIG

+(void)testConfigManagerInsertOrUpdate
{
    
    DEspConfigManager *configManager = [DEspConfigManager sharedConfigManager];
    
    DaoEspConfig *daoConfig = [[DaoEspConfig alloc]init];
    
    daoConfig.espConfigLastUserEmail = @"email@config";
    daoConfig.espConfigLastApBssid = @"apBssid@config";
    
    [configManager insertOrUpdate:daoConfig];
}

+(void)testConfigManagerRemove
{
    DEspConfigManager *configManager = [DEspConfigManager sharedConfigManager];
    
    [configManager remove];
}

+(void)testConfigManagerUpdate
{
    DEspConfigManager *configManager = [DEspConfigManager sharedConfigManager];
    
    DaoEspConfig *daoConfig = [[DaoEspConfig alloc]init];
    
    daoConfig.espConfigLastUserEmail = @"email-update@config";
    daoConfig.espConfigLastApBssid = @"apBssid-update@config";
    
    [configManager update:daoConfig];
}

+(void)testConfigManagerQuery
{
    DEspConfigManager *configManager = [DEspConfigManager sharedConfigManager];
    
    DaoEspConfig *daoConfig = [configManager query];
    
    NSLog(@"daoConfig:%@",daoConfig);
}

+(void)testConfigManager
{
    [self testConfigManagerInsertOrUpdate];
//    [self testConfigManagerRemove];
//    [self testConfigManagerUpdate];
    [self testConfigManagerQuery];
}

#pragma -mark DEVICE

+(void)testDeviceManagerInsertOrUpdate
{
    DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
    
    DaoEspDevice *daoDevice = [[DaoEspDevice alloc]init];
    
    daoDevice.espDeviceId = [NSNumber numberWithLongLong:12345678];
    daoDevice.espPKUserId = [NSNumber numberWithLongLong:12345];
    daoDevice.espDeviceKey = @"deviceKey";
    daoDevice.espDeviceName = @"deviceName";
    daoDevice.espDeviceType = [NSNumber numberWithInt:1];
    daoDevice.espDeviceBssid = @"deviceBssid";
    daoDevice.espDeviceState = [NSNumber numberWithInt:2];
    daoDevice.espDeviceRomCur = @"devcieRomCur";
    daoDevice.espDeviceRomLat = @"deviceRomLat";
    daoDevice.espDeviceIsOwner = [NSNumber numberWithBool:YES];
    daoDevice.espDeviceActivatedTimestamp = [NSDate date];
    
    [deviceManager insertOrUpdate:daoDevice];

}

+(void)testDeviceManagerRemove
{
    DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
    
    [deviceManager removeByBssid:@"5c:cf:7f:0a:13:fe"];
    
//    [deviceManager removeByDeviceKey:@"deviceKey"];
}

+(void)testDeviceManagerUpdate
{
    DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
    
    DaoEspDevice *daoDevice = [[DaoEspDevice alloc]init];
    
    daoDevice.espDeviceId = [NSNumber numberWithLongLong:12345678000];
    daoDevice.espPKUserId = [NSNumber numberWithLongLong:12345000];
    daoDevice.espDeviceKey = @"deviceKeyUpdate";
    daoDevice.espDeviceName = @"deviceNameUpdate";
    daoDevice.espDeviceType = [NSNumber numberWithInt:1000];
    daoDevice.espDeviceBssid = @"deviceBssid";
    daoDevice.espDeviceState = [NSNumber numberWithInt:2000];
    daoDevice.espDeviceRomCur = @"devcieRomCurUpdate";
    daoDevice.espDeviceRomLat = @"deviceRomLatUpdate";
    daoDevice.espDeviceIsOwner = [NSNumber numberWithBool:NO];
    daoDevice.espDeviceActivatedTimestamp = [NSDate date];
    
    [deviceManager update:daoDevice];
}

+(void)testDeviceManagerQuery
{
    DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
    
//    DaoEspDevice *daoDevice1 = [deviceManager queryByBssid:@"deviceBssid"];
//    NSLog(@"daoDevice1:%@",daoDevice1);

    DaoEspDevice *daoDevice2 = [deviceManager queryByDeviceKey:@"deviceKey"];
    NSLog(@"daoDevice2:%@",daoDevice2);
    
    NSArray<DaoEspDevice *> *daoDevices = [deviceManager queryByUserId:123456];
    NSLog(@"daoDevices:%@",daoDevices);
}

+(void)testDeviceManager
{
    [self testDeviceManagerInsertOrUpdate];
    [self testDeviceManagerRemove];
    [self testDeviceManagerUpdate];
    [self testDeviceManagerQuery];
}

#pragma -mark TEST

+(void)test
{
    NSLog(@"Running %@ '%@'",[DEspTester class],NSStringFromSelector(_cmd));
//    [self testUserManager];
//    [self testApManager];
//    [self testConfigManager];
//    [self testDeviceManager];
}

@end