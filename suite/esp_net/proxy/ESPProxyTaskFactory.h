//
//  ESPProxyTaskFactory.h
//  MeshProxy
//
//  Created by 白 桦 on 4/15/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPProxyTask.h"
#import "ESPSocketClient2.h"

@interface ESPProxyTaskFactory : NSObject

/**
 * create ESPProxyTask by its source socket
 *
 * @param srcSock the source socket
 * @return the ESPProxyTask
 */
+ (ESPProxyTask *)createProxyTask:(ESPSocketClient2 *)srcSock;

@end
