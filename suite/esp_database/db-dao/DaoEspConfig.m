//
//  DaoEspConfig.m
//  suite
//
//  Created by 白 桦 on 8/12/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "DaoEspConfig.h"

@implementation DaoEspConfig

-(NSString *)description
{
    NSString *descriptionSuper = [super description];
    return [NSString stringWithFormat:@"%@:[lastUserEmail=%@,lastApBssid=%@]",descriptionSuper,_espConfigLastUserEmail,_espConfigLastApBssid];
}

@end
