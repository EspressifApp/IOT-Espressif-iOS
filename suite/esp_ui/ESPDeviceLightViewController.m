//
//  DeviceLightViewController.m
//  suite
//
//  Created by 白 桦 on 5/20/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDeviceLightViewController.h"
#import "ESPUser.h"
#import "ESPStatusLight.h"
#import "ESPCommandLightGetStatusInternet.h"
#import "ESPCommandLightPostStatusInternet.h"
#import "ESPCommandLightGetStatusLocal.h"
#import "ESPCommandLightPostStatusLocal.h"
#import "ESPActionDeviceUpgradeLocal.h"
#import "ESPActionDeviceUpgradeInternet.h"
#import "ESPVersionUtil.h"
#import "ESPConstantsCommandLight.h"

/**
 *       ------------------
 *       | 111111111111111 |
 *       |                 |
 *       | 222222222222222 |
 *       | 222222222222222 |
 *       | 222222222222222 |
 *       |
 *       | 333  4444444444 |
 *       |                 |
 *       | 555  6666666666 |
 *       |                 |
 *       | 777  8888888888 |
 *       |                 |
 *       | 999999999999999 |
 *       |                 |
 *       -------------------
 *
 *       1: titlebar
 *       2: colorboard
 *       3: redLb
 *       4: redSld
 *       5: greenLb
 *       6: greenSld
 *       7: blueLb
 *       8: blueSld
 *       9: confirmBtn
 *       x: onOffSwh:(only new protocol light will be showed)
 *
 *       titlebar:
 *       ------------------
 *       |10             11|
 *       -------------------
 *
 *       10: titlebarLeftBtn
 *       11: titlebarRightBtn
 */
@interface ESPDeviceLightViewController()

@property (nonatomic, strong) UIView *colorboard;
@property (nonatomic, strong) UISlider *redSld;
@property (nonatomic, strong) UILabel *redLb;
@property (nonatomic, strong) UISlider *greenSld;
@property (nonatomic, strong) UILabel *greenLb;
@property (nonatomic, strong) UISlider *blueSld;
@property (nonatomic, strong) UILabel *blueLb;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UISwitch *onOffSwh;

@property (nonatomic, strong) UIActivityIndicatorView *aiv;

@end

#define RGB_MIN     0
#define RGB_MAX     255

@implementation ESPDeviceLightViewController

-(BOOL)isLightProtocolNew {
    return ([ESPVersionUtil resolveValue:self.deviceLight.espRomVersionCurrent] >= [ESPVersionUtil resolveValue:ESP_LIGHT_VERSION_NEW_PROTOCOL]);
}

-(void)viewInit {
    
    UINavigationBar *titlebar = [[UINavigationBar alloc]init];
    titlebar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titlebar];
    
    // self.titlebar.leading = self.view.leading
    NSLayoutConstraint *titlebarConstraintX = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:titlebarConstraintX];
    // self.titlebar.top = self.view.top + 20.0
    NSLayoutConstraint *titlebarConstraintY = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0];
    [self.view addConstraint:titlebarConstraintY];
    // self.titlebar.width = self.view.width
    NSLayoutConstraint *titlebarConstraintWidth = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:titlebarConstraintWidth];
    // self.titlebar.height = 44.0
    NSLayoutConstraint *titlebarConstraintHeight = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:44.0];
    [self.view addConstraint:titlebarConstraintHeight];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    navigationItem.title = self.deviceLight.espDeviceName;
    
    // titlebar left
    UIBarButtonItem *titlebarItemLeft = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(tapTitlebarButtonLeft)];
    navigationItem.leftBarButtonItem = titlebarItemLeft;
    
    // titlebar right: menu
    AFXMenu *menu = [[AFXMenu alloc]init];
    if([self addMenuItems:menu]){
        menu.afxMenuTitle = @"Menu";
        menu.translatesAutoresizingMaskIntoConstraints = NO;
        UIBarButtonItem *titlebarItemRight = [[UIBarButtonItem alloc]initWithCustomView:menu];
        navigationItem.rightBarButtonItem = titlebarItemRight;
        [titlebar pushNavigationItem:navigationItem animated:NO];
        
        CGFloat titlebarItemRightWidth = 53.0f;
        CGFloat titlebarItemRightMargin = 3.0f;
        
        // menu.leading = titlebar.trailing - titlebarItemRightWidth - titlebarItemRightMargin
        NSLayoutConstraint *menuConstraintX = [NSLayoutConstraint constraintWithItem:menu attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:titlebar attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-titlebarItemRightWidth-titlebarItemRightMargin];
        [titlebar addConstraint:menuConstraintX];
        // menu.top = titlebar.top
        NSLayoutConstraint *menuConstraintY = [NSLayoutConstraint constraintWithItem:menu attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titlebar attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [titlebar addConstraint:menuConstraintY];
        // menu.width = titlebarItemRightWidth
        NSLayoutConstraint *menuConstraintWidth = [NSLayoutConstraint constraintWithItem:menu attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:titlebarItemRightWidth];
        [titlebar addConstraint:menuConstraintWidth];
        // menu.height = titlebar.height
        NSLayoutConstraint *menuConstraintHeight = [NSLayoutConstraint constraintWithItem:menu attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:titlebar attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [titlebar addConstraint:menuConstraintHeight];
    } else {
        [titlebar pushNavigationItem:navigationItem animated:NO];
    }
    
    // set background white
    self.view.backgroundColor = [UIColor whiteColor];
    
    // colorboard
    self.colorboard = [[UIView alloc]init];
    self.colorboard.translatesAutoresizingMaskIntoConstraints = NO;
    self.colorboard.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.colorboard];
    
    // self.colorboard.leading = self.view.trailing * 0.05
    NSLayoutConstraint *colorboardConstraintX = [NSLayoutConstraint constraintWithItem:self.colorboard attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:0.05 constant:0.0];
    [self.view addConstraint:colorboardConstraintX];
    // self.colorboard.top = 64 + (self.view.bottom - 64) * 0.05 = self.view.bottom * 0.05 + 60.8 (64=20+44)
    NSLayoutConstraint *colorboardConstraintY = [NSLayoutConstraint constraintWithItem:self.colorboard attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.05 constant:60.8];
    [self.view addConstraint:colorboardConstraintY];
    // self.colorboard.width = self.view.width * 0.9
    NSLayoutConstraint *colorboardConstraintWidth = [NSLayoutConstraint constraintWithItem:self.colorboard attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.9 constant:0.0];
    [self.view addConstraint:colorboardConstraintWidth];
    // self.colorboard.height = (self.view.height - 64) * 0.3 = self.view.height * 0.3 - 19.2 (64=20+44)
    NSLayoutConstraint *colorboardConstraintHeight = [NSLayoutConstraint constraintWithItem:self.colorboard attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.3 constant:-19.2];
    [self.view addConstraint:colorboardConstraintHeight];
    
    // redLb
    self.redLb = [[UILabel alloc]init];
    self.redLb.translatesAutoresizingMaskIntoConstraints = NO;
    self.redLb.text = @"0";
    [self.view addSubview:self.redLb];
    
    // self.redLb.leading = self.view.trailing * 0.05
    NSLayoutConstraint *redLbConstraintX = [NSLayoutConstraint constraintWithItem:self.redLb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:0.05 constant:0.0];
    [self.view addConstraint:redLbConstraintX];
    // self.redLb.top = 64 + (self.view.bottom - 64) * 0.4 = self.view.bottom * 0.4 + 38.4 (64=20+44)
    NSLayoutConstraint *redLbConstraintY = [NSLayoutConstraint constraintWithItem:self.redLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.4 constant:38.4];
    [self.view addConstraint:redLbConstraintY];
    // self.redLb.width = self.view.width * 0.1
    NSLayoutConstraint *redLbConstraintWidth = [NSLayoutConstraint constraintWithItem:self.redLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.1 constant:0.0];
    [self.view addConstraint:redLbConstraintWidth];
    // self.redLb.height = (self.view.height - 64) * 0.1 = self.view.height * 0.1 - 6.4 (64=20+44)
    NSLayoutConstraint *redLbConstraintHeight = [NSLayoutConstraint constraintWithItem:self.redLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.1 constant:-6.4];
    [self.view addConstraint:redLbConstraintHeight];
    
    // greenLb
    self.greenLb = [[UILabel alloc]init];
    self.greenLb.translatesAutoresizingMaskIntoConstraints = NO;
    self.greenLb.text = @"0";
    [self.view addSubview:self.greenLb];
    
    // self.greenLb.leading = self.redLb.leading
    NSLayoutConstraint *greenLbConstraintX = [NSLayoutConstraint constraintWithItem:self.greenLb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.redLb attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:greenLbConstraintX];
    // self.greenLb.top = 64 + (self.view.bottom - 64) * 0.55 = self.view.bottom * 0.55 + 28.8 (64=20+44)
    NSLayoutConstraint *greenLbConstraintY = [NSLayoutConstraint constraintWithItem:self.greenLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.55 constant:28.8];
    [self.view addConstraint:greenLbConstraintY];
    // self.greenLb.width = self.redLb.width
    NSLayoutConstraint *greenLbConstraintWidth = [NSLayoutConstraint constraintWithItem:self.greenLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.redLb attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:greenLbConstraintWidth];
    // self.greenLb.height = self.redLb.height
    NSLayoutConstraint *greenLbConstraintHeight = [NSLayoutConstraint constraintWithItem:self.greenLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.redLb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:greenLbConstraintHeight];
    
    // blueLb
    self.blueLb = [[UILabel alloc]init];
    self.blueLb.translatesAutoresizingMaskIntoConstraints = NO;
    self.blueLb.text = @"0";
    [self.view addSubview:self.blueLb];
    // self.blueLb.leading = self.greenLb.leading
    NSLayoutConstraint *blueLbConstraintX = [NSLayoutConstraint constraintWithItem:self.blueLb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.greenLb attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:blueLbConstraintX];
    // self.greenLb.top = 64 + (self.view.bottom - 64) * 0.7 = self.view.bottom * 0.7 + 19.2 (64=20+44)
    NSLayoutConstraint *blueLbConstraintY = [NSLayoutConstraint constraintWithItem:self.blueLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.7 constant:19.2];
    [self.view addConstraint:blueLbConstraintY];
    // self.blueLb.width = self.greenLb.width
    NSLayoutConstraint *blueLbConstraintWidth = [NSLayoutConstraint constraintWithItem:self.blueLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.greenLb attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:blueLbConstraintWidth];
    // self.blueLb.height = self.greenLb.height
    NSLayoutConstraint *blueLbConstraintHeight = [NSLayoutConstraint constraintWithItem:self.blueLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.greenLb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:blueLbConstraintHeight];
    
    // redSld
    self.redSld = [[UISlider alloc]init];
    self.redSld.translatesAutoresizingMaskIntoConstraints = NO;
    self.redSld.minimumValue = RGB_MIN;
    self.redSld.maximumValue = RGB_MAX;
    self.redSld.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.redSld];
    
    // self.redSld.trailing = self.view.trailing * 0.95
    NSLayoutConstraint *redSldConstraintX = [NSLayoutConstraint constraintWithItem:self.redSld attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:0.95 constant:0.0];
    [self.view addConstraint:redSldConstraintX];
    // self.redSld.top = self.redLb.top
    NSLayoutConstraint *redSldConstraintY = [NSLayoutConstraint constraintWithItem:self.redSld attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.redLb attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:redSldConstraintY];
    // self.redSld.width = self.view.width * 0.75
    NSLayoutConstraint *redSldConstraintWidth = [NSLayoutConstraint constraintWithItem:self.redSld attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.75 constant:0.0];
    [self.view addConstraint:redSldConstraintWidth];
    // self.redSld.height = self.redLb.height
    NSLayoutConstraint *redSldConstraintHeight = [NSLayoutConstraint constraintWithItem:self.redSld attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.redLb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:redSldConstraintHeight];
    
    // greenSld
    self.greenSld = [[UISlider alloc]init];
    self.greenSld.translatesAutoresizingMaskIntoConstraints = NO;
    self.greenSld.minimumValue = RGB_MIN;
    self.greenSld.maximumValue = RGB_MAX;
    self.greenSld.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.greenSld];
    
    // self.greenSld.leading = self.redSld.leading
    NSLayoutConstraint *greenSldConstraintX = [NSLayoutConstraint constraintWithItem:self.greenSld attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.redSld attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:greenSldConstraintX];
    // self.greenSld.top = self.greenLb.top
    NSLayoutConstraint *greenSldConstraintY = [NSLayoutConstraint constraintWithItem:self.greenSld attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.greenLb attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:greenSldConstraintY];
    // self.greenSld.width = self.redSld.width
    NSLayoutConstraint *greenSldConstraintWidth = [NSLayoutConstraint constraintWithItem:self.greenSld attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.redSld attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:greenSldConstraintWidth];
    // self.greenSld.height = self.redSld.height
    NSLayoutConstraint *greenSldConstraintHeight = [NSLayoutConstraint constraintWithItem:self.greenSld attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.redSld attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:greenSldConstraintHeight];
    
    self.blueSld = [[UISlider alloc]init];
    self.blueSld.translatesAutoresizingMaskIntoConstraints = NO;
    self.blueSld.minimumValue = RGB_MIN;
    self.blueSld.maximumValue = RGB_MAX;
    self.blueSld.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.blueSld];
    
    // self.blueSld.leading = self.greenSld.leading
    NSLayoutConstraint *blueSldConstraintX = [NSLayoutConstraint constraintWithItem:self.blueSld attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.greenSld attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:blueSldConstraintX];
    // self.blueSld.top = self.blueLb.top
    NSLayoutConstraint *blueSldConstraintY = [NSLayoutConstraint constraintWithItem:self.blueSld attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.blueLb attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:blueSldConstraintY];
    // self.blueSld.width = self.greenSld.width
    NSLayoutConstraint *blueSldConstraintWidth = [NSLayoutConstraint constraintWithItem:self.blueSld attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.greenSld attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:blueSldConstraintWidth];
    // self.blueSld.height = self.greenSld.height
    NSLayoutConstraint *blueSldConstraintHeight = [NSLayoutConstraint constraintWithItem:self.blueSld attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.greenSld attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:blueSldConstraintHeight];
    
    // confirmBtn
    self.confirmBtn = [[UIButton alloc]init];
    self.confirmBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.confirmBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:255.0 alpha:0.4] forState:UIControlStateHighlighted];
    self.confirmBtn.layer.borderColor = [[UIColor blueColor] CGColor];
    self.confirmBtn.layer.borderWidth = 1.0f;
    self.confirmBtn.layer.cornerRadius = 8.0f;
    self.confirmBtn.layer.masksToBounds = YES;
    [self.view addSubview:self.confirmBtn];
    
    if ([self isLightProtocolNew]) {
        // self.confirmBtn.centerX = self.view.centerX * 0.5
        NSLayoutConstraint *confirmBtnConstraintX = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:0.5 constant:0.0];
        [self.view addConstraint:confirmBtnConstraintX];
        // self.confirmBtn.top = 64 + (self.view.bottom - 64) * 0.85 = self.view.bottom * 0.85 + 9.6 (64=20+44)
        NSLayoutConstraint *confirmBtnConstraintY = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.85 constant:9.6];
        [self.view addConstraint:confirmBtnConstraintY];
        // self.confirmBtn.width = self.view.width * 0.3
        NSLayoutConstraint *confirmBtnConstraintWidth = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.3 constant:0.0];
        [self.view addConstraint:confirmBtnConstraintWidth];
        // self.confirmBtn.height = (self.view.height - 64) * 0.1 = self.view.height * 0.1 - 6.4
        NSLayoutConstraint *confirmBtnConstraintHeight = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.1 constant:-6.4];
        [self.view addConstraint:confirmBtnConstraintHeight];

        // onOffSwh
        self.onOffSwh = [[UISwitch alloc]init];
        self.onOffSwh.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.onOffSwh];
        
        // self.onOffSwh.centerX = self.view.centerX * 0.75
        NSLayoutConstraint *onOffSwhConstraintX = [NSLayoutConstraint constraintWithItem:self.onOffSwh attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.5 constant:0.0];
        [self.view addConstraint:onOffSwhConstraintX];
        // self.onOffSwh.centerY = self.confirmBtn.centerY
        NSLayoutConstraint *onOffSwhConstraintY = [NSLayoutConstraint constraintWithItem:self.onOffSwh attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.confirmBtn attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
        [self.view addConstraint:onOffSwhConstraintY];
        // self.onOffSwh.width > 0
        NSLayoutConstraint *onOffSwhConstraintWidth = [NSLayoutConstraint constraintWithItem:self.onOffSwh attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
        [self.view addConstraint:onOffSwhConstraintWidth];
        // self.onOffSwh.height > 0
        NSLayoutConstraint *onOffSwhConstraintHeight = [NSLayoutConstraint constraintWithItem:self.onOffSwh attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
        [self.view addConstraint:onOffSwhConstraintHeight];
    } else {
        // self.confirmBtn.centerX = self.view.centerX
        NSLayoutConstraint *confirmBtnConstraintX = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        [self.view addConstraint:confirmBtnConstraintX];
        // self.confirmBtn.top = 64 + (self.view.bottom - 64) * 0.85 = self.view.bottom * 0.85 + 9.6 (64=20+44)
        NSLayoutConstraint *confirmBtnConstraintY = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.85 constant:9.6];
        [self.view addConstraint:confirmBtnConstraintY];
        // self.confirmBtn.width = self.view.width * 0.3
        NSLayoutConstraint *confirmBtnConstraintWidth = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.3 constant:0.0];
        [self.view addConstraint:confirmBtnConstraintWidth];
        // self.confirmBtn.height = (self.view.height - 64) * 0.1 = self.view.height * 0.1 - 6.4
        NSLayoutConstraint *confirmBtnConstraintHeight = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.1 constant:-6.4];
        [self.view addConstraint:confirmBtnConstraintHeight];
    }
    
    // aiv
    self.aiv = [[UIActivityIndicatorView alloc]init];
    self.aiv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.aiv.color = [UIColor grayColor];
    self.aiv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.aiv];
    
    // self.aiv.centerX = self.view.centerX
    NSLayoutConstraint *aivConstraintX = [NSLayoutConstraint constraintWithItem:self.aiv attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.view addConstraint:aivConstraintX];
    // self.aiv.centerY = self.view.centerY
    NSLayoutConstraint *aivConstraintY = [NSLayoutConstraint constraintWithItem:self.aiv attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.view addConstraint:aivConstraintY];
    
}

-(void)tapTitlebarButtonLeft {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)targetActionInit {
    [self.redSld addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.greenSld addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.blueSld addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.confirmBtn addTarget:self action:@selector(executePost) forControlEvents:UIControlEventTouchUpInside];
    [self.onOffSwh addTarget:self action:@selector(executeOnOff) forControlEvents:UIControlEventValueChanged];
}

-(void)sliderValueChanged:(UISlider *)slider {
    NSString *valueStr = [NSString stringWithFormat:@"%d",(int)slider.value];
    if (slider==self.redSld) {
        self.redLb.text = valueStr;
    } else if(slider==self.greenSld) {
        self.greenLb.text = valueStr;
    } else if(slider==self.blueSld) {
        self.blueLb.text = valueStr;
    }
    CGFloat colorRed = self.redSld.value / 255.0;
    CGFloat colorGreen = self.greenSld.value / 255.0;
    CGFloat colorBlue = self.blueSld.value / 255.0;
    UIColor *color = [UIColor colorWithRed:colorRed green:colorGreen blue:colorBlue alpha:1.0];
    self.colorboard.backgroundColor = color;
}

-(void)updateColorboardSldLb {
    ESPStatusLight *statusUi = self.deviceLight.espStatusLight;
    // update slider
    self.redSld.value = statusUi.espRed;
    self.greenSld.value = statusUi.espGreen;
    self.blueSld.value = statusUi.espBlue;
    // update label
    self.redLb.text = [NSString stringWithFormat:@"%d",statusUi.espRed];
    self.greenLb.text = [NSString stringWithFormat:@"%d",statusUi.espGreen];
    self.blueLb.text = [NSString stringWithFormat:@"%d",statusUi.espBlue];
    // update colorboard
    CGFloat colorRed = statusUi.espRed / 255.0;
    CGFloat colorGreen = statusUi.espGreen / 255.0;
    CGFloat colorBlue = statusUi.espBlue / 255.0;
    UIColor *color = [UIColor colorWithRed:colorRed green:colorGreen blue:colorBlue alpha:1.0];
    self.colorboard.backgroundColor = color;
}

-(void)updateOnOffSwh {
    if ([self isLightProtocolNew]) {
        if (self.deviceLight.espStatusLight.espStatus!=ESP_STATUS_LIGHT_OFF) {
            self.onOffSwh.on = YES;
        } else {
            self.onOffSwh.on = NO;
        }
    }
}

-(ESPStatusLight *)resolveColorboard {
    ESPStatusLight *statusUi = [[ESPStatusLight alloc]init];
    statusUi.espRed = self.redSld.value;
    statusUi.espGreen = self.greenSld.value;
    statusUi.espBlue = self.blueSld.value;
    statusUi.espPeriod = self.deviceLight.espStatusLight.espPeriod;
    statusUi.espCwhite = 0;
    statusUi.espWwhite = 0;
    return statusUi;
}

- (void) startAivAnimating
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = NO;
        [self.aiv startAnimating];
    });
}

- (void) stopAivAnimating
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = YES;
        [self.aiv stopAnimating];
    });
}

-(void)viewDidLoad {
    [self viewInit];
    [self targetActionInit];
    [self executeGet];
}

-(void)executeGet {
    // start aiv
    [self startAivAnimating];
    // do action background
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        ESPUser *user = [ESPUser sharedUser];
        BOOL result = [user doActionGetDeviceStatusDevice:self.deviceLight];
#ifdef DEBUG
        NSLog(@"%@ %@ %@",[self class],NSStringFromSelector(_cmd),result?@"SUC":@"FAIL");
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            // stop aiv
            [self stopAivAnimating];
            [self updateColorboardSldLb];
            [self updateOnOffSwh];
        });
    });
}

-(void)executePost {
    // start aiv
    [self startAivAnimating];
    __block ESPStatusLight *statusDevice = [self resolveColorboard];
    // do action background
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // only support color at present for new light protocol
        if([self isLightProtocolNew])
        {
            statusDevice.espStatus = ESP_STATUS_LIGHT_COLOR;
        }
        
        ESPUser *user = [ESPUser sharedUser];
        BOOL result = [user doActionPostDeviceStatusDevice:self.deviceLight Status:statusDevice];
#ifdef DEBUG
        NSLog(@"%@ %@ %@",[self class],NSStringFromSelector(_cmd),result?@"SUC":@"FAIL");
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            // stop aiv
            [self stopAivAnimating];
            [self updateColorboardSldLb];
            // update onOffSwh if necessary
            if(result){
                self.onOffSwh.on = YES;
            }
        });
    });
}

-(void)executeOnOff {
    NSAssert([self isLightProtocolNew], @"executeOnOff only support new protocol light");
    // start aiv
    [self startAivAnimating];
    __block ESPStatusLight *statusDevice = [self.deviceLight.espStatusLight copy];
    if (statusDevice.espStatus!=ESP_STATUS_LIGHT_ON) {
        statusDevice.espStatus = ESP_STATUS_LIGHT_ON;
    } else {
        statusDevice.espStatus = ESP_STATUS_LIGHT_OFF;
    }
    // do action background
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        ESPUser *user = [ESPUser sharedUser];
        __block BOOL result = [user doActionPostDeviceStatusDevice:self.deviceLight Status:statusDevice];
#ifdef DEBUG
        NSLog(@"%@ %@ %@",[self class],NSStringFromSelector(_cmd),result?@"SUC":@"FAIL");
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            // stop aiv
            [self stopAivAnimating];
            [self updateColorboardSldLb];
            // update onOffSwh if necessary
            if (!result) {
                self.onOffSwh.on = !self.onOffSwh.isOn;
            }
        });
    });
}

#pragma -mark menu
#define ESP_MENU_ID_UPGRADING_LOCAL     0
#define ESP_MENU_ID_UPGRADING_INTERNET  1
- (BOOL)addMenuItems:(AFXMenu *)menu {
    menu.afxParentViewController = self;
    menu.afxDelegate = self;
    NSString *romVerCur = self.deviceLight.espRomVersionCurrent;
    NSString *romVerLat = self.deviceLight.espRomVersionLatest;
    BOOL isOwner = self.deviceLight.espIsOwner;
    if (isOwner && romVerLat!=nil && ![romVerLat isEqualToString:romVerCur]) {
        if (self.deviceLight.espDeviceState.isStateLocal) {
            AFXMenuItem *menuItem = [[AFXMenuItem alloc]init];
            menuItem.afxMenuItemId = ESP_MENU_ID_UPGRADING_LOCAL;
            menuItem.afxMenuItemTitle = [NSString stringWithFormat:@"Upgrading Local to %@",romVerLat];
            [menu addMenuItem:menuItem];
        }
        if (self.deviceLight.espDeviceState.isStateInternet) {
            AFXMenuItem *menuItem = [[AFXMenuItem alloc]init];
            menuItem.afxMenuItemId = ESP_MENU_ID_UPGRADING_INTERNET;
            menuItem.afxMenuItemTitle = [NSString stringWithFormat:@"Upgrading Internet to %@",romVerLat];
            [menu addMenuItem:menuItem];
        }
        return YES;
    } else {
        return NO;
    }
}
-(void)menuItemSelected:(AFXMenuItem*)menuItem {
    switch (menuItem.afxMenuItemId) {
        case ESP_MENU_ID_UPGRADING_LOCAL:
            [self menuItemActionUpgradeLocal];
            break;
        case ESP_MENU_ID_UPGRADING_INTERNET:
            [self menuItemActionUpgradeInternet];
            break;
    }
}

-(void)menuItemActionUpgradeLocal {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        ESPUser *user = [ESPUser sharedUser];
        [user doActionUpgradeDeviceLocal:self.deviceLight];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)menuItemActionUpgradeInternet {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        ESPUser *user = [ESPUser sharedUser];
        [user doActionUpgradeDeviceInternet:self.deviceLight];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end