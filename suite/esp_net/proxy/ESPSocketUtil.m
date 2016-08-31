//
//  ESPSocketUtil.m
//  MeshProxy
//
//  Created by 白 桦 on 4/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPSocketUtil.h"
#import "ESPSocketIOException.h"
#import "ESPMeshLog.h"
#import "ESPLineReader.h"

#define LF      @"\r"
#define CR      @"\n"

#define DEBUG_ON    NO

@implementation ESPSocketUtil

+ (NSData *) readOneData: (ESPSocketClient2*) socketClient
{
    NSData *oneData = [socketClient readData:1];
    if (oneData == nil) {
        NSException *e = [ESPSocketIOException exceptionWithName:@"ESPSocketUtil-readOneData" reason:@"fail to read one data" userInfo:nil];
        @throw e;
    }
    return oneData;
}

/**
 * read http header from socket into buffer
 *
 * @param socketClient the socket client to be read
 * @param buffer the buffer to store Http Header
 * @param byteOffset the byte of offset
 * @return the count of header or -1 when exception occurs
 * @throws ESPSocketIOException the IOException
 */
+ (int) readHttpHeader: (ESPSocketClient2*) socketClient IntoBuffer: (NSMutableData *) buffer Offset: (int) byteOffset
{
    int count = 0;
    NSData *last = nil;
    NSString *lastStr = nil;
    NSData *current = nil;
    NSString *currentStr = nil;
    BOOL isEscapeOnce = NO;
    BOOL isEscapeTwiceTry = NO;
    NSRange range = NSMakeRange(byteOffset + count++, 1);
    last = [self readOneData:socketClient];
    [buffer replaceBytesInRange:range withBytes:[last bytes]];
    while (YES)
    {
        // read one byte into buffer
        current = [self readOneData:socketClient];
        range = NSMakeRange(byteOffset + count++, 1);
        [buffer replaceBytesInRange:range withBytes:[current bytes]];
        lastStr = [[NSString alloc] initWithData:last encoding:NSUTF8StringEncoding];
        currentStr = [[NSString alloc] initWithData:current encoding:NSUTF8StringEncoding];
        if (!isEscapeTwiceTry && [lastStr isEqualToString:LF] && [currentStr isEqualToString:CR]) {
            isEscapeOnce = YES;
        } else if (isEscapeOnce) {
            isEscapeOnce = NO;
            isEscapeTwiceTry = YES;
        } else if (isEscapeTwiceTry) {
            if ([lastStr isEqualToString:LF] && [currentStr isEqualToString:CR]) {
                break;
            }
            isEscapeTwiceTry = NO;
        }
        last = current;
    }
    return count;
}


// split NSString by regex ":( )+"
+ (NSArray *) split1: (NSString *)str
{
    NSArray *array1 = [str componentsSeparatedByString:@":"];
    NSUInteger count1 = [array1 count];
    if (count1 < 2) {
        return array1;
    }
    NSString *key = [array1 objectAtIndex:0];
    NSMutableString *valueOrigin = [[NSMutableString alloc]init];
    for (int i = 1; i < count1; ++i) {
        [valueOrigin appendString:[array1 objectAtIndex:i]];
        if (i!=count1-1) {
            [valueOrigin appendString:@":"];
        }
    }
    NSMutableString *valueDest = [[NSMutableString alloc]init];
    BOOL isSpaceContinue;
    // from which index valueOrigin is not space at first time
    NSUInteger index = -1;
    NSString *oneStr;
    NSRange range;
    for (int i = 0; i < [valueOrigin length]; ++i) {
        range = NSMakeRange(i, 1);
        oneStr = [valueOrigin substringWithRange:range];
        isSpaceContinue = [oneStr isEqualToString:@" "];
        if (!isSpaceContinue) {
            index = i;
            break;
        }
    }
    if (index != -1) {
        [valueDest appendString:[valueOrigin substringFromIndex:index]];
    }
    NSArray *array2 = [NSArray arrayWithObjects:key, [valueDest copy], nil];
    return array2;
}

/**
 * find Http Header Value by its Header Key
 *
 * @param buffer the buffer stored HttpHeader
 * @param byteOffset the byte of HttpHeader
 * @param byteCount the count of HttpHeader
 * @param headerKey the Key of Header
 * @return the Value of Header or nil when can't find
 */
+ (NSString *) findHttpHeader: (NSData *) buffer Offset: (int) byteOffset Count: (int) byteCount HeaderKey: (NSString *)headerKey
{
    NSString *headerValue = nil;
    NSString *line = nil;
    ESPLineReader *reader = [[ESPLineReader alloc]initWithData:buffer];
    line = [reader readLine];
    if (line==nil) {
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:@"findHttpHeader() line is nil firstly"];
    }
    
    // find the head value and read next line
    while (line != nil) {
        NSArray *kv = [self split1:line];
        if ([kv count] == 2  && [headerKey isEqualToString:[kv objectAtIndex:0]]) {
            headerValue = [kv objectAtIndex:1];
            break;
        }
        else {
            line = [reader readLine];
            if (line==nil) {
//                NSString *msg = [NSString stringWithFormat:@"findHttpHeader() line is nil, headerKey is %@", headerKey];
//                [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
                break;
            }
        }
    }
    return headerValue;
}

/**
 * remove unnecessary Http Header
 *
 * @param buffer the buffer stored HttpHeader
 * @param headerLength the header length
 * @param contentLength the content length
 * @param httpHeaderList the http header list to be removed
 * @param newHeaderLength to store new header length
 * @return the new buffer
 */
+ (NSData *) removeUnnecessaryHttpHeader: (NSData *) buffer HeaderLength:(int) headerLength ContentLength:(int) contentLength HttpHeaderArray: (NSArray *) httpHeaderArray NewHeaderLength: (NSInteger *) newHeaderLength
{
    int bufferOffset = 0;
    int bufferSize = headerLength + contentLength;
    NSMutableData *newBuffer = [[NSMutableData alloc]initWithLength:bufferSize];
    int newByteOffset = 0;
    ESPLineReader *reader = [[ESPLineReader alloc]initWithData:buffer];
    NSString *line = nil;
    // read first line
    line = [reader readLine];
    if (line==nil) {
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:@"removeUnnecessaryHttpHeader() line is nil firstly"];
    }
    BOOL isRemoved;
    // occupy header
    while (line!=nil && bufferOffset < headerLength)
    {
        isRemoved = NO;
        // check header whether it is to be removed
        NSArray *kv = [self split1:line];
        if ([kv count] == 2) {
            for (NSString *httpHeader in httpHeaderArray) {
                if ([httpHeader isEqualToString:kv[0]]) {
                    isRemoved = YES;
                    break;
                }
            }
        }
        
        // don't forget to add \r\n
        line = [NSString stringWithFormat:@"%@%@%@",line,LF,CR];
        if (!isRemoved && line!=nil) {
            NSData *lineData = [line dataUsingEncoding:NSUTF8StringEncoding];
            Byte *srcBytes = (Byte *)[lineData bytes];
            NSUInteger dstPos = newByteOffset;
            NSUInteger length = [lineData length];
            NSRange destRange = NSMakeRange(dstPos, length);
            [newBuffer replaceBytesInRange:destRange withBytes:srcBytes length:length];
            newByteOffset += length;
            bufferOffset += length;
        } else {
            bufferOffset += [line length];
        }
        
        line = [reader readLine];
        if (line==nil) {
            [ESPMeshLog error:DEBUG_ON Class:[self class] Message:@"removeUnnecessaryHttpHeader() line is nil"];
        }
    }
    
    // update newHeaderLength
    (*newHeaderLength) = newByteOffset;
    
    // occupy body if necessary
    if (contentLength > 0) {
        Byte *src = (Byte *)[buffer bytes];
        int srcPos = bufferOffset;
        int dstPost = newByteOffset;
        int length = contentLength;
        NSRange destRange = NSMakeRange(dstPost, length);
        [newBuffer replaceBytesInRange:destRange withBytes:src + srcPos];
    }
    
    return newBuffer;
}

/**
 * read some data from the socket into the buffer
 *
 * @param socketClient the socket client to be read
 * @param buffer the buffer
 * @param bufferOffset the offset of buffer
 * @param bufferCount the count byte to be read
 */
+ (void) readData: (ESPSocketClient2*) socketClient IntoBuffer: (NSMutableData *)buffer Offset: (int) bufferOffset Count: (int) bufferCount
{
    NSData* data = [socketClient readData:bufferCount];
    if (data==nil) {
        NSException *e = [ESPSocketIOException exceptionWithName:@"ESPSocketUtil-readData" reason:@"fail to read data" userInfo:nil];
        @throw e;

    }
    NSRange range = NSMakeRange(bufferOffset, bufferCount);
    [buffer replaceBytesInRange:range withBytes:[data bytes]];
}

@end
