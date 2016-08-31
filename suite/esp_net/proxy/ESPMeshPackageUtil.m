//
//  ESPMeshPackageUtil.m
//  MeshProxy
//
//  Created by 白 桦 on 4/20/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshPackageUtil.h"

#import "ESPIllegalStateException.h"
#import "ESPMeshLog.h"

#define DEBUG_ON                NO
#define M_OPTION_HEADER_LEN     2
#define M_O_MCAST_GRP           7
#define VER                     0
#define MULTIPLE_CAST_BSSID     @"01:00:5e:00:00:00"
#define MAC_ADDR_LEN            6

@implementation ESPMeshPackageUtil

// get first byte of Mesh Package Header
+ (Byte) get1Byte:(int) ver OptionExist:(BOOL) optionExist
{
    // version has 2 bits
    int result = ver & 0x03;
    if (optionExist)
    {
        // optionExist is 3 bit
        result = result | 0x04;
    }
    // flags are fixed at present
    int flags = 0x02 << 0x03;
    result |= flags;
    return result;
}

+ (Byte) get2Byte:(int) protocol
{
    return protocol << 0x02;
}

+ (NSData *) getLengthData:(int) packageLength
{
    if (packageLength > 65535) {
        NSString *exceptionName = @"ESPMeshPackageUtil-getLengthData";
        NSString *exceptionReason = @"packageLength is too large";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
        @throw e;
    }
    Byte lByte = packageLength & 0x00ff;
    Byte hByte = (packageLength & 0xff00) >> 0x08;
    Byte bytes[] = {lByte, hByte};
    return [NSData dataWithBytes:bytes length:2];
}

+ (NSData *) getDestAddrData:(NSString *)targetBssid
{
    Byte results[MAC_ADDR_LEN];
    NSArray *bssidArray = [targetBssid componentsSeparatedByString:@":"];
    if ([bssidArray count] != MAC_ADDR_LEN) {
        NSString *exceptionName = @"ESPMeshPackageUtil-getDestAddrData";
        NSString *exceptionReason = [NSString stringWithFormat:@"invalid targetBssid: %@", targetBssid];
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
        @throw e;
    }
    for (int i = 0; i < [bssidArray count]; ++i) {
        NSString *hexStr = [bssidArray objectAtIndex:i];
        Byte byte = strtoul([hexStr cStringUsingEncoding:NSUTF8StringEncoding], NULL, 16);
        results[i] = byte;
    }
    return [NSData dataWithBytes:results length:MAC_ADDR_LEN];
}

+ (NSData *) getSrcAddrData
{
    Byte srcBytes[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    return [NSData dataWithBytes:srcBytes length:MAC_ADDR_LEN];
}

+ (NSData *) getOptionLengthData:(int) optionLength
{
    return [self getLengthData:optionLength];
}

+ (NSData *) getOptionData:(NSArray *) targetBssidArray
{
    int targetBssidArrayCount = (int)[targetBssidArray count];
    int optionSizeEach = MAC_ADDR_LEN + M_OPTION_HEADER_LEN;
    int optionCount = targetBssidArrayCount * optionSizeEach;
    Byte optionBytes[optionCount];
    int optionBytesOffset = 0;

    for (int bssidIndex = 0; bssidIndex < targetBssidArrayCount; ++bssidIndex) {
        optionBytes[optionBytesOffset++] = M_O_MCAST_GRP;
        optionBytes[optionBytesOffset++] = optionSizeEach;
        NSString *targetBssid = [targetBssidArray objectAtIndex:bssidIndex];
        NSData *bssidData = [self getDestAddrData:targetBssid];
        Byte bssidBytes[MAC_ADDR_LEN];
        [bssidData getBytes:bssidBytes];
        for (int offset = 0; offset < MAC_ADDR_LEN; ++offset)
        {
            optionBytes[offset + optionBytesOffset] = bssidBytes[offset];
        }
        optionBytesOffset += MAC_ADDR_LEN;
    }
    return [NSData dataWithBytes:optionBytes length:optionCount];
}

+ (int) getMeshRequestOptionLength:(NSArray *) groupBssiArray
{
    return (M_OPTION_LEN + (M_OPTION_HEADER_LEN + MAC_ADDR_LEN) * (int)[groupBssiArray count]);
}

+ (NSData*) __addMeshRequestPackageHeaderByProto:(int)proto TargetBssid:(NSString *)targetBssid RequestData:(NSData *)requestData GroupBssidArray:(NSArray *)groupBssidArray
{
    int optionLength = 0;
    // update optionLength if necessary
    if (groupBssidArray != nil) {
        // check whether [groupBssidArray count] is zero
        if ([groupBssidArray count] == 0) {
            NSString *exceptionName = @"ESPMeshPackageUtil-__addMeshRequestPackageHeaderByProto";
            NSString *exceptionReason = [NSString stringWithFormat:@"groupBssidList count should > 0"];
            NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
            @throw e;

        }
        // don't forget to add M_OPTION_LEN
        optionLength = [self getMeshRequestOptionLength:groupBssidArray];
    }
    // packageLength = M_HEADER_LEN + [requestData length] + optionLength
    int packageLength = M_HEADER_LEN + (int)[requestData length] + optionLength;
    // build new request data
    NSMutableData *newRequestMutableData = [[NSMutableData alloc]initWithCapacity:packageLength];
    // build package before optionList
    int ver = VER;
    BOOL optionExist = optionLength != 0;
    // build first two data
    Byte byte1 = [self get1Byte:ver OptionExist:optionExist];
    Byte byte2 = [self get2Byte:proto];
    Byte byte12s[] = {byte1,byte2};
    [newRequestMutableData appendBytes:byte12s length:2];
    // build length data
    NSData *lengthData = [self getLengthData:packageLength];
    [newRequestMutableData appendData:lengthData];
    // build dest addr data
    NSData *destAddrData = [self getDestAddrData:targetBssid];
    [newRequestMutableData appendData:destAddrData];
    // build src addr data
    NSData *srcAddrData = [self getSrcAddrData];
    [newRequestMutableData appendData:srcAddrData];
    // build package of optionList if necessary
    if (optionLength != 0) {
        NSData *optionLengthData = [self getOptionLengthData:optionLength];
        [newRequestMutableData appendData:optionLengthData];
        NSData *optionData = [self getOptionData:groupBssidArray];
        [newRequestMutableData appendData:optionData];
    }
    // build package content
    [newRequestMutableData appendData:requestData];
    return [newRequestMutableData copy];
}

+ (NSData *) addMeshRequestPackageHeaderByProto:(int)proto TargetBssid:(NSString *)targetBssid RequestData:(NSData *)requestData
{
    NSData *newRequestData = [self __addMeshRequestPackageHeaderByProto:proto TargetBssid:targetBssid RequestData:requestData GroupBssidArray:nil];
//    NSString *message = [NSString stringWithFormat:@" addMeshRequestPackageHeader() proto:%d, targetBssid:%@, newRequestData:%@",proto,targetBssid,newRequestData];
//    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:message];
    return newRequestData;
}

+ (NSData *) addMeshGroupRequestPackageHeaderByProto:(int)proto GroupBssidArray:(NSArray *)groupBssidArray RequestData:(NSData *)requestData
{
    NSData *newRequestData = [self __addMeshRequestPackageHeaderByProto:proto TargetBssid:MULTIPLE_CAST_BSSID RequestData:requestData GroupBssidArray:groupBssidArray];
    NSString *message = [NSString stringWithFormat:@" addMeshGroupRequestPackageHeaderByProto() proto:%d, groupBssiArray:%@, newRequestData:%@",proto,groupBssidArray,newRequestData];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:message];
    return newRequestData;
}

+ (int) getResponseProto:(NSData *)responseData
{
    Byte byte1[1];
    [responseData getBytes:byte1 range:NSMakeRange(0x01, 1)];
    return byte1[0] >> 0x02;
}

+ (int) getResponsePackageLength:(NSData *)responseData
{
    Byte byte2[1];
    [responseData getBytes:byte2 range:NSMakeRange(0x02, 1)];
    Byte byte3[1];
    [responseData getBytes:byte3 range:NSMakeRange(0x03, 1)];
    return byte2[0] | (byte3[0] << 0x08);
}

+ (int) getResponseOptionLength:(NSData *)responseData
{
    Byte byte0[1];
    [responseData getBytes:byte0 range:NSMakeRange(0x00, 1)];
    if ((byte0[0] & 0x04) == 0) {
        return 0;
    } else {
        Byte byte10[1];
        [responseData getBytes:byte10 range:NSMakeRange(0x10, 1)];
        Byte byte11[1];
        [responseData getBytes:byte11 range:NSMakeRange(0x11, 1)];
        return byte10[0] | byte11[0] << 0x08;
    }
}

+ (NSData *) getPureResposneData:(NSData *)responseData
{
    int packageLength = [self getResponsePackageLength:responseData];
    int optionLength = [self getResponseOptionLength:responseData];
    int pureResponseOffset = M_HEADER_LEN + optionLength;
    int pureResponseCount = packageLength - optionLength - M_HEADER_LEN;
    return [responseData subdataWithRange:NSMakeRange(pureResponseOffset, pureResponseCount)];
}

+ (BOOL) isDeviceAvailable:(NSData *)responseData
{
    Byte byte0[1];
    [responseData getBytes:byte0 range:NSMakeRange(0, 1)];
    return (byte0[0] & 0x08) !=0;
}

+ (NSString *) getDeviceBssid:(NSData *)responseData
{
    int deviceBssidOffset = 0x0a;
    int deviceBssidCount = MAC_ADDR_LEN;
    NSMutableString *ms = [[NSMutableString alloc]init];
    Byte hexValue[1];
    for (int i = 0; i < deviceBssidCount; ++i) {
        if (i != 0) {
            [ms appendString:@":"];
        }
        [responseData getBytes:hexValue range:NSMakeRange(deviceBssidOffset + i, 1)];
        [ms appendFormat:@"%02x",hexValue[0]];
    }
    return [ms copy];
}

+ (BOOL) isBodyEmptyByPackageLength:(int)packageLength OptionLength:(int)optionLength
{
    return packageLength - optionLength == M_HEADER_LEN;
}

+ (void) main
{
    int ver = 0x01;
    BOOL optionExist = YES;
    Byte b1 = [self get1Byte:ver OptionExist:optionExist];
    if (b1 == 21) {
        NSLog(@"get1Byte() pass");
    }
    // M_PROTO_HTTP is 1
    int proto = 1;
    Byte b2 = [self get2Byte:proto];
    if (b2 == 4) {
        NSLog(@"get2Byte() pass");
    }
    int packageLength = 0x10;
    NSData *packageLengthData = [self getLengthData:packageLength];
    Byte byte0[1];
    Byte byte1[1];
    Byte byte2[1];
    Byte byte3[1];
    Byte byte4[1];
    Byte byte5[1];
    Byte byte6[1];
    Byte byte7[1];
    Byte byte8[1];
    Byte byte9[1];
    Byte byteA[1];
    Byte byteB[1];
    Byte byteC[1];
    Byte byteD[1];
    Byte byteE[1];
    Byte byteF[1];
    [packageLengthData getBytes:byte0 range:NSMakeRange(0, 1)];
    [packageLengthData getBytes:byte1 range:NSMakeRange(1, 1)];
    if (byte0[0] == 0x10 && byte1[0] == 0x00) {
        NSLog(@"getLengthData() pass");
    } else {
        NSLog(@"getLengthData() fail");
    }
    NSString *targetBssid = @"18:fe:34:ab:cd:ef";
    NSData *destAddrData = [self getDestAddrData:targetBssid];
    [destAddrData getBytes:byte0 range:NSMakeRange(0, 1)];
    [destAddrData getBytes:byte1 range:NSMakeRange(1, 1)];
    [destAddrData getBytes:byte2 range:NSMakeRange(2, 1)];
    [destAddrData getBytes:byte3 range:NSMakeRange(3, 1)];
    [destAddrData getBytes:byte4 range:NSMakeRange(4, 1)];
    [destAddrData getBytes:byte5 range:NSMakeRange(5, 1)];
    if (byte0[0]==0x18&&byte1[0]==0xfe&&byte2[0]==0x34&&byte3[0]==0xab&&byte4[0]==0xcd&&byte5[0]==0xef) {
        NSLog(@"getDestAddrData() pass");
    } else {
        NSLog(@"getDestAddrData() fail");
    }
    
    NSArray *targetBssidArray = [[NSArray alloc]initWithObjects:@"18:fe:34:ab:cd:ef",@"81:ef:43:ba:dc:fe", nil];
    NSData *targetBssidArrayData = [self getOptionData:targetBssidArray];
    [targetBssidArrayData getBytes:byte0 range:NSMakeRange(0, 1)];
    [targetBssidArrayData getBytes:byte1 range:NSMakeRange(1, 1)];
    [targetBssidArrayData getBytes:byte2 range:NSMakeRange(2, 1)];
    [targetBssidArrayData getBytes:byte3 range:NSMakeRange(3, 1)];
    [targetBssidArrayData getBytes:byte4 range:NSMakeRange(4, 1)];
    [targetBssidArrayData getBytes:byte5 range:NSMakeRange(5, 1)];
    [targetBssidArrayData getBytes:byte6 range:NSMakeRange(6, 1)];
    [targetBssidArrayData getBytes:byte7 range:NSMakeRange(7, 1)];
    [targetBssidArrayData getBytes:byte8 range:NSMakeRange(8, 1)];
    [targetBssidArrayData getBytes:byte9 range:NSMakeRange(9, 1)];
    [targetBssidArrayData getBytes:byteA range:NSMakeRange(10, 1)];
    [targetBssidArrayData getBytes:byteB range:NSMakeRange(11, 1)];
    [targetBssidArrayData getBytes:byteC range:NSMakeRange(12, 1)];
    [targetBssidArrayData getBytes:byteD range:NSMakeRange(13, 1)];
    [targetBssidArrayData getBytes:byteE range:NSMakeRange(14, 1)];
    [targetBssidArrayData getBytes:byteF range:NSMakeRange(15, 1)];
    
    if (byte0[0]==0x07&&byte1[0]==0x08
        &&byte2[0]==0x18&&byte3[0]==0xfe&&byte4[0]==0x34&&byte5[0]==0xab&&byte6[0]==0xcd&&byte7[0]==0xef
        &&byte8[0]==0x07&&byte9[0]==0x08
        &&byteA[0]==0x81&&byteB[0]==0xef&&byteC[0]==0x43&&byteD[0]==0xba&&byteE[0]==0xdc&&byteF[0]==0xfe) {
        NSLog(@"getOptionData() pass");
    } else {
        NSLog(@"getOptionData() fail");
    }
    
    Byte responsePackageLengthBytes[] = {0x00, 0x00, 0x10, 0x20};
    NSData *responsePackageLengthData = [NSData dataWithBytes:responsePackageLengthBytes length:4];
    packageLength = [self getResponsePackageLength:responsePackageLengthData];
    if (packageLength == (0x20 << 8) + 0x10) {
        NSLog(@"getResponsePackageLength() pass");
    } else {
        NSLog(@"getResponsePackageLength() fail");
    }
    
    Byte responseOptionLengthBytes[] = {0x04, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
        0x10, 0x11};
    NSData *responseOptionLengthData = [NSData dataWithBytes:responseOptionLengthBytes length:18];
    int optionLength = [self getResponseOptionLength:responseOptionLengthData];
    if (optionLength == (0x11 << 8) + 0x10) {
        NSLog(@"getResponseOptionLength() pass");
    } else {
        NSLog(@"getResponseOptionLength() fail");
    }
    
    Byte responseDeviceAvailableBytes[] = {0x08};
    NSData *responseDeviceAvailableData = [NSData dataWithBytes:responseDeviceAvailableBytes length:1];
    BOOL isDeviceAvailable = [self isDeviceAvailable:responseDeviceAvailableData];
    if (isDeviceAvailable) {
        NSLog(@"isDeviceAvailable() pass");
    } else {
        NSLog(@"isDeviceAvailable() fail");
    }
    
    Byte responseDeviceBssidBytes[] ={0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x18, 0xfe, 0x34, 0xab,
        0xcd, 0xef};
    NSData *responseDeviceBssidData = [NSData dataWithBytes:responseDeviceBssidBytes length:16];
    NSString *deviceBssid = [self getDeviceBssid:responseDeviceBssidData];
    if ([deviceBssid isEqualToString:@"18:fe:34:ab:cd:ef"]) {
        NSLog(@"getDeviceBssid() pass");
    } else {
        NSLog(@"getDeviceBssid() fail");
    }
}
@end
