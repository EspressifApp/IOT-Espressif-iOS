//
//  ESPDevicePlug.m
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDevicePlug.h"

@implementation ESPDevicePlug

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.espStatusPlug = [[ESPStatusPlug alloc]init];
    }
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    ESPDevicePlug *copy = [super copyWithZone:zone];
    if (copy) {
        copy.espStatusPlug = [self.espStatusPlug copy];
    }
    return copy;
}

@end
