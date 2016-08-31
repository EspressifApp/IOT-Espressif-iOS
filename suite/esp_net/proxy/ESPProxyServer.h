//
//  ESPProxyServer.h
//  MeshProxy
//
//  Created by 白 桦 on 4/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPSingletonMacro.h"
#import "ESPSocketServer2.h"
#import "ESPBlockingMutableArray.h"

@interface ESPProxyServer : NSObject

@property (nonatomic, strong) __block ESPBlockingMutableArray* taskBlockArray;
@property (nonatomic, strong) __block ESPSocketServer2* socketServer;

DEFINE_SINGLETON_FOR_HEADER(ProxyServer,ESP)

/**
 * start the ESPProxyServer
 */
- (void) start;

/**
 * stop the ESPProxyServer
 */
- (void) stop;

/**
 * get the ESPProxyServer port
 *
 * @return the ESPProxyServer port
 */
- (int) getEspProxyServerPort;
@end
