//
//  ESPMeshLog.m
//  MeshProxy
//
//  Created by 白 桦 on 4/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshLog.h"

@implementation ESPMeshLog

+ (void) debug: (BOOL) isDebug Class: (Class) cls Message: (NSString *) message
{
    if (isDebug) {
        NSLog(@"%@ DEBUG %@",NSStringFromClass(cls),message);
    }
}

+ (void) info: (BOOL) isDebug Class: (Class) cls Message: (NSString *) message
{
    if (isDebug) {
        NSLog(@"%@ INFO %@",NSStringFromClass(cls),message);
    }
}

+ (void) warn: (BOOL) isDebug Class: (Class) cls Message: (NSString *) message
{
    if (isDebug) {
        NSLog(@"%@ WARN %@",NSStringFromClass(cls),message);
    }
}

+ (void) error: (BOOL) isDebug Class: (Class) cls Message: (NSString *) message
{
    if (isDebug) {
        NSLog(@"%@ ERROR %@",NSStringFromClass(cls),message);
    }
}

@end
