//
//  ESPStatusLight.m
//  suite
//
//  Created by 白 桦 on 5/25/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPStatusLight.h"

@implementation ESPStatusLight

-(BOOL) isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[ESPStatusLight class]]) {
        return NO;
    }
    
    const ESPStatusLight *other = object;
    return self.espWhite == other.espWhite && self.espCwhite == other.espCwhite && self.espWwhite == other.espWwhite && self.espRed == other.espRed && self.espGreen == other.espGreen && self.espBlue == other.espBlue && self.espPeriod == other.espPeriod;
}

-(id) copyWithZone:(NSZone *)zone
{
    ESPStatusLight *copy = [[[self class]allocWithZone:zone]init];
    if (copy) {
        copy.espCwhite = self.espCwhite;
        copy.espWwhite = self.espWwhite;
        copy.espRed = self.espRed;
        copy.espGreen = self.espGreen;
        copy.espBlue = self.espBlue;
        copy.espPeriod = self.espPeriod;
        copy.espWhite = self.espWhite;
        copy.espStatus = self.espStatus;
    }
    return copy;
}

-(NSString *)description
{
    NSString *hexAddr = [super description];
    return [NSString stringWithFormat:@"[%@ cwhite=%d,wwhite=%d,red=%d,green=%d,blue=%d,period=%d,status=%d,white=%d]",hexAddr,self.espCwhite,self.espWwhite,self.espRed,self.espGreen,self.espBlue,self.espPeriod,self.espStatus,self.espWhite];
}

@end
