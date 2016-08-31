//
//  ESPLineReader.m
//  MeshProxy
//
//  Created by 白 桦 on 4/12/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPLineReader.h"

@interface ESPLineReader()

@property (nonatomic, strong) NSMutableData* data;
@property (nonatomic, assign) NSUInteger total;
@property (nonatomic, assign) NSUInteger current;
@property (nonatomic, assign) Byte lastByte;
@property (nonatomic, assign) BOOL lastByteWasSwallow;

@end

#define LF      0x0A
#define CR      0x0D

@implementation ESPLineReader

- (instancetype)initWithData: (NSData *)data
{
    self = [super init];
    if (self) {
        _data = data==nil ? [[NSMutableData alloc]init] : [NSMutableData dataWithData:data];
        _total = [data length];
        _current = 0;
        _lastByte = -1;
        _lastByteWasSwallow = NO;
    }
    return self;
}

- (instancetype)init
{
    perror("ESPLineReader can't init without data or string");
    assert(0);
}

- (instancetype)initWithStr:(NSString *)str
{
    NSData *data = str==nil ? nil : [str dataUsingEncoding:NSUTF8StringEncoding];
    return [self initWithData: data];
}

- (void)appendData:(NSData *)data
{
    [_data appendData:data];
    _total += [data length];
}

- (void) appendStr: (NSString *)str
{
    if (str!=nil) {
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [self appendData:data];
    }
}

- (NSString *)readLine
{
    NSMutableData *lineData = [[NSMutableData alloc]init];
    Byte oneByte = -1;
    Byte oneBytes[] = {-1};
    BOOL lastWasCR = NO;
    Byte *bytes = (Byte *)[_data bytes];
    // avoid swallow
    if (_lastByteWasSwallow) {
        oneByte = _lastByte;
        _lastByteWasSwallow = NO;
    } else {
        if (_current < _total) {
            oneByte = bytes[_current++];
        } else {
            perror("ESPLineReader readLine() _current >= _total");
            return nil;
        }
    }
    // check lastWasCR
    lastWasCR = oneByte == CR;
    if (!lastWasCR && oneByte!= LF) {
        oneBytes[0] = oneByte;
        [lineData appendBytes:oneBytes length:1];
    }
    // check first was LF
    else if (oneByte == LF) {
        return [[NSString alloc]init];
    }
    
    while (_current < _total) {
        // read one byte
        oneByte = bytes[_current++];
        if (lastWasCR) {
            if (oneByte == LF) {
                break;
            } else {
                // tag last byte was swallow
                _lastByte = oneByte;
                _lastByteWasSwallow = YES;
                break;
            }
        } else {
            // clear lastWasCR
            lastWasCR = NO;
            if (oneByte == LF) {
                break;
            } else if (oneByte == CR) {
                lastWasCR = YES;
            } else {
                // append one byte
                oneBytes[0] = oneByte;
                [lineData appendBytes:oneBytes length:1];
            }
        }
    }
    
    if (oneByte!=LF && oneByte!=CR) {
//        perror("ESPLineReader() readLine() last byte isn't LF and CR");
        return nil;
    }
    
    return [[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding];
}

- (NSString *) description
{
    return [[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
}

@end
