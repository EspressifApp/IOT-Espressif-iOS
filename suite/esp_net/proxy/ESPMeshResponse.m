//
//  ESPMeshResponse.m
//  MeshProxy
//
//  Created by 白 桦 on 4/21/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshResponse.h"
#import "ESPMeshPackageUtil.h"

@interface ESPMeshResponse()

@property (nonatomic, assign) int packageLength;
@property (nonatomic, assign) int optionLength;
@property (nonatomic, strong) NSString *targetBssid;
@property (nonatomic, assign) int proto;
@property (nonatomic, assign) BOOL isDeviceAvailable;
@property (nonatomic, strong) ESPMeshOption *meshOption;
@property (nonatomic, strong) NSData *responseData;

@end

@implementation ESPMeshResponse

-(instancetype) init
{
    abort();
}

-(instancetype) init:(NSData *)first4Data
{
    self = [super init];
    if (self) {
        _packageLength = [ESPMeshPackageUtil getResponsePackageLength:first4Data];
    }
    return self;
}
-(BOOL) fillInAll:(NSData *)responseData
{
    @try {
        _responseData = responseData;
        _isDeviceAvailable = [ESPMeshPackageUtil isDeviceAvailable:responseData];
        _optionLength = [ESPMeshPackageUtil getResponseOptionLength:responseData];
        if (_optionLength > 0) {
            _meshOption = [[ESPMeshOption alloc]initWithResponseData:_responseData PackageLength:_packageLength OptionLength:_optionLength];
        } else {
            _meshOption = nil;
        }
        _proto = [ESPMeshPackageUtil getResponseProto:responseData];
        _targetBssid = [ESPMeshPackageUtil getDeviceBssid:responseData];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"ESPMeshResponse fillInAll() exception: %@",exception);
        return NO;
    }
}

-(int) getPackageLength
{
    return _packageLength;
}

-(int) getOptionLength
{
    return _optionLength;
}

-(int) getProto
{
    return _proto;
}

-(NSString *) getTargetBssid
{
    return _targetBssid;
}

-(BOOL) hasMeshOption
{
    return _meshOption != nil;
}

-(ESPMeshOption *) getMeshOption
{
    return _meshOption;
}

-(BOOL) isBodyEmpty
{
    return _packageLength - _optionLength == M_HEADER_LEN;
}

-(BOOL) isDeviceAvailable
{
    return _isDeviceAvailable;
}

-(NSData *) getPureResponseData
{
    int pureResponseOffset = M_HEADER_LEN + _optionLength;
    int pureResponseCount = _packageLength - _optionLength - M_HEADER_LEN;
    return [_responseData subdataWithRange:NSMakeRange(pureResponseOffset, pureResponseCount)];
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"[ESPMeshResponse packageLength = %d | optionLength = %d | targetBssid = %@ | proto = %d | hasMeshOption = %@ | isBodyEmpty = %@ | isDeviceAvailable = %@]",_packageLength,_optionLength,_targetBssid,_proto,[self hasMeshOption] ? @"YES" : @"NO",[self isBodyEmpty] ? @"YES" : @"NO",_isDeviceAvailable ? @"YES" : @"NO"];
}

@end
