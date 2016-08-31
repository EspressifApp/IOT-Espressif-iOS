//
//  ESPVersionUtil.h
//  suite
//
//  Created by 白 桦 on 8/3/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDeviceType.h"

#define ESP_ROM_VERSION_VALUE_INVALID   -1

@interface ESPVersionUtil : NSObject

/**
 * check whether the rom version is valid
 *
 * @param version rom version
 *
 * @return whether the rom version is valid
 */
+ (BOOL) isVersionValid:(NSString *)version;

/**
 * resolve device type by rom verion
 *
 * @param version rom version
 *
 * @return device type
 */
+ (ESPDeviceType *) resolveDeviceType:(NSString *)version;

/**
 * resolve rom version value ty rom version
 *
 * @param version rom version
 *
 * @return rom version value
 */
+ (int) resolveValue:(NSString *)version;

@end
