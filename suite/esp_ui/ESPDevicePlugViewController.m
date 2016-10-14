//
//  ESPDevicePlugViewController.m
//  suite
//
//  Created by 白 桦 on 10/14/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDevicePlugViewController.h"
#import "ESPUser.h"


/**
 *       ------------------
 *       | 111111111111111 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |      22222      |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       -------------------
 *
 *       1: titlebar(drawed by ESPDeviceBaseViewController)
 *       2: switch
 *
 *       titlebar:
 *       ------------------
 *       |10             11|
 *       -------------------
 *
 *       10: titlebarLeftBtn
 *       11: titlebarRightBtn
 */

@interface ESPDevicePlugViewController ()

@property UISwitch *onOffSwh;

@end

@implementation ESPDevicePlugViewController

- (ESPDevice *)deviceBase {
    return self.devicePlug;
}

- (void)viewInit {
    // onOffSwh
    self.onOffSwh = [[UISwitch alloc]init];
    self.onOffSwh.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.onOffSwh];
    
    // self.onOffSwh.centerX = self.view.centerX
    NSLayoutConstraint *onOffSwhConstraintX = [NSLayoutConstraint constraintWithItem:self.onOffSwh attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.view addConstraint:onOffSwhConstraintX];
    // self.onOffSwh.centerY = self.view.centerY = self.view.centerY + 32 (64=20+44)
    NSLayoutConstraint *onOffSwhConstraintY = [NSLayoutConstraint constraintWithItem:self.onOffSwh attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:32.0];
    [self.view addConstraint:onOffSwhConstraintY];
    // self.onOffSwh.width > 0
    NSLayoutConstraint *onOffSwhConstraintWidth = [NSLayoutConstraint constraintWithItem:self.onOffSwh attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
    [self.view addConstraint:onOffSwhConstraintWidth];
    // self.onOffSwh.height > 0
    NSLayoutConstraint *onOffSwhConstraintHeight = [NSLayoutConstraint constraintWithItem:self.onOffSwh attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
    [self.view addConstraint:onOffSwhConstraintHeight];
}

-(void)targetActionInit {
    [self.onOffSwh addTarget:self action:@selector(executePost) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
    [self targetActionInit];
    [self executeGet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateOnOffSwh {
    self.onOffSwh.on = self.devicePlug.espStatusPlug.espIsOn;
}

-(void)executeGet {
    // start aiv
    [self startAivAnimating];
    // do action background
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        ESPUser *user = [ESPUser sharedUser];
        BOOL result = [user doActionGetDeviceStatusDevice:self.devicePlug];
#ifdef DEBUG
        NSLog(@"%@ %@ %@",[self class],NSStringFromSelector(_cmd),result?@"SUC":@"FAIL");
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            // stop aiv
            [self stopAivAnimating];
            [self updateOnOffSwh];
        });
    });
}

-(void)executePost {
    // start aiv
    [self startAivAnimating];
    __block ESPStatusPlug *statusDevice = [self.devicePlug.espStatusPlug copy];
    statusDevice.espIsOn = !statusDevice.espIsOn;
    // do action background
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        ESPUser *user = [ESPUser sharedUser];
        __block BOOL result = [user doActionPostDeviceStatusDevice:self.devicePlug Status:statusDevice];
#ifdef DEBUG
        NSLog(@"%@ %@ %@",[self class],NSStringFromSelector(_cmd),result?@"SUC":@"FAIL");
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            // stop aiv
            [self stopAivAnimating];
            // update onOffSwh if necessary
            if (!result) {
                [self updateOnOffSwh];
            }
        });
    });
}

@end
