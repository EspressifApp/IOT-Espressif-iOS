//
//  ESPLoginResult.m
//  suite
//
//  Created by 白 桦 on 5/23/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPLoginResult.h"

@implementation ESPLoginResult

- (instancetype)init
{
    abort();
}

- (instancetype)initWithStatus:(int)status
{
    self = [super init];
    if (self) {
        _loginResult = status;
    }
    return self;
}

- (NSString *)description
{
    NSString *hexAddr = [super description];
    return [NSString stringWithFormat:@"[%@ status %d]",hexAddr,_loginResult];
}

@end
