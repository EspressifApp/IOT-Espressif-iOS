//
//  ESPCommandUserRegisterInternet.m
//  suite
//
//  Created by 白 桦 on 5/24/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandUserRegisterInternet.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPConstantsCommandUser.h"
#import "ESPConstantsCommand.h"
#import "ESPBaseApiUtil.h"
#import "ESPUser.h"

@implementation ESPCommandUserRegisterInternet

/**
 * Register a new account
 *
 * @param userName the account's user name
 * @param userEmail the account's user email
 * @param userPassword the account's user password, at least 6 words
 * @return the ESPRegisterResult
 */
-(ESPRegisterResult *) doCommandUserRegisterInternetUserName:(NSString *)userName UserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword
{
    NSDictionary *jsonRequest = [NSDictionary dictionaryWithObjectsAndKeys:userName,USER_NAME,userEmail,USER_EMAIL,userPassword,USER_PASSWORD, nil];
    NSDictionary *jsonResponse = [ESPBaseApiUtil Post:URL Json:jsonRequest Headers:nil];
    ESPRegisterResult *result = nil;
    if (jsonResponse==nil) {
        result = [[ESPRegisterResult alloc]initWithStatus:-HTTP_STATUS_OK];
#ifdef DEBUG
        NSLog(@"%@ %@(userName=[%@],userEmail=[%@],userPassword=[%@]): %@",self.class,NSStringFromSelector(_cmd),userName,userEmail,userPassword,result);
#endif
        return result;
    }
    int status = [[jsonResponse objectForKey:STATUS] intValue];
    if (status==HTTP_STATUS_OK) {
        ESPUser *user = [ESPUser sharedUser];
        user.espUserEmail = userEmail;
    }
    result = [[ESPRegisterResult alloc]initWithStatus:status];
#ifdef DEBUG
    NSLog(@"%@ %@(userName=[%@],userEmail=[%@],userPassword=[%@]): %@",self.class,NSStringFromSelector(_cmd),userName,userEmail,userPassword,result);
#endif
    return result;
}

@end
