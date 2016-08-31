//
//  ESPBlockingArray.h
//  MeshProxy
//
//  Created by 白 桦 on 4/14/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPBlockingMutableArray<ObjectType,NSFastEnumeration> : NSObject

#pragma NSArray and NSMutableArray API
- (void)addObject:(id)anObject;

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;

- (void)removeLastObject;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;

- (void)removeAllObjects;

- (NSUInteger)count;

- (ObjectType)objectAtIndex:(NSUInteger)index;

#pragma custom API

/**
 * check whether ESPBlockingMutableArray is empty
 *
 * @return whehter ESPBlockingMutableArray
 */
- (BOOL)isEmpty;
/**
 * wait ESPBlockingMutableArray not empty or throw ESPInterruptException
 *
 * @throw ESPInterruptException
 */
- (void)wait;

/**
 * wait ESPBlockingMutableArray not empty until timeout or throw ESPInterruptException
 *
 * @param timeout timeout in milliseconds
 * @throw ESPInterruptException
 * @return YES if the condition was signaled; otherwise, NO if the time limit was reached.
 */
- (BOOL)waitUntilTimeout:(int) timeout;

/**
 * interrupt ESPBlockingMutableArray(make wait or take throw ESPInterruptException)
 */
- (void)interrupt;
/**
 * wait ESPBlockingMutableArray not empty firstly,
 * get first element and remove it from ESPBlockingMutableArray then.
 * if it is interrupted, throw ESPInterruptException
 *
 * @throw ESPInterruptException
 * @return first element from ESPBlockingMutableArray
 */
- (id)take;

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
- (id)takeUntilTimeout:(int) timeout;

/**
 * peek first element(without removement)
 *
 * @return first element or nil(when ESPBlockingMutableArray is empty)
 */
- (id)peek;

/**
 * clear isInterrupted bit
 */
- (void)clearInterrupt;

/**
 *
 * declare NSFastEnumeration protocol to support fast in transversation and make complier dumb
 *
 */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
@end
