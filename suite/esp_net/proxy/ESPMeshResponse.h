//
//  ESPMeshResponse.h
//  MeshProxy
//
//  Created by 白 桦 on 4/21/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPMeshOption.h"

@interface ESPMeshResponse : NSObject

-(instancetype) init:(NSData *)first4Data;

/**
 * fill in all response data to ESPMeshResponse
 *
 * @return whether the response is parsed valid
 */
-(BOOL) fillInAll:(NSData *)responseData;

-(int) getPackageLength;

-(int) getOptionLength;

-(int) getProto;

-(NSString *) getTargetBssid;

-(BOOL) hasMeshOption;

-(ESPMeshOption *) getMeshOption;

-(BOOL) isBodyEmpty;

-(BOOL) isDeviceAvailable;

-(NSData *) getPureResponseData;

@end
