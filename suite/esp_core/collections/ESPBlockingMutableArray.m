
//
//  ESPBlockingArray.m
//  MeshProxy
//
//  Created by 白 桦 on 4/14/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPBlockingMutableArray.h"
#import "ESPInterruptException.h"

@interface ESPBlockingMutableArray()

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSCondition *lock;
@property (nonatomic, assign) BOOL isInterrupted;

@end

@implementation ESPBlockingMutableArray

- (instancetype)init
{
    self = [super init];
    if (self) {
        _array = [[NSMutableArray alloc]init];
        _lock = [[NSCondition alloc]init];
        _isInterrupted = NO;
    }
    return self;
}

#pragma NSArray and NSMutableArray API

- (void)addObject:(id)anObject
{
    [_lock lock];
    [_array addObject:anObject];
    [_lock signal];
    [_lock unlock];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [_lock lock];
    [_array insertObject:anObject atIndex:index];
    [_lock signal];
    [_lock unlock];
}

- (void)removeLastObject;
{
    [_lock lock];
    [_array removeLastObject];
    [_lock unlock];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [_lock lock];
    [_array removeObjectAtIndex:index];
    [_lock unlock];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [_lock lock];
    [_array replaceObjectAtIndex:index withObject:anObject];
    [_lock unlock];
}

- (void)removeAllObjects
{
    [_lock lock];
    [_array removeAllObjects];
    [_lock unlock];
}

- (NSUInteger)count
{
    NSUInteger count;
    [_lock lock];
    count = [_array count];
    [_lock unlock];
    return count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    id object;
    [_lock lock];
    object = [_array objectAtIndex:index];
    [_lock unlock];
    return object;
}

#pragma custom API

/**
 * check whether ESPBlockingMutableArray is empty
 *
 * @return whehter ESPBlockingMutableArray
 */
- (BOOL)isEmpty
{
    BOOL isEmpty;
    [_lock lock];
    isEmpty = [_array count] <= 0;
    [_lock unlock];
    return isEmpty;
}

/**
 * wait ESPBlockingMutableArray not empty or throw ESPInterruptException
 *
 * @throw ESPInterruptException
 */
- (void)wait
{
    [_lock lock];
    while ([_array count] == 0 && !_isInterrupted) {
        [_lock wait];
    }
    if (_isInterrupted) {
        _isInterrupted = NO;
        NSString *exceptionName = @"ESPBlockingMutableArray-wait";
        NSString *exceptionReason = @"wait is interrupted";
        NSException *e = [ESPInterruptException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
        [_lock unlock];
        @throw e;
    } else {
        [_lock unlock];
    }
}

/**
 * wait ESPBlockingMutableArray not empty until timeout or throw ESPInterruptException
 *
 * @param timeout timeout in milliseconds
 * @throw ESPInterruptException
 * @return YES if the condition was signaled; otherwise, NO if the time limit was reached.
 */
- (BOOL)waitUntilTimeout:(int) timeout
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow: timeout/1000.0];
    [_lock lock];
    BOOL signaled = NO;
    while ([_array count] == 0 && !_isInterrupted && (signaled = [_lock waitUntilDate:date])) {
    }
    if (_isInterrupted) {
        _isInterrupted = NO;
        NSString *exceptionName = @"ESPBlockingMutableArray-waitUntilTimeout";
        NSString *exceptionReason = @"wait is interrupted";
        NSException *e = [ESPInterruptException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
        [_lock unlock];
        @throw e;
    } else {
        [_lock unlock];
    }
    return signaled || [_array count] > 0;
}

/**
 * interrupt ESPBlockingMutableArray(make wait or take throw ESPInterruptException)
 */
- (void)interrupt
{
    [_lock lock];
    _isInterrupted = YES;
    [_lock signal];
    [_lock unlock];
}

/**
 * wait ESPBlockingMutableArray not empty firstly,
 * get first element and remove it from ESPBlockingMutableArray then.
 * if it is interrupted, thow ESPBlockingMutableArray
 *
 * @throw ESPInterruptException
 * @return first element from ESPBlockingMutableArray
 */
- (id)take
{
    id object = nil;
    
    [_lock lock];
    while ([_array count] == 0 && !_isInterrupted) {
        [_lock wait];
    }
    if (_isInterrupted) {
        _isInterrupted = NO;
        NSString *exceptionName = @"ESPBlockingMutableArray-take";
        NSString *exceptionReason = @"take is interrupted";
        NSException *e = [ESPInterruptException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
        [_lock unlock];
        @throw e;
    } else {
        object = [_array objectAtIndex:0];
        [_array removeObjectAtIndex:0];
        [_lock unlock];
        return object;
    }
}

/**
 * wait ESPBlockingMutableArray not empty firstly,
 * get first element and remove it from ESPBlockingMutableArray then.
 * if it is interrupted, throw ESPInterruptException
 * if it is timeout, return nil
 *
 * @param timeout timeout in milliseconds
 * @throw ESPInterruptException
 * @return first element from ESPBlockingMutableArray or nil
 */
- (id)takeUntilTimeout:(int) timeout
{
    id object = nil;
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow: timeout/1000.0];
    [_lock lock];
    BOOL signaled = NO;
    while ([_array count] == 0 && !_isInterrupted && (signaled = [_lock waitUntilDate:date])) {
    }
    if (_isInterrupted) {
        _isInterrupted = NO;
        NSString *exceptionName = @"ESPBlockingMutableArray-takeUntilTimeout";
        NSString *exceptionReason = @"takeUntilTimeout is interrupted";
        NSException *e = [ESPInterruptException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
        [_lock unlock];
        @throw e;
    } else {
        if ([_array count] > 0) {
            object = [_array objectAtIndex:0];
            [_array removeObjectAtIndex:0];
        }
        [_lock unlock];
    }
    return object;
}

/**
 * peek first element(without removement)
 *
 * @return first element or nil(when ESPBlockingMutableArray is empty)
 */
- (id)peek
{
    id object = nil;
    
    [_lock lock];
    if ([_array count]>0) {
        object = [_array objectAtIndex:0];
    }
    [_lock unlock];
    
    return object;
}

/**
 * clear isInterrupted bit
 */
- (void)clearInterrupt
{
    [_lock lock];
    _isInterrupted = NO;
    [_lock unlock];
}

/**
 * 
 * implement NSFastEnumeration protocol to support fast in transversation
 *
 */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [_array countByEnumeratingWithState:state objects:buffer count:len];
}

@end
