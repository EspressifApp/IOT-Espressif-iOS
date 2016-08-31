//
//  ESPCommandUserLoginInternet.m
//  suite
//
//  Created by 白 桦 on 5/23/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandUserLoginInternet.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPConstantsCommandInternet.h"
#import "ESPConstantsCommand.h"
#import "ESPBaseApiUtil.h"
#import "ESPUser.h"

@implementation ESPCommandUserLoginInternet

- (ESPLoginResult *) doCommandUserLoginInternetUserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword
{
    NSDictionary *jsonRequest = [[NSDictionary alloc]initWithObjectsAndKeys:userEmail,EMAIL,userPassword,PASSWORD,@"1",REMEMBER, nil];
    NSDictionary *jsonResponse = [ESPBaseApiUtil Post:URL Json:jsonRequest Headers:nil];
    ESPLoginResult *result = nil;
    if (jsonResponse == nil) {
        result = [[ESPLoginResult alloc]initWithStatus:-HTTP_STATUS_OK];
#ifdef DEBUG
        NSLog(@"%@ %@(userEmail=[%@],userPassword=[%@]): %@",self.class,NSStringFromSelector(_cmd),userEmail,userPassword,result);
#endif
        return result;
    }
    int status = [[jsonResponse objectForKey:STATUS] intValue];
    if (status == HTTP_STATUS_OK) {
        NSDictionary *userDict = [jsonResponse objectForKey:USER];
        long long userId = [[userDict objectForKey:ID]longLongValue];
        NSString *userName = [userDict objectForKey:USER_NAME];
        NSDictionary *keyDict = [jsonResponse objectForKey:KEY];
        NSString *userKey = [keyDict objectForKey:TOKEN];
        
        ESPUser *user = [ESPUser sharedUser];
        user.espUserKey = userKey;
        user.espUserId = userId;
        user.espUserName = userName;
        user.espUserEmail = userEmail;
    }
    result = [[ESPLoginResult alloc]initWithStatus:status];
#ifdef DEBUG
    NSLog(@"%@ %@(userEmail=[%@],userPassword=[%@]): %@",self.class,NSStringFromSelector(_cmd),userEmail,userPassword,result);
#endif
    return result;
}

@end
