//
//  ESPActionUesrLoginInternet.m
//  suite
//
//  Created by 白 桦 on 5/23/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionUesrLoginInternet.h"
#import "ESPCommandUserLoginInternet.h"

@implementation ESPActionUesrLoginInternet

/**
 * login by Internet
 *
 * @param userEmail user's email
 * @param userPassword user's password
 * @return ESPLoginResult
 */
- (ESPLoginResult *)doActionUserLoginInternetUserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword {
    ESPCommandUserLoginInternet *command = [[ESPCommandUserLoginInternet alloc]init];
    ESPLoginResult *loginResult = [command doCommandUserLoginInternetUserEmail:userEmail UserPassword:userPassword];
#ifdef DEBUG
    NSLog(@"%@ %@(userEmail=[%@],userPassword=[%@]): %@",self.class, NSStringFromSelector(_cmd), userEmail, userPassword, loginResult);
#endif
    return loginResult;
}

@end
