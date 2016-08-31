//
//  ESPRegisterResult.m
//  suite
//
//  Created by 白 桦 on 5/23/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPRegisterResult.h"

@implementation ESPRegisterResult

- (instancetype)init
{
    abort();
}

- (instancetype)initWithStatus:(int)status
{
    self = [super init];
    if (self) {
        _registerResult = status;
    }
    return self;
}

- (NSString *)description
{
    NSString *hexAddr = [super description];
    return [NSString stringWithFormat:@"[%@ status %d]",hexAddr,_registerResult];
}

@end
