//
//  ESPHttpResponseEntity.m
//  suite
//
//  Created by 白 桦 on 6/29/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPHttpResponseEntity.h"

#define NO_STATUS_VALUE     -1
#define NO_NONCE_VALUE      -1
#define STATUS              @"status"
#define NONCE               @"nonce"

@implementation ESPHttpResponseEntity

- (instancetype)init
{
    abort();
}

-(instancetype) initWithJson:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        if (json==nil) {
            // invalid format
            _isValid = NO;
            _status = NO_STATUS_VALUE;
            _nonce = NO_NONCE_VALUE;
            _json = nil;
        } else {
            _isValid = YES;
            _status = [json objectForKey:STATUS]!=nil ? [[json objectForKey:STATUS]intValue] :NO_STATUS_VALUE;
            _nonce = [json objectForKey:NONCE]!=nil ? [[json objectForKey:NONCE]longLongValue] : NO_NONCE_VALUE;
            _json = json;
        }
    }
    return self;
}

@end
