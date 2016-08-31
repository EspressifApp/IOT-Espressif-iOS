//
//  DaoEspAp.m
//  suite
//
//  Created by 白 桦 on 8/12/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "DaoEspAp.h"

@implementation DaoEspAp

-(NSString *)description
{
    NSString *descriptionSuper = [super description];
    return [NSString stringWithFormat:@"%@:[bssid=%@,ssid=%@,pwd=%@]",descriptionSuper,_espApBssid,_espApSsid,_espApPwd];
}

@end
