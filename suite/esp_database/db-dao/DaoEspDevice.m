//
//  DaoEspDevice.m
//  suite
//
//  Created by 白 桦 on 8/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "DaoEspDevice.h"

@implementation DaoEspDevice

-(NSString *)description
{
    NSString *descriptionSuper = [super description];
    return [NSString stringWithFormat:@"%@:[id=%lld,key=%@,bssid=%@,type=%d,state=%d,isOwner=%@,name=%@,romCur=%@,romLat=%@,espDeviceActivatedTimestamp=%@,espPKUserId=%lld]",descriptionSuper,[_espDeviceId longLongValue],_espDeviceKey,_espDeviceBssid,[_espDeviceType intValue],[_espDeviceState intValue],[_espDeviceIsOwner boolValue]?@"YES":@"NO",_espDeviceName,_espDeviceRomCur,_espDeviceRomLat,_espDeviceActivatedTimestamp,[_espPKUserId longLongValue]];
}

@end
