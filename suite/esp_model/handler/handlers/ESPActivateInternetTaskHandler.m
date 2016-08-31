
//
//  ESPActivateInternetTaskHandler.m
//  suite
//
//  Created by 白 桦 on 7/26/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActivateInternetTaskHandler.h"

#define kActivateInternetTaskHandlerCount   2
#define kActivateInternetTaskHandlerName    @"ESPActivateInternetTaskHandler"

@implementation ESPActivateInternetTaskHandler

DEFINE_SINGLETON_FOR_CLASS(ActivateInternetTaskHandler, ESP)

- (instancetype)init
{
    self = [super initWithExecutorsCount:kActivateInternetTaskHandlerCount Name:kActivateInternetTaskHandlerName];
    return self;
}


@end
