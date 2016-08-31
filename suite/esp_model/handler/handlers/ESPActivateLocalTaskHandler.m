//
//  ESPActivateLocalTaskHandler.m
//  suite
//
//  Created by 白 桦 on 7/26/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActivateLocalTaskHandler.h"

#define kActivateLocalTaskHandlerCount  2
#define kActivateLocalTaskHandlerName   @"ESPActivateLocalTaskHandler"

@implementation ESPActivateLocalTaskHandler

DEFINE_SINGLETON_FOR_CLASS(ActivateLocalTaskHandler, ESP)

- (instancetype)init
{
    self = [super initWithExecutorsCount:kActivateLocalTaskHandlerCount Name:kActivateLocalTaskHandlerName];
    return self;
}

@end
