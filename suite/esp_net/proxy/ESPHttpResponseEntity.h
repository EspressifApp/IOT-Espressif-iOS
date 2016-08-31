//
//  ESPHttpResponseEntity.h
//  suite
//
//  Created by 白 桦 on 6/29/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPHttpResponseEntity : NSObject

@property (readonly, nonatomic, assign) int status;
@property (readonly, nonatomic, assign) long long nonce;
@property (readonly, nonatomic, assign) BOOL isValid;
@property (readonly, nonatomic, strong) NSDictionary *json;

-(instancetype) initWithJson:(NSDictionary *)json;

@end
