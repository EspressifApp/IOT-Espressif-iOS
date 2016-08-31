//
//  ESPSocketUtil.h
//  MeshProxy
//
//  Created by 白 桦 on 4/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPSocketClient2.h"

@interface ESPSocketUtil : NSObject

/**
 * read http header from socket into buffer
 *
 * @param socketClient the socket client to be read
 * @param buffer the buffer to store Http Header
 * @param byteOffset the byte of offset
 * @return the count of header or -1 when exception occurs
 * @throws ESPSocketIOException the IOException
 */
+ (int) readHttpHeader: (ESPSocketClient2*) socketClient IntoBuffer: (NSMutableData *) buffer Offset: (int) byteOffset;

/**
 * find Http Header Value by its Header Key
 *
 * @param buffer the buffer stored HttpHeader
 * @param byteOffset the byte of HttpHeader
 * @param byteCount the count of HttpHeader
 * @param headerKey the Key of Header
 * @return the Value of Header or nil when can't find
 */
+ (NSString *) findHttpHeader: (NSData *) buffer Offset: (int) byteOffset Count: (int) byteCount HeaderKey: (NSString *)headerKey;

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
+ (NSData *) removeUnnecessaryHttpHeader: (NSData *) buffer HeaderLength:(int) headerLength ContentLength:(int) contentLength HttpHeaderArray: (NSArray *) httpHeaderArray NewHeaderLength: (NSInteger *) newHeaderLength;

/**
 * read some data from the socket into the buffer
 *
 * @param socketClient the socket client to be read
 * @param buffer the buffer
 * @param bufferOffset the offset of buffer
 * @param bufferCount the count byte to be read
 * @throws ESPSocketIOException the IOException
 */
+ (void) readData: (ESPSocketClient2*) socketClient IntoBuffer: (NSMutableData *)buffer Offset: (int) bufferOffset Count: (int) bufferCount;

@end
