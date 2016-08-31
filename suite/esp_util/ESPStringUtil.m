//
//  ESPStringUtil.m
//  suite
//
//  Created by 白 桦 on 5/24/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPStringUtil.h"

@implementation ESPStringUtil

+ (BOOL) isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
