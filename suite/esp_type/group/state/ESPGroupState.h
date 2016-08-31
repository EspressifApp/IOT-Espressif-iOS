//
//  ESPGroupState.h
//  suite
//
//  Created by 白 桦 on 6/2/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ESPGroupStateEnum{
    DELETED_ESP_GROUPSTATE, RENAMED_ESP_GROUPSTATE, CLEAR_ESP_GROUPSTATE
}ESPGroupStateEnum;

@interface ESPGroupState : NSObject

-(instancetype) init;
-(instancetype) initWithState:(int)state;

-(int) stateValue;
-(void) setStateValue:(int) state;

-(void) addStateDeleted;
-(void) clearStateDeleted;
-(BOOL) isStateDeleted;

-(void) addStateRenamed;
-(void) clearStateRenamed;
-(BOOL) isStateRenamed;

-(void) clearState;
-(BOOL) isStateClear;

@end
