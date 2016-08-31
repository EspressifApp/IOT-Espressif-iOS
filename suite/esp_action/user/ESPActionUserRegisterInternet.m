//
//  ESPActionUserRegisterInternet.m
//  suite
//
//  Created by 白 桦 on 5/24/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionUserRegisterInternet.h"
#import "ESPCommandUserRegisterInternet.h"

@implementation ESPActionUserRegisterInternet

/**
 * register user account by Internet
 *
 * @param userName user's name
 * @param userEmail user's email
 * @param userPassword user's password
 * @return ESPRegisterResult
 */
-(ESPRegisterResult *) doActionUserRegisterInternetUserName:(NSString *)userName UserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword
{
    ESPCommandUserRegisterInternet *command = [[ESPCommandUserRegisterInternet alloc]init];
    ESPRegisterResult *registerResult = [command doCommandUserRegisterInternetUserName:userName UserEmail:userEmail UserPassword:userPassword];
#ifdef DEBUG
    NSLog(@"%@ %@(userName=[%@],userEmail=[%@],userPassword=[%@]): %@",self.class, NSStringFromSelector(_cmd),userName, userEmail, userPassword, registerResult);
#endif
    return registerResult;
}
@end
