//
//  ESPActionUserRegisterInternet.h
//  suite
//
//  Created by 白 桦 on 5/24/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPRegisterResult.h"

@interface ESPActionUserRegisterInternet : NSObject

/**
 * register user account by Internet
 *
 * @param userName user's name
 * @param userEmail user's email
 * @param userPassword user's password
 * @return ESPRegisterResult
 */
-(ESPRegisterResult *) doActionUserRegisterInternetUserName:(NSString *)userName UserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword;

@end
