//
//  ESPRandomUtil.h
//  suite
//
//  Created by 白 桦 on 7/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPRandomUtil : NSObject

/**
 * generate random key for 40 places token, the value range is "0-9" and "a-z"
 *
 * @return random key for 40 places token like "a23b5678e012345z7890123e567890r234r6789x"
 */
+ (NSString *) random40;

@end
