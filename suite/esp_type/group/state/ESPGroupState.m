//
//  ESPGroupState.m
//  suite
//
//  Created by 白 桦 on 6/2/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPGroupState.h"

@interface ESPGroupState()

@property (nonatomic, assign) int state;

@end

@implementation ESPGroupState

-(instancetype) init
{
    return [self initWithState:0];
}

-(instancetype) initWithState:(int)state
{
    self = [super init];
    if (self) {
        self.state = state;
    }
    return self;
}

-(void) addStateXXX:(ESPGroupStateEnum) stateEnum
{
    self.state |= (1<<stateEnum);
}

-(void) clearStateXXX:(ESPGroupStateEnum) stateEnum
{
    self.state &= (~(1<<stateEnum));
}

-(BOOL) isStateXXX:(ESPGroupStateEnum) stateEnum
{
    return (self.state & (1 << stateEnum))!=0;
}

-(int) stateValue
{
    return self.state;
}

-(void) setStateValue:(int) state
{
    self.state = state;
}

-(void) addStateDeleted
{
    [self addStateXXX:DELETED_ESP_GROUPSTATE];
}

-(void) clearStateDeleted
{
    [self clearStateXXX:DELETED_ESP_GROUPSTATE];
}

-(BOOL) isStateDeleted
{
    return [self isStateXXX:DELETED_ESP_GROUPSTATE];
}

-(void) addStateRenamed
{
    [self addStateXXX:RENAMED_ESP_GROUPSTATE];
}

-(void) clearStateRenamed
{
    [self clearStateXXX:RENAMED_ESP_GROUPSTATE];
}

-(BOOL) isStateRenamed
{
    return [self isStateXXX:RENAMED_ESP_GROUPSTATE];
}

-(void) clearState
{
    self.state = 0;
}

-(BOOL) isStateClear
{
    return self.state == 0;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    const ESPGroupState *other = object;
    return self.state == other.state;
}

-(NSString *)description
{
    NSString *hexAddr = [super description];
    NSMutableString *mstr = [[NSMutableString alloc]init];
    if ([self isStateRenamed]) {
        [mstr appendString:@"RENAMED,"];
    }
    if ([self isStateDeleted]) {
        [mstr appendString:@"DELETED,"];
    }
    if ([self isStateClear]) {
        [mstr appendString:@"CLEAR,"];
    }
    return [NSString stringWithFormat:@"[%@ %@]",hexAddr,[mstr substringToIndex:[mstr length]-1]];
}

@end
