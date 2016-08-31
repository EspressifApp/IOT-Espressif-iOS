//
//  ESPCommandUserLoginInternet.h
//  suite
//
//  Created by 白 桦 on 5/23/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPLoginResult.h"
#import "ESPConstantsCommandUser.h"

#define URL                 @"https://iot.espressif.cn/v1/user/login/"
#define KEY_ACCESS_TOKEN    KEY_CODE
#define KEY_OPEN_ID         @"openid"

@interface ESPCommandUserLoginInternet : NSObject

- (ESPLoginResult *) doCommandUserLoginInternetUserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword;

@end
