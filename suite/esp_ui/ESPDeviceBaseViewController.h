//
//  ESPDeviceBaseViewController.h
//  suite
//
//  Created by 白 桦 on 10/14/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESPDevice.h"
#import "AFXMenu.h"

@interface ESPDeviceBaseViewController : UIViewController<AFXMenuDelegate>

/**
 * abstract method which should be override by subclass to provide device for show device name,
 * do device upgrade and etc.
 */
-(ESPDevice *) deviceBase;

/**
 * start UIActivityIndicatorView in the center
 */
- (void) startAivAnimating;

/**
 * stop UIActivityIndicatorView in the center
 */
- (void) stopAivAnimating;

@end
