//
//  ESPDeviceLight.m
//  suite
//
//  Created by 白 桦 on 5/25/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDeviceLight.h"

@implementation ESPDeviceLight

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.espStatusLight = [[ESPStatusLight alloc]init];
    }
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    ESPDeviceLight *copy = [super copyWithZone:zone];
    if (copy) {
        copy.espStatusLight = [self.espStatusLight copy];
    }
    return copy;
}

@end
