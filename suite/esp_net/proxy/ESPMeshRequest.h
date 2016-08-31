//
//  ESPMeshRequest.h
//  MeshProxy
//
//  Created by 白 桦 on 4/21/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * class for Mesh request
 *
 * @author afunx
 *
 */
@interface ESPMeshRequest : NSObject

- (instancetype) initWithProto:(int)proto TargetBssid:(NSString *)targetBssid OriginRequestData:(NSData *)originRequestData;

- (instancetype) initWithProto:(int)proto TargetBssidArray:(NSArray *)targetBssidArray OriginRequestData:(NSData *)originRequestData;

- (NSData *) getRequestData;

@end
