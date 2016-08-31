//
//  ESPHttpRequestEntity.m
//  suite
//
//  Created by 白 桦 on 6/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPHttpRequestEntity.h"


#define PATH                    @"path"
#define METHOD                  @"method"
#define META                    @"meta"
#define GET                     @"get"
#define POST                    @"post"
#define URL_QUERY_DELIMITER     @"&"
#define EQUAL                   @"="
#define ESCAPE                  @"\r\n"

@interface ESPHttpRequestEntity()

@property (nonatomic,strong) NSString *method;
@property (nonatomic,strong) NSString *path;
@property (nonatomic,strong) NSString *host;
@property (nonatomic,strong) NSString *scheme;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *relativeUrl;

@end

@implementation ESPHttpRequestEntity

- (instancetype)init
{
    abort();
}

- (instancetype)initWithMethod:(NSString *)method UrlString:(NSString *)urlString
{
    return [self initWithMethod:method UrlString:urlString Content:nil];
}

- (instancetype)initWithMethod:(NSString *)method UrlString:(NSString *)urlString Content:(NSString *)content
{
    self = [super init];
    if (self) {
        self.method = method;
        self.content = content;
        // parse URL
        NSURL *url = [NSURL URLWithString:urlString];
        self.scheme = url.scheme;
        self.relativeUrl = (url.query!=nil) ? ([NSString stringWithFormat:@"%@?%@",url.path,url.query]) : (url.path);
        self.path = url.path;
        self.host = url.host;
        self.headers = [[NSMutableDictionary alloc]init];
        self.queries = [[NSMutableDictionary alloc]init];
        [self parseQuery:url.query];
    }
    return self;
}

- (void) parseQuery:(NSString *)query
{
    if (query!=nil) {
        NSArray *query1Array = [query componentsSeparatedByString:URL_QUERY_DELIMITER];
        for (NSString *query1 in query1Array) {
            NSArray *query2Array = [query1 componentsSeparatedByString:EQUAL];
            if ([query2Array count] != 2) {
                NSLog(@"ERROR %@ %@ bad url argument",[self class],NSStringFromSelector(_cmd));
                abort();
            }
            NSString *key = [query2Array objectAtIndex:0];
            NSString *value = [query2Array objectAtIndex:1];
            [self.queries setObject:value forKey:key];
        }
    }
}

- (NSString *)description
{
    NSDictionary *requestJson = [self requestJson];
    NSData* parametersData = [NSJSONSerialization dataWithJSONObject:requestJson options:kNilOptions error:nil];
    NSString *requestStr = [[NSString alloc]initWithData:parametersData encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@%@",requestStr ,ESCAPE];
}

-(NSDictionary *)requestJson
{
    NSMutableDictionary *jsonResult = [[NSMutableDictionary alloc]init];
    [jsonResult setObject:self.path forKey:PATH];
    [jsonResult setObject:self.method forKey:METHOD];
    if ([self.headers count]!=0) {
        NSMutableDictionary *metaJson = [[NSMutableDictionary alloc]init];
        for (NSString *headerKey in self.headers.keyEnumerator) {
            NSString *key = headerKey;
            NSString *value = [self.headers objectForKey:headerKey];
            [metaJson setObject:value forKey:key];
        }
        [jsonResult setObject:metaJson forKey:META];
    }

    if ([self.queries count]!=0) {
        NSMutableDictionary *queryJson = [[NSMutableDictionary alloc]init];
        for (NSString *headerKey in self.queries.keyEnumerator) {
            NSString *key = headerKey;
            NSString *value = [self.queries objectForKey:headerKey];
            [queryJson setObject:value forKey:key];
        }
        [jsonResult setObject:queryJson forKey:GET];
    }
    if (self.content!=nil&&[self.content length]>0) {
        [jsonResult setObject:self.content forKey:POST];
    }

    return jsonResult;
}

@end
