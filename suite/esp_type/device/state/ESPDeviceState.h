//
//  ESPDeviceState.h
//  suite
//
//  Created by 白 桦 on 5/25/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ESPDeviceStateEnum{
    NEW_ESP_DEVICESTATE, LOCAL_ESP_DEVICESTATE, INTERNET_ESP_DEVICESTATE, OFFLINE_ESP_DEVICESTATE, CONFIGURING_ESP_DEVICESTATE, UPGRADING_LOCAL_ESP_DEVICESTATE, UPGRADING_INTERNET_ESP_DEVICESTATE, ACTIVATING_ESP_DEVICESTATE, DELETED_ESP_DEVICESTATE, RENAMED_ESP_DEVICESTATE, CLEAR_ESP_DEVICESTATE
}ESPDeviceStateEnum;

@interface ESPDeviceState : NSObject<NSCopying>

-(instancetype) init;
-(instancetype) initWithState:(int)state;

-(ESPDeviceStateEnum) espStateEnum;
-(int) espStateValue;
-(void) setEspStateValue:(int) state;

-(void) addStateNew;
-(void) clearStateNew;
-(BOOL) isStateNew;

-(void) addStateLocal;
-(void) clearStateLocal;
-(BOOL) isStateLocal;

-(void) addStateInternet;
-(void) clearStateInternet;
-(BOOL) isStateInternet;

-(void) addStateOffline;
-(void) clearStateOffline;
-(BOOL) isStateOffline;

-(void) addStateConfiguring;
-(void) clearStateConfiguring;
-(BOOL) isStateConfiguring;

-(void) addStateUpgradeLocal;
-(void) clearStateUpgradeLocal;
-(BOOL) isStateUpgradeLocal;

-(void) addStateUpgradeInternet;
-(void) clearStateUpgradeInternet;
-(BOOL) isStateUpgradeInternet;

-(void) addStateActivating;
-(void) clearStateActivating;
-(BOOL) isStateActivating;

-(void) addStateDeleted;
-(void) clearStateDeleted;
-(BOOL) isStateDeleted;

-(void) addStateRenamed;
-(void) clearStateRenamed;
-(BOOL) isStateRenamed;

-(void) clearState;
-(BOOL) isStateClear;

@end
