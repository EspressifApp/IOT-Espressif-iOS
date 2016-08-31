//
//  ESPHttpRequestEntity.h
//  suite
//
//  Created by 白 桦 on 6/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPHttpRequestEntity : NSObject

-(instancetype)initWithMethod:(NSString *)method UrlString:(NSString *)urlString Content:(NSString *)content;

-(instancetype)initWithMethod:(NSString *)method UrlString:(NSString *)urlString;

@property (nonatomic,strong) NSMutableDictionary *headers;
@property (nonatomic,strong) NSMutableDictionary *queries;

-(NSDictionary *)requestJson;

@end
