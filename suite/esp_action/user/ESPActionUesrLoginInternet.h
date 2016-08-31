//
//  ESPActionUesrLoginInternet.h
//  suite
//
//  Created by 白 桦 on 5/23/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPLoginResult.h"

@interface ESPActionUesrLoginInternet : NSObject

/**
 * login by Internet
 *
 * @param userEmail user's email
 * @param userPassword user's password
 * @return ESPLoginResult
 */
- (ESPLoginResult *)doActionUserLoginInternetUserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword;

@end
