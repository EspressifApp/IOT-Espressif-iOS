

//
//  ESPMeshOption.m
//  MeshProxy
//
//  Created by 白 桦 on 4/20/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshOption.h"
#import "ESPIllegalStateException.h"
#import "ESPMeshPackageUtil.h"

#define M_OPTION_TYPE_SIZE          1
#define M_OPTION_LENGTH_SIZE        1
// M_OPTION_TYPE_LENGTH_SIZE = M_OPTION_TYPE_SIZE + M_OPTION_LENGTH_SIZE
#define M_OPTION_TYPE_LENGTH_SIZE   2

enum MESH_OPTION_TYPE
{
    M_O_CONGEST_REQ,    // congest request option
    M_O_CONGEST_RESP,   // congest response option
    M_O_ROUTER_SPREAD,  // router information spread option
    M_O_ROUTE_ADD,      // route table update (node joins mesh) option
    M_O_ROUTE_DEL,      // route table update (node leaves mesh) option
    M_O_TOPO_REQ,       // topology request option
    M_O_TOPO_RESP,      // topology response option
    M_O_MCAST_GRP,      // group list of mcast
    M_O_MESH_FRAG,      // mesh management fragment option
    M_O_USR_FRAG,       // user data fragment
    M_O_USR_OPTION,     // user option
};

typedef enum MESH_OPTION_TYPE MESH_OPTION_TYPE;

@interface ESPMeshOption()

@property(nonatomic, assign) int deviceAvailableCount;

@end

@implementation ESPMeshOption

- (instancetype)init
{
    abort();
}

- (instancetype)initWithResponseData:(NSData *)responseData PackageLength:(int)packageLength OptionLength:(int)optionLength
{
    self = [super init];
    if (self) {
        @try {
            [self initInternalWithResponseData:responseData PackageLength:packageLength OptionLength:optionLength];
        }
        @catch (NSException *exception) {
            NSLog(@"%@ '%@' %@",[self class],NSStringFromSelector(_cmd),exception);
            self = nil;
        }
    }
    return self;
}

- (void)initInternalWithResponseData:(NSData *)responseData PackageLength:(int)packageLength OptionLength:(int)optionLength
{
    if (optionLength <= 0) {
        NSString *exceptionName = @"ESPMeshOption-initInternalWithResponseData";
        NSString *exceptionReason = [NSString stringWithFormat:@"option length <= 0, optionLenght = %d",optionLength];
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
        @throw e;
    }
    if (packageLength <= optionLength) {
        NSString *exceptionName = @"ESPMeshOption-initInternalWithResponseData";
        NSString *exceptionReason = [NSString stringWithFormat: @"packageLength <= optionLength, packageLength = %d, optionLength = %d",packageLength,optionLength];
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
        @throw e;
    }
    [self parse:responseData PackageLength:packageLength OptionLength:optionLength];
}

- (int)parseTLV:(NSData *)responseData Offset:(int)offset Count:(int)count
{
    int value = 0;
    Byte responseBytes[count];
    [responseData getBytes:responseBytes range:NSMakeRange(offset, count)];
    for (int index = count - 1; index >= 0; --index) {
        value <<= 0x08;
        value += responseBytes[index];
    }
    return value;
}

- (MESH_OPTION_TYPE) parseType:(NSData *)responseData Offset:(int)typeOffset Count:(int)typeCount
{
    int typeValue = [self parseTLV:responseData Offset:typeOffset Count:typeCount];
    return typeValue;
}

- (int)parseLength:(NSData *)responseData Offset:(int)lengthOffset Count:(int)lengthCount
{
    return [self parseTLV:responseData Offset:lengthOffset Count:lengthCount];
}

- (int)parseValue:(NSData *)responseData Offset:(int)valueOffset Count:(int)valueCount
{
    return [self parseTLV:responseData Offset:valueOffset Count:valueCount];
}

- (void)parse:(NSData *)responseData PackageLength:(int)packageLength OptionLength:(int)optionLength
{
    int bodyLength = packageLength - M_HEADER_LEN - optionLength;
    int offset = M_HEADER_LEN + bodyLength + M_OPTION_LEN;
    // parse TLV
    while (offset < packageLength)
    {
        MESH_OPTION_TYPE type = [self parseType:responseData Offset:offset Count:M_OPTION_TYPE_SIZE];
        offset += M_OPTION_TYPE_SIZE;
        // reduce 2 bytes for type and length
        int length = [self parseLength:responseData Offset:offset Count:M_OPTION_LENGTH_SIZE] - M_OPTION_TYPE_LENGTH_SIZE;
        offset += M_OPTION_LENGTH_SIZE;
        NSString *exceptionName;
        NSString *exceptionReason;
        NSException *e;
        switch (type)
        {
            case M_O_CONGEST_REQ:
                exceptionName = @"ESPMeshOption-responseData";
                exceptionReason = [NSString stringWithFormat: @"M_O_CONGEST_REQ shouldn't be sent to mobile"];
                e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                @throw e;
            case M_O_CONGEST_RESP:
                if (length != 0x02)
                {
                    exceptionName = @"ESPMeshOption-responseData";
                    exceptionReason = [NSString stringWithFormat: @"M_O_CONGEST_RESP length != 2, length = %d",length];
                    e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                    @throw e;
                }
                _deviceAvailableCount = [self parseValue:responseData Offset:offset Count:length];
                offset += length;
                break;
            case M_O_MCAST_GRP:
                exceptionName = @"ESPMeshOption-responseData";
                exceptionReason = [NSString stringWithFormat: @"M_O_MCAST_GRP shouldn't be sent to mobile"];
                e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                @throw e;
            case M_O_MESH_FRAG:
                exceptionName = @"ESPMeshOption-responseData";
                exceptionReason = [NSString stringWithFormat: @"M_O_MESH_FRAG shouldn't be sent to mobile"];
                e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                @throw e;
            case M_O_ROUTER_SPREAD:
                exceptionName = @"ESPMeshOption-responseData";
                exceptionReason = [NSString stringWithFormat: @"M_O_ROUTER_SPREAD shouldn't be sent to mobile"];
                e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                @throw e;
            case M_O_ROUTE_ADD:
                exceptionName = @"ESPMeshOption-responseData";
                exceptionReason = [NSString stringWithFormat: @"M_O_ROUTE_ADD shouldn't be sent to mobile"];
                e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                @throw e;
            case M_O_ROUTE_DEL:
                exceptionName = @"ESPMeshOption-responseData";
                exceptionReason = [NSString stringWithFormat: @"M_O_ROUTE_DEL shouldn't be sent to mobile"];
                e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                @throw e;
            case M_O_TOPO_REQ:
                exceptionName = @"ESPMeshOption-responseData";
                exceptionReason = [NSString stringWithFormat: @"M_O_TOPO_REQ shouldn't be sent to mobile"];
                e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                @throw e;
            case M_O_TOPO_RESP:
                exceptionName = @"ESPMeshOption-responseData";
                exceptionReason = [NSString stringWithFormat: @"M_O_TOPO_RESP shouldn't be sent to mobile"];
                e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                @throw e;
            case M_O_USR_FRAG:
                exceptionName = @"ESPMeshOption-responseData";
                exceptionReason = [NSString stringWithFormat: @"M_O_USR_FRAG shouldn't be sent to mobile"];
                e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                @throw e;
            case M_O_USR_OPTION:
                exceptionName = @"ESPMeshOption-responseData";
                exceptionReason = [NSString stringWithFormat: @"M_O_USR_OPTION shouldn't be sent to mobile"];
                e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
                @throw e;
        }
    }
}
- (int)getDeviceAvailableCount
{
    return _deviceAvailableCount;
}

@end
