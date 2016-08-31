
//
//  ESPMeshRequest.m
//  MeshProxy
//
//  Created by 白 桦 on 4/21/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshRequest.h"
#import "ESPMeshPackageUtil.h"

@interface ESPMeshRequest()

@property(nonatomic, assign) int proto;
@property(nonatomic, strong) NSString *targetBssid;
@property(nonatomic, strong) NSData *originRequestData;
@property(nonatomic, strong) NSArray *targetBssidArray;

@end

@implementation ESPMeshRequest

- (instancetype)init
{
    abort();
}

- (void) initIntervalWithProto:(int)proto TargetBssid:(NSString *)targetBssid TargetBssidArray:(NSArray *)targetBssidArray OriginRequestData:(NSData *)originRequestData
{
    _proto = proto;
    _targetBssid = targetBssid;
    _targetBssidArray = targetBssidArray;
    _originRequestData = originRequestData;
}

- (instancetype) initWithProto:(int)proto TargetBssid:(NSString *)targetBssid OriginRequestData:(NSData *)originRequestData
{
    self = [super init];
    if (self) {
        [self initIntervalWithProto:proto TargetBssid:targetBssid TargetBssidArray:nil OriginRequestData:originRequestData];
    }
    return self;

}

- (instancetype) initWithProto:(int)proto TargetBssidArray:(NSArray *)targetBssidArray OriginRequestData:(NSData *)originRequestData
{
    self = [super init];
    if (self) {
        [self initIntervalWithProto:proto TargetBssid:nil TargetBssidArray:targetBssidArray OriginRequestData:originRequestData];
    }
    return self;
}

- (NSData *) getRequestData
{
    if (_targetBssidArray == nil) {
        return [ESPMeshPackageUtil addMeshRequestPackageHeaderByProto:_proto TargetBssid:_targetBssid RequestData:_originRequestData];
    } else {
        return [ESPMeshPackageUtil addMeshGroupRequestPackageHeaderByProto:_proto GroupBssidArray:_targetBssidArray RequestData:_originRequestData];
    }
}

@end
