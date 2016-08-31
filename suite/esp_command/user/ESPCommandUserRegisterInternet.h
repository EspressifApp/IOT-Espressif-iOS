//
//  ESPCommandUserRegisterInternet.h
//  suite
//
//  Created by 白 桦 on 5/24/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPRegisterResult.h"

#define URL                 @"https://iot.espressif.cn/v1/user/join/"

@interface ESPCommandUserRegisterInternet : NSObject

/**
 * Register a new account
 *
 * @param userName the account's user name
 * @param userEmail the account's user email
 * @param userPassword the account's user password, at least 6 words
 * @return the ESPRegisterResult
 */
-(ESPRegisterResult *) doCommandUserRegisterInternetUserName:(NSString *)userName UserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword;

@end
