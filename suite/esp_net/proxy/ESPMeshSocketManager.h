//
//  ESPMeshSocketManager.h
//  MeshProxy
//
//  Created by 白 桦 on 4/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPSingletonMacro.h"
#import "ESPBlockingMutableArray.h"
#import "ESPProxyTask.h"

@interface ESPMeshSocketManager : NSObject

DEFINE_SINGLETON_FOR_HEADER(MeshSocketManager, ESP)

@property (nonatomic, strong) __block ESPBlockingMutableArray* meshSockeBlockArray;

/**
 * @synchronized(self)
 */
- (void) start;

/**
 * @synchronized(self)
 */
- (void) stop;

/**
 * @synchronized(self)
 */
- (void) accept: (ESPProxyTask *)task;

@end
