//
//  ESPGlobalTaskHandler.m
//  suite
//
//  Created by 白 桦 on 8/17/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPGlobalTaskHandler.h"

#define kActivateLocalTaskHandlerCount  1
#define kActivateLocalTaskHandlerName   @"ESPGlobalTaskHandler"

@implementation ESPGlobalTaskHandler

DEFINE_SINGLETON_FOR_CLASS(GlobalTaskHandler, ESP);

- (instancetype)init
{
    self = [super initWithExecutorsCount:kActivateLocalTaskHandlerCount Name:kActivateLocalTaskHandlerName];
    return self;
}

@end
