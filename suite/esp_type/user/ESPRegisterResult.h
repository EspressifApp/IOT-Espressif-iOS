//
//  ESPRegisterResult.h
//  suite
//
//  Created by 白 桦 on 5/23/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPConstantsHttpStatus.h"

typedef enum
{
    REGISTER_SUC = HTTP_STATUS_OK,
    REGISTER_USER_OR_EMAIL_EXIST_ALREADY = HTTP_STATUS_CONFLICT,
    REGISTER_USER_OR_EMAIL_ERR_FORMAT = HTTP_STATUS_BAD_REQUEST,
    REGISTER_NETWORK_UNACCESSIBLE = -HTTP_STATUS_OK
}ESPRegisterResultEnum;


@interface ESPRegisterResult : NSObject

@property (readonly, nonatomic, assign) ESPRegisterResultEnum registerResult;
- (instancetype) initWithStatus:(int) status;

@end
