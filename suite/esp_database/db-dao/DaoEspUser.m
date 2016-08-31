
//
//  DaoEspUser.m
//  suite
//
//  Created by 白 桦 on 8/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "DaoEspUser.h"

@implementation DaoEspUser

-(NSString *)description
{
    NSString *descriptionSuper = [super description];
    return [NSString stringWithFormat:@"%@:[id=%lld,email=%@,key=%@,name=%@]",descriptionSuper,[_espUserId longLongValue],_espUserEmail,_espUserKey,_espUserName];
}

@end
