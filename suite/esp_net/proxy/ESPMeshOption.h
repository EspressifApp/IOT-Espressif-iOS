//
//  ESPMeshOption.h
//  MeshProxy
//
//  Created by 白 桦 on 4/20/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * EspMeshOption is used for parse MESH OPTION in MESH HEADER
 *
 * @author afunx
 *
 */
@interface ESPMeshOption : NSObject

- (instancetype)initWithResponseData:(NSData *)responseData PackageLength:(int)packageLength OptionLength:(int)optionLength;

- (int)getDeviceAvailableCount;

@end
