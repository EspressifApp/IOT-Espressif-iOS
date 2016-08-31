//
//  DeviceLightViewController.h
//  suite
//
//  Created by 白 桦 on 5/20/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESPDeviceLight.h"
#import "AFXMenu.h"

@interface ESPDeviceLightViewController : UIViewController<AFXMenuDelegate>

@property (nonatomic, strong) ESPDeviceLight *deviceLight;

@end
