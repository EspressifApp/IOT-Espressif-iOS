//
//  ESPDeviceType.m
//  MeshProxy
//
//  Created by 白 桦 on 4/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDeviceType.h"

@interface ESPDeviceType()

@property (nonatomic, assign) ESPDeviceTypeEnum typeEnum;
@property (nonatomic, assign) NSString *typeName;

@end

@implementation ESPDeviceType

#pragma mark - Arrays
+ (NSArray *)TypeEnumArray
{
    static dispatch_once_t predicate;
    static NSArray *TypeEnumArray;
    dispatch_once(&predicate, ^{
        TypeEnumArray = [[NSArray alloc]initWithObjects:
                         [[NSNumber alloc]initWithInt:NEW_ESP_DEVICETYPE],
                         [[NSNumber alloc]initWithInt:ROOT_ESP_DEVICETYPE],
                         [[NSNumber alloc]initWithInt:PLUG_ESP_DEVICETYPE],
                         [[NSNumber alloc]initWithInt:LIGHT_ESP_DEVICETYPE],
                         [[NSNumber alloc]initWithInt:HUMITURE_ESP_DEVICETYPE],
                         [[NSNumber alloc]initWithInt:FLAMMABLE_ESP_DEVICETYPE],
                         [[NSNumber alloc]initWithInt:VOLTAGE_ESP_DEVICETYPE],
                         [[NSNumber alloc]initWithInt:REMOTE_ESP_DEVICETYPE],
                         [[NSNumber alloc]initWithInt:PLUGS_ESP_DEVICETYPE],
                         [[NSNumber alloc]initWithInt:SOUNDBOX_ESP_DEVICETYPE],
                         nil];
    });
    return TypeEnumArray;
}

+ (NSArray *)SerialArray
{
    static dispatch_once_t predicate;
    static NSArray *SerialArray;
    dispatch_once(&predicate, ^{
        SerialArray = [[NSArray alloc]initWithObjects:
                         [[NSNumber alloc]initWithInt:-1],
                         [[NSNumber alloc]initWithInt:-2],
                         [[NSNumber alloc]initWithInt:23701],
                         [[NSNumber alloc]initWithInt:45772],
                         [[NSNumber alloc]initWithInt:12335],
                         [[NSNumber alloc]initWithInt:3835],
                         [[NSNumber alloc]initWithInt:68574],
                         [[NSNumber alloc]initWithInt:2355],
                         [[NSNumber alloc]initWithInt:47446],
                         [[NSNumber alloc]initWithInt:43902],
                         nil];
    });
    return SerialArray;
}

+ (NSArray *)TypeNameArray
{
    static dispatch_once_t predicate;
    static NSArray *TypeNameArray;
    dispatch_once(&predicate, ^{
        TypeNameArray = [[NSArray alloc]initWithObjects:
                         @"New",
                         @"Root Router",
                         @"Plug",
                         @"Light",
                         @"Humiture",
                         @"Flammable Gas",
                         @"Voltage",
                         @"Remote",
                         @"Plugs",
                         @"Soundbox",
                         nil];
    });
    return TypeNameArray;
}

+ (NSArray *)IsLocalSupportArray
{
    static dispatch_once_t predicate;
    static NSArray *IsLocalSupportArray;
    dispatch_once(&predicate, ^{
        IsLocalSupportArray = [[NSArray alloc]initWithObjects:
                               [[NSNumber alloc]initWithBool:YES],
                               [[NSNumber alloc]initWithBool:NO],
                               [[NSNumber alloc]initWithBool:YES],
                               [[NSNumber alloc]initWithBool:YES],
                               [[NSNumber alloc]initWithBool:NO],
                               [[NSNumber alloc]initWithBool:NO],
                               [[NSNumber alloc]initWithBool:NO],
                               [[NSNumber alloc]initWithBool:YES],
                               [[NSNumber alloc]initWithBool:YES],
                               [[NSNumber alloc]initWithBool:YES],
                               nil];
    });
    return IsLocalSupportArray;
}

+ (NSArray *)DeviceTypeArray
{
    static dispatch_once_t predicate;
    static NSArray *DeviceTypeArray;
    dispatch_once(&predicate, ^{
        NSArray *TypeEnumArray = [ESPDeviceType TypeEnumArray];
        NSArray *SerialArray = [ESPDeviceType SerialArray];
        NSArray *TypeNameArray = [ESPDeviceType TypeNameArray];
        NSArray *IsLocalSupportArray = [ESPDeviceType IsLocalSupportArray];
        NSUInteger count = [TypeEnumArray count];
        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:count];
        for (int i = 0; i < count; ++i) {
            int serial = [[SerialArray objectAtIndex:i]intValue];
            NSString *typeName = [TypeNameArray objectAtIndex:i];
            BOOL isLocalSupport = [[IsLocalSupportArray objectAtIndex:i]boolValue];
            ESPDeviceTypeEnum typeEnum = [[TypeEnumArray objectAtIndex:i]intValue];
            // deviceType is const in DeviceTypeArray
            const ESPDeviceType* const deviceType = [[ESPDeviceType alloc]initWithSerial:serial TypeName:typeName IsLocalSupport:isLocalSupport TypeEnum:typeEnum];
            [tempArray addObject:deviceType];
        }
        DeviceTypeArray = [tempArray copy];
    });
    return DeviceTypeArray;
}

+ (BOOL) isTypeSupportedAlready:(ESPDeviceType *)deviceType
{
    if (deviceType==nil) {
        return NO;
    } else if (deviceType.espTypeEnum==NEW_ESP_DEVICETYPE) {
        return YES;
    } else if (deviceType.espTypeEnum==ROOT_ESP_DEVICETYPE) {
        return NO;
    } else if (deviceType.espTypeEnum==PLUG_ESP_DEVICETYPE) {
        return NO;
    } else if (deviceType.espTypeEnum==LIGHT_ESP_DEVICETYPE) {
        return YES;
    } else if (deviceType.espTypeEnum==HUMITURE_ESP_DEVICETYPE) {
        return NO;
    } else if (deviceType.espTypeEnum==FLAMMABLE_ESP_DEVICETYPE) {
        return NO;
    } else if (deviceType.espTypeEnum==VOLTAGE_ESP_DEVICETYPE) {
        return NO;
    } else if (deviceType.espTypeEnum==REMOTE_ESP_DEVICETYPE) {
        return NO;
    } else if (deviceType.espTypeEnum==PLUGS_ESP_DEVICETYPE) {
        return NO;
    } else if (deviceType.espTypeEnum==SOUNDBOX_ESP_DEVICETYPE) {
        return NO;
    }
    return NO;
}

- (instancetype)init
{
    abort();
}

- (instancetype)initWithSerial:(int) serial TypeName:(NSString *) typeName IsLocalSupport:(BOOL) isLocalSupport TypeEnum:(ESPDeviceTypeEnum) typeEnum;
{
    self = [super init];
    if (self) {
        _espSerial = serial;
        _typeName = typeName;
        _espIsLocalSupport = isLocalSupport;
        _typeEnum = typeEnum;
    }
    return self;
}

- (ESPDeviceTypeEnum)espTypeEnum
{
    return _typeEnum;
}

+ (ESPDeviceType *)resolveDeviceTypeBySerial:(int) serial
{
    int index = -1;
    // search index by serial
    NSArray *SerialArray = [ESPDeviceType SerialArray];
    for (int i = 0; i < [SerialArray count]; ++i) {
        NSNumber *number = [SerialArray objectAtIndex:i];
        if ([number intValue] == serial) {
            index = i;
            break;
        }
    }
    if (index != -1) {
        NSArray *DeviceTypeArray = [ESPDeviceType DeviceTypeArray];
        return [DeviceTypeArray objectAtIndex:index];
    } else {
        return nil;
    }
}

+ (ESPDeviceType *)resolveDeviceTypeByTypeName:(NSString *) typeName
{
    int index = -1;
    // search index by type name
    NSArray *TypeNameArray = [ESPDeviceType TypeNameArray];
    for (int i = 0; i < [TypeNameArray count]; ++i) {
        NSString *typeNameInArray = [TypeNameArray objectAtIndex:i];
        if ([typeNameInArray isEqualToString:typeName]) {
            index = i;
            break;
        }
    }
    if (index != -1) {
        NSArray *DeviceTypeArray = [ESPDeviceType DeviceTypeArray];
        return [DeviceTypeArray objectAtIndex:index];
    } else {
        return nil;
    }
}

- (BOOL)isEqual:(id)object
{
 
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[ESPDeviceType class]]) {
        return NO;
    }
    
    const ESPDeviceType *other = object;
    return _typeEnum == other.typeEnum;

    
}

- (id)copyWithZone:(NSZone *)zone
{
    ESPDeviceType *copy = [[self class]allocWithZone:zone];
    if (copy) {
        copy.espSerial = self.espSerial;
        copy.espIsLocalSupport = self.espIsLocalSupport;
        copy.typeEnum = self.typeEnum;
        copy.typeName = self.typeName;
    }
    return copy;
}

- (NSString *)description
{
    return _typeName;
}

@end
