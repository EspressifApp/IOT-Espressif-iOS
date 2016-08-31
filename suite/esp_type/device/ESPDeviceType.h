//
//  ESPDeviceType.h
//  MeshProxy
//
//  Created by 白 桦 on 4/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ESPDeivceTypeEnum
{
    NEW_ESP_DEVICETYPE,
    ROOT_ESP_DEVICETYPE,
    PLUG_ESP_DEVICETYPE,
    LIGHT_ESP_DEVICETYPE,
    HUMITURE_ESP_DEVICETYPE,
    FLAMMABLE_ESP_DEVICETYPE,
    VOLTAGE_ESP_DEVICETYPE,
    REMOTE_ESP_DEVICETYPE,
    PLUGS_ESP_DEVICETYPE,
    SOUNDBOX_ESP_DEVICETYPE
} ESPDeviceTypeEnum;

@interface ESPDeviceType : NSObject<NSCopying>

@property (nonatomic, assign) int espSerial;
@property (nonatomic, assign) BOOL espIsLocalSupport;

- (ESPDeviceTypeEnum)espTypeEnum;

+ (ESPDeviceType *)resolveDeviceTypeBySerial:(int) serial;

+ (ESPDeviceType *)resolveDeviceTypeByTypeName:(NSString *) typeName;

+ (BOOL) isTypeSupportedAlready:(ESPDeviceType *)deviceType;

@end