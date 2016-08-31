//
//  ESPWifi.h
//  suite
//
//  Created by 白 桦 on 7/6/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPSingletonMacro.h"

@interface ESPWifi : NSObject

DEFINE_SINGLETON_FOR_HEADER(Wifi, ESP)

@property (readonly, nonatomic, assign) BOOL espIsSsidExist;
@property (readonly, nonatomic, strong) NSString *espSsid;
@property (readonly, nonatomic, strong) NSString *espBssid;

-(void) update;

@end
