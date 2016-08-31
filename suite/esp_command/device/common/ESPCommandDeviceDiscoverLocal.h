//
//  ESPCommandDeviceDiscoverLocal.h
//  suite
//
//  Created by 白 桦 on 6/1/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPCommandDeviceDiscoverLocal : NSObject

/**
 * discover the ESPDevice in the same AP
 * @return the array of device
 */
- (NSArray *) doCommandDiscoverLocal;

@end
