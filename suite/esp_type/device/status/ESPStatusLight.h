//
//  ESPStatusLight.h
//  suite
//
//  Created by 白 桦 on 5/25/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDeviceStatus.h"

#define ESP_STATUS_LIGHT_NULL   -1
#define ESP_STATUS_LIGHT_OFF    0
#define ESP_STATUS_LIGHT_ON     1
#define ESP_STATUS_LIGHT_COLOR  2
#define ESP_STATUS_LIGHT_WHITE  3

@interface ESPStatusLight : ESPDeviceStatus<NSCopying>

@property (nonatomic, assign) int espStatus;
@property (nonatomic, assign) int espWhite;
@property (nonatomic, assign) int espCwhite;
@property (nonatomic, assign) int espWwhite;
@property (nonatomic, assign) int espRed;
@property (nonatomic, assign) int espGreen;
@property (nonatomic, assign) int espBlue;
@property (nonatomic, assign) int espPeriod;

@end
