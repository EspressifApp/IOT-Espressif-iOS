//
//  ESPRandomUtil.m
//  suite
//
//  Created by 白 桦 on 7/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPRandomUtil.h"

@implementation ESPRandomUtil

+ (NSString *) map:(int)i
{
    if (i<10) {
        return [NSString stringWithFormat:@"%d",i];
    } else {
        char c = (char)('a' + i - 10);
        return [NSString stringWithFormat:@"%c",c];
    }
}

+ (NSString *) random:(NSUInteger)length
{
    NSMutableString *token = [[NSMutableString alloc]init];
    for (int i = 0; i < length; i++) {
        int x = arc4random()%36;
        [token appendString:[self map:x]];
    }
    return token;
}

/**
 * generate random key for 40 places token, the value range is "0-9" and "a-z"
 *
 * @return random key for 40 places token like "a23b5678e012345z7890123e567890r234r6789x"
 */
+ (NSString *) random40
{
    return [self random:40];
}

@end
