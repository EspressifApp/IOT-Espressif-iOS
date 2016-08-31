//
//  ESPGlobalTaskHandler.h
//  suite
//
//  Created by 白 桦 on 8/17/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPTaskHandler.h"
#import "ESPSingletonMacro.h"

@interface ESPGlobalTaskHandler : ESPTaskHandler

DEFINE_SINGLETON_FOR_HEADER(GlobalTaskHandler, ESP);

@end
