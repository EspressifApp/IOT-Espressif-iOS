//
//  ESPStatusPlug.m
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPStatusPlug.h"

@implementation ESPStatusPlug

-(BOOL) isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[ESPStatusPlug class]]) {
        return NO;
    }

    const ESPStatusPlug *other = object;
    return self.espIsOn == other.espIsOn;
}

-(id) copyWithZone:(NSZone *)zone
{
    ESPStatusPlug *copy = [[[self class]allocWithZone:zone]init];
    if (copy) {
        copy.espIsOn = self.espIsOn;
    }
    return copy;
}

-(NSString *)description
{
    NSString *hexAddr = [super description];
    return [NSString stringWithFormat:@"[%@ isOn=%@]",hexAddr,self.espIsOn?@"YES":@"NO"];
}

@end
