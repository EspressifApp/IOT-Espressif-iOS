//
//  ESPLoginResult.h
//  suite
//
//  Created by 白 桦 on 5/23/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPConstantsHttpStatus.h"

typedef enum
{
    LOGIN_SUC = HTTP_STATUS_OK,
    LOGIN_PASSWORD_ERR = HTTP_STATUS_FORBIDDEN,
    LOGIN_NOT_REGISTER = HTTP_STATUS_NOT_FOUND,
    LOGIN_NETWORK_UNACCESSIBLE = -HTTP_STATUS_OK
}ESPLoginResultEnum;

@interface ESPLoginResult : NSObject

@property (readonly, nonatomic, assign) ESPLoginResultEnum loginResult;
- (instancetype) initWithStatus:(int) status;

@end
