//
//  ESPDeviceState.m
//  suite
//
//  Created by 白 桦 on 5/25/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDeviceState.h"

@interface ESPDeviceState()

@property (nonatomic, assign) int state;

@end

@implementation ESPDeviceState

- (instancetype)init
{
    return [self initWithState:0];
}

- (instancetype)initWithState:(int)state
{
    self = [super init];
    if (self) {
        self.state = state;
    }
    return self;
}

/**
 * although these variables are final, but their mState could be changed. but please don't change them. or the bugs
 * will be produced
 */
+ (const ESPDeviceState *) NEW
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *NEW_STATE;
    dispatch_once(&predicate, ^{
        NEW_STATE = [[ESPDeviceState alloc]initWithState:1<<NEW_ESP_DEVICESTATE];
    });
    return NEW_STATE;
}
+ (const ESPDeviceState *) LOCAL
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *LOCAL_STATE;
    dispatch_once(&predicate, ^{
        LOCAL_STATE = [[ESPDeviceState alloc]initWithState:1<<LOCAL_ESP_DEVICESTATE];
    });
    return LOCAL_STATE;
}
+ (const ESPDeviceState *) INTERNET
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *INTERNET_STATE;
    dispatch_once(&predicate, ^{
        INTERNET_STATE = [[ESPDeviceState alloc]initWithState:1<<INTERNET_ESP_DEVICESTATE];
    });
    return INTERNET_STATE;
}
+ (const ESPDeviceState *) OFFLINE
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *OFFLINE_STATE;
    dispatch_once(&predicate, ^{
        OFFLINE_STATE = [[ESPDeviceState alloc]initWithState:1<<OFFLINE_ESP_DEVICESTATE];
    });
    return OFFLINE_STATE;
}
+ (const ESPDeviceState *) CONFIGURING
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *CONFIGURING_STATE;
    dispatch_once(&predicate, ^{
        CONFIGURING_STATE = [[ESPDeviceState alloc]initWithState:1<<CONFIGURING_ESP_DEVICESTATE];
    });
    return CONFIGURING_STATE;
}
+ (const ESPDeviceState *) UPGRADING_LOCAL
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *UPGRADING_LOCAL_STATE;
    dispatch_once(&predicate, ^{
        UPGRADING_LOCAL_STATE = [[ESPDeviceState alloc]initWithState:1<<UPGRADING_LOCAL_ESP_DEVICESTATE];
    });
    return UPGRADING_LOCAL_STATE;
}
+ (const ESPDeviceState *) UPGRADING_INTERNET
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *UPGRADING_INTERNET_STATE;
    dispatch_once(&predicate, ^{
        UPGRADING_INTERNET_STATE = [[ESPDeviceState alloc]initWithState:1<<UPGRADING_INTERNET_ESP_DEVICESTATE];
    });
    return UPGRADING_INTERNET_STATE;
}
+ (const ESPDeviceState *) ACTIVATING
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *ACTIVATING_STATE;
    dispatch_once(&predicate, ^{
        ACTIVATING_STATE = [[ESPDeviceState alloc]initWithState:1<<ACTIVATING_ESP_DEVICESTATE];
    });
    return ACTIVATING_STATE;
}
+ (const ESPDeviceState *) DELETED
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *DELETED_STATE;
    dispatch_once(&predicate, ^{
        DELETED_STATE = [[ESPDeviceState alloc]initWithState:1<<DELETED_ESP_DEVICESTATE];
    });
    return DELETED_STATE;
}
+ (const ESPDeviceState *) RENAMED
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *RENAMED_STATE;
    dispatch_once(&predicate, ^{
        RENAMED_STATE = [[ESPDeviceState alloc]initWithState:1<<RENAMED_ESP_DEVICESTATE];
    });
    return RENAMED_STATE;
}
+ (const ESPDeviceState *) CLEAR
{
    static dispatch_once_t predicate;
    const static ESPDeviceState *CLEAR_STATE;
    dispatch_once(&predicate, ^{
        CLEAR_STATE = [[ESPDeviceState alloc]initWithState:0];
    });
    return CLEAR_STATE;
}

-(void) __checkvalid
{
    if (self==[ESPDeviceState NEW]) {
        NSLog(@"[ESPDeviceState NEW] can't be changed or something will make supprise");
        abort();
    } else if (self==[ESPDeviceState LOCAL]) {
        NSLog(@"[ESPDeviceState LOCAL] can't be changed or something will make supprise");
        abort();
    } else if (self==[ESPDeviceState INTERNET]) {
        NSLog(@"[ESPDeviceState INTERNET] can't be changed or something will make supprise");
        abort();
    } else if (self==[ESPDeviceState OFFLINE]) {
        NSLog(@"[ESPDeviceState OFFLINE] can't be changed or something will make supprise");
        abort();
    } else if (self==[ESPDeviceState CONFIGURING]) {
        NSLog(@"[ESPDeviceState CONFIGURING] can't be changed or something will make supprise");
        abort();
    } else if (self==[ESPDeviceState UPGRADING_LOCAL]) {
        NSLog(@"[ESPDeviceState UPGRADING_LOCAL] can't be changed or something will make supprise");
        abort();
    } else if (self==[ESPDeviceState UPGRADING_INTERNET]) {
        NSLog(@"[ESPDeviceState UPGRADING_INTERNET] can't be changed or something will make supprise");
        abort();
    } else if (self==[ESPDeviceState ACTIVATING]) {
        NSLog(@"[ESPDeviceState ACTIVATING] can't be changed or something will make supprise");
        abort();
    } else if (self==[ESPDeviceState DELETED]) {
        NSLog(@"[ESPDeviceState DELETED] can't be changed or something will make supprise");
        abort();
    } else if (self==[ESPDeviceState RENAMED]) {
        NSLog(@"[ESPDeviceState RENAMED] can't be changed or something will make supprise");
        abort();
    } else if (self==[ESPDeviceState CLEAR]) {
        NSLog(@"[ESPDeviceState CLEAR] can't be changed or something will make supprise");
        abort();
    }
}

-(void) addStateXXX:(ESPDeviceStateEnum) stateEnum
{
    [self __checkvalid];
    self.state |= (1<<stateEnum);
}

-(void) clearStateXXX:(ESPDeviceStateEnum) stateEnum
{
    [self __checkvalid];
    self.state &= (~(1<<stateEnum));
}

-(BOOL) isStateXXX:(ESPDeviceStateEnum) stateEnum
{
    return (self.state & (1 << stateEnum))!=0;
}

-(ESPDeviceStateEnum) espStateEnum
{
    if ([self isStateUpgradeLocal]) {
        return UPGRADING_LOCAL_ESP_DEVICESTATE;
    } else if([self isStateUpgradeInternet]) {
        return UPGRADING_INTERNET_ESP_DEVICESTATE;
    } else if([self isStateOffline]) {
        return OFFLINE_ESP_DEVICESTATE;
    } else if([self isStateNew]) {
        return NEW_ESP_DEVICESTATE;
    } else if([self isStateLocal]) {
        // LOCAL must be front of INTERNET
        // for the UI display priority to Local
        return LOCAL_ESP_DEVICESTATE;
    } else if([self isStateInternet]) {
        return INTERNET_ESP_DEVICESTATE;
    } else if([self isStateDeleted]) {
        return DELETED_ESP_DEVICESTATE;
    } else if([self isStateConfiguring]) {
        return CONFIGURING_ESP_DEVICESTATE;
    } else if([self isStateActivating]) {
        return ACTIVATING_ESP_DEVICESTATE;
    } else if([self isStateRenamed]) {
         // RENAMED and CLEAR should be in the end
        return RENAMED_ESP_DEVICESTATE;
    } else if([self isStateClear]) {
        return CLEAR_ESP_DEVICESTATE;
    }
    NSLog(@"ESPDeviceState deviceState can't find proper state");
    return -1;
}

-(int) espStateValue
{
    [self __checkvalid];
    return self.state;
}
-(void) setEspStateValue:(int) state
{
    [self __checkvalid];
    self.state = state;
}

-(void) addStateNew
{
    [self addStateXXX:NEW_ESP_DEVICESTATE];
}
-(void) clearStateNew
{
    [self clearStateXXX:NEW_ESP_DEVICESTATE];
}
-(BOOL) isStateNew
{
    return [self isStateXXX:NEW_ESP_DEVICESTATE];
}

-(void) addStateLocal
{
    [self addStateXXX:LOCAL_ESP_DEVICESTATE];
}
-(void) clearStateLocal
{
    [self clearStateXXX:LOCAL_ESP_DEVICESTATE];
}
-(BOOL) isStateLocal
{
    return [self isStateXXX:LOCAL_ESP_DEVICESTATE];
}

-(void) addStateInternet
{
    [self addStateXXX:INTERNET_ESP_DEVICESTATE];
}
-(void) clearStateInternet
{
    [self clearStateXXX:INTERNET_ESP_DEVICESTATE];
}
-(BOOL) isStateInternet
{
    return [self isStateXXX:INTERNET_ESP_DEVICESTATE];
}

-(void) addStateOffline
{
    [self addStateXXX:OFFLINE_ESP_DEVICESTATE];
}
-(void) clearStateOffline
{
    [self clearStateXXX:OFFLINE_ESP_DEVICESTATE];
}
-(BOOL) isStateOffline
{
    return [self isStateXXX:OFFLINE_ESP_DEVICESTATE];
}

-(void) addStateConfiguring
{
    [self addStateXXX:CONFIGURING_ESP_DEVICESTATE];
}
-(void) clearStateConfiguring
{
    [self clearStateXXX:CONFIGURING_ESP_DEVICESTATE];
}
-(BOOL) isStateConfiguring
{
    return [self isStateXXX:CONFIGURING_ESP_DEVICESTATE];
}

-(void) addStateUpgradeLocal
{
    [self addStateXXX:UPGRADING_LOCAL_ESP_DEVICESTATE];
}
-(void) clearStateUpgradeLocal
{
    [self clearStateXXX:UPGRADING_LOCAL_ESP_DEVICESTATE];
}
-(BOOL) isStateUpgradeLocal
{
    return [self isStateXXX:UPGRADING_LOCAL_ESP_DEVICESTATE];
}

-(void) addStateUpgradeInternet
{
    [self addStateXXX:UPGRADING_INTERNET_ESP_DEVICESTATE];
}
-(void) clearStateUpgradeInternet
{
    [self clearStateXXX:UPGRADING_INTERNET_ESP_DEVICESTATE];
}
-(BOOL) isStateUpgradeInternet
{
    return [self isStateXXX:UPGRADING_INTERNET_ESP_DEVICESTATE];
}

-(void) addStateActivating
{
    [self addStateXXX:ACTIVATING_ESP_DEVICESTATE];
}
-(void) clearStateActivating
{
    [self clearStateXXX:ACTIVATING_ESP_DEVICESTATE];
}
-(BOOL) isStateActivating
{
    return [self isStateXXX:ACTIVATING_ESP_DEVICESTATE];
}

-(void) addStateDeleted
{
    [self addStateXXX:DELETED_ESP_DEVICESTATE];
}
-(void) clearStateDeleted
{
    [self clearStateXXX:DELETED_ESP_DEVICESTATE];
}
-(BOOL) isStateDeleted
{
    return [self isStateXXX:DELETED_ESP_DEVICESTATE];
}

-(void) addStateRenamed
{
    [self addStateXXX:RENAMED_ESP_DEVICESTATE];
}
-(void) clearStateRenamed
{
    [self clearStateXXX:RENAMED_ESP_DEVICESTATE];
}
-(BOOL) isStateRenamed
{
    return [self isStateXXX:RENAMED_ESP_DEVICESTATE];
}

-(void) clearState
{
    [self __checkvalid];
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
    
    const ESPDeviceState *other = object;
    return self.state == other.state;
}

-(id)copyWithZone:(NSZone *)zone
{
    ESPDeviceState *copy = [[self class]allocWithZone:zone];
    if (copy) {
        copy.state = self.state;
    }
    return copy;
}

-(NSString *)description
{
//    NSString *hexAddr = [super description];
    NSMutableString *mstr = [[NSMutableString alloc]init];
    if ([self isStateUpgradeLocal]) {
        [mstr appendString:@"UPGRADING_LOCAL,"];
    }
    if ([self isStateUpgradeInternet]) {
        [mstr appendString:@"UPGRADING_INTERNET,"];
    }
    if ([self isStateOffline]) {
        [mstr appendString:@"OFFLINE,"];
    }
    // RENAMED state is just useful for debugging
//    if ([self isStateRenamed]) {
//        [mstr appendString:@"RENAMED,"];
//    }
    if ([self isStateNew]) {
        [mstr appendString:@"NEW,"];
    }
    if ([self isStateLocal]) {
        [mstr appendString:@"LOCAL,"];
    }
    if ([self isStateInternet]) {
        [mstr appendString:@"INTERNET,"];
    }
    if ([self isStateDeleted]) {
        [mstr appendString:@"DELETED,"];
    }
    if ([self isStateConfiguring]) {
        [mstr appendString:@"CONFIGURING,"];
    }
    if ([self isStateClear]) {
        [mstr appendString:@"CLEAR,"];
    }
    if ([self isStateActivating]) {
        [mstr appendString:@"ACTIVATING,"];
    }
//    return [NSString stringWithFormat:@"[%@ %@]",hexAddr,[mstr substringToIndex:[mstr length]-1]];
    return [NSString stringWithFormat:@"[%@]",[mstr substringToIndex:[mstr length]-1]];
}

@end
