
//
//  ESPEsptouchViewController.m
//  suite
//
//  Created by 白 桦 on 7/5/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPEsptouchViewController.h"

#import "ESPUITextField.h"
#import "ESPUICheckBox.h"
#import "ESPWifi.h"
#import "ESPUser.h"
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESPConstantsNotification.h"
#import "ESPBssidUtil.h"
#import "ESPUIAlertView.h"
#import "DEspApManager.h"
#import "ESPGlobalTaskHandler.h"

/**
 *       ------------------
 *       | 111111111111111 |
 *       | 222  3333333333 |
 *       | 444444444444444 |
 *       | 55  6666        |
 *       | 77  8888        |
 *       | 99  aaaa        |
 *       | bb  cccc        |
 *       | dddddddd        |
 *       |                 |
 *       |                 |
 *       -------------------
 *
 *       1. titlebar
 *       2. ssidTitleLb
 *       3. ssidLb
 *       4. pwdTf
 *       5. pwdShowCb
 *       6. pwdShowLb
 *       7. ssidHiddenCb
 *       8. ssidHiddenLb
 *       9. multiDevCb
 *       a. multiDevLb
 *       b. activateCb
 *       c. activateLb
 *       d. confirmBtn
 *
 *       titlebar:
 *       ------------------
 *       |ee             ff|
 *       -------------------
 * 
 *       e. afxTitlebarLeftBtn
 *       f. afxTitlebarRightBtn
 */
@interface ESPEsptouchViewController ()

@property (nonatomic, strong) UILabel *ssidLb;
@property (nonatomic, strong) UITextField *pwdTf;
@property (nonatomic, strong) ESPUICheckBox *pwdShowCb;
@property (nonatomic, strong) ESPUICheckBox *ssidHiddenCb;
@property (nonatomic, strong) ESPUICheckBox *multiDevCb;
@property (nonatomic, strong) ESPUICheckBox *activateCb;
@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, strong) ESPUIAlertView *alertView;
@property (nonatomic, strong) UIAlertView *alertViewResult;
@property (nonatomic, strong) UIActivityIndicatorView *aiv;

// devices's bssid which is configured to the wifi
@property (nonatomic, strong) NSMutableArray *devicesLocalBssid;
// devices's which is configured to the server
@property (nonatomic, strong) NSMutableArray *devicesInternet;

@end

@implementation ESPEsptouchViewController

- (void)viewInit {
    // set background white
    self.view.backgroundColor = [UIColor whiteColor];
    
    // titlebar
    UINavigationBar *titlebar = [[UINavigationBar alloc]init];
    titlebar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titlebar];
    
    // titlebar.leading = self.view.leading
    NSLayoutConstraint *titlebarConstraintX = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:titlebarConstraintX];
    // titlebar.top = self.view.top + 20.0
    NSLayoutConstraint *titlebarConstraintY = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0];
    [self.view addConstraint:titlebarConstraintY];
    // titlebar.width = self.view.width
    NSLayoutConstraint *titlebarConstraintWidth = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:titlebarConstraintWidth];
    // titlebar.height = 44.0
    NSLayoutConstraint *titlebarConstraintHeight = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:44.0];
    [self.view addConstraint:titlebarConstraintHeight];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    navigationItem.title = @"IOT Espressif";
    
    // titlebar left
    UIBarButtonItem *titlebarItemLeft = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(tapTitleBarButtonLeft)];
    navigationItem.leftBarButtonItem = titlebarItemLeft;
    
    // titlebar right: menu
    AFXMenu *menu = [[AFXMenu alloc]init];
    if([self addMenuItems:menu]) {
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
    
    // ssidTitleLb
    UILabel *ssidTitleLb = [[UILabel alloc]init];
    ssidTitleLb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:ssidTitleLb];
    
    // ssidTitleLb.leading = self.view.leading + 30.0
    NSLayoutConstraint *ssidTitleLbConstraintX = [NSLayoutConstraint constraintWithItem:ssidTitleLb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:30.0];
    [self.view addConstraint:ssidTitleLbConstraintX];
    
    // ssidTitleLb.top = titlebar.bottom + 30.0
    NSLayoutConstraint *ssidTitleLbConstraintY = [NSLayoutConstraint constraintWithItem:ssidTitleLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titlebar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30.0];
    [self.view addConstraint:ssidTitleLbConstraintY];
    
    // ssidTitleLb.width = (self.view.width - 60.0) * 0.3 = 0.3*self.view.width - 18.0
    NSLayoutConstraint *ssidTitleLbConstraintWidth = [NSLayoutConstraint constraintWithItem:ssidTitleLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.3 constant:-18.0];
    [self.view addConstraint:ssidTitleLbConstraintWidth];
    
    // ssidTitleLb.height = 30.0
    NSLayoutConstraint *ssidTitleLbConstraintHeight = [NSLayoutConstraint constraintWithItem:ssidTitleLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:30.0];
    [self.view addConstraint:ssidTitleLbConstraintHeight];
    ssidTitleLb.text = @"ssid:";
    
    // ssidLb
    UILabel *ssidLb = [[UILabel alloc]init];
    ssidLb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:ssidLb];
    
    // ssidLb.trailing = self.view.trailing - 30.0
    NSLayoutConstraint *ssidLbConstraintX = [NSLayoutConstraint constraintWithItem:ssidLb attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-30.0];
    [self.view addConstraint:ssidLbConstraintX];
    // ssidLb.top = ssidTitleLb.top
    NSLayoutConstraint *ssidLbConstraintY = [NSLayoutConstraint constraintWithItem:ssidLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:ssidTitleLb attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:ssidLbConstraintY];
    // ssidLb.width = (self.view.width - 60.0) * 0.6 = 0.6*self.view.wdith - 36.0
    NSLayoutConstraint *ssidLbConstraintWidth = [NSLayoutConstraint constraintWithItem:ssidLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.6 constant:-36.0];
    [self.view addConstraint:ssidLbConstraintWidth];
    // ssidLb.height = ssidTitleLb.height
    NSLayoutConstraint *ssidLbConstraintHeight = [NSLayoutConstraint constraintWithItem:ssidLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:ssidTitleLb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:ssidLbConstraintHeight];
    
//    ssidLb.text = @"wifi-1";
    _ssidLb = ssidLb;
    
    // pwdTf
    ESPUITextField *pwdTf = [[ESPUITextField alloc]init];
    pwdTf.translatesAutoresizingMaskIntoConstraints = NO;
    pwdTf.placeholder = @"Please input password...";
    pwdTf.keyboardType = UIKeyboardTypeASCIICapable;
    pwdTf.secureTextEntry = YES;
    [self.view addSubview:pwdTf];
    
    // pwdTf.leading = ssidTitleLb.leading
    NSLayoutConstraint *pwdTfConstraintX = [NSLayoutConstraint constraintWithItem:pwdTf attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:ssidTitleLb attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:pwdTfConstraintX];
    // pwdTf.top = ssidTitleLb.bottom + 30.0
    NSLayoutConstraint *pwdTfConstraintY = [NSLayoutConstraint constraintWithItem:pwdTf attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:ssidTitleLb attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30.0];
    [self.view addConstraint:pwdTfConstraintY];
    // pwdTf.width = self.view.width - 30.0 * 2 = self.view.width - 60.0
    NSLayoutConstraint *pwdTfConstraintWidth = [NSLayoutConstraint constraintWithItem:pwdTf attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-60.0];
    [self.view addConstraint:pwdTfConstraintWidth];
    // pwdTf.height = ssidTitleLb.height
    NSLayoutConstraint *pwdTfConstraintHeight = [NSLayoutConstraint constraintWithItem:pwdTf attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:ssidTitleLb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:pwdTfConstraintHeight];
    
    _pwdTf = pwdTf;
    
    // pwdShowCb
    // ESPUICheckBox don't adapt to autolayout mechanism thoroughly at present,so CGRectNull will give you a surprise
    ESPUICheckBox *pwdShowCb = [[ESPUICheckBox alloc]initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
    pwdShowCb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pwdShowCb];
    
    // pwdShowCb.leading = ssidTitleLb.leading
    NSLayoutConstraint *pwdShowCbConstraintX = [NSLayoutConstraint constraintWithItem:pwdShowCb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:ssidTitleLb attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:pwdShowCbConstraintX];
    // pwdShowCb.top = pwdTf.bottom + 30.0
    NSLayoutConstraint *pwdShowCbConstraintY = [NSLayoutConstraint constraintWithItem:pwdShowCb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:pwdTf attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30.0];
    [self.view addConstraint:pwdShowCbConstraintY];
    // pwdShowCb.width = 30.0
    NSLayoutConstraint *pwdShowCbConstraintWidth = [NSLayoutConstraint constraintWithItem:pwdShowCb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:30.0];
    [self.view addConstraint:pwdShowCbConstraintWidth];
    // pwdShowCb.height = pwdShowCb.width
    NSLayoutConstraint *pwdShowCbConstraintHeight = [NSLayoutConstraint constraintWithItem:pwdShowCb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:pwdShowCb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:pwdShowCbConstraintHeight];
    
    _pwdShowCb = pwdShowCb;
    
    // pwdShowLb
    UILabel *pwdShowLb = [[UILabel alloc]init];
    pwdShowLb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pwdShowLb];
    
    // pwdShowLb.leading = pwdShowCb.trailing + 8.0
    NSLayoutConstraint *pwdShowLbConstraintX = [NSLayoutConstraint constraintWithItem:pwdShowLb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:pwdShowCb attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0];
    [self.view addConstraint:pwdShowLbConstraintX];
    // pwdShowLb.top = pwdShowCb.top
    NSLayoutConstraint *pwdShowLbConstraintY = [NSLayoutConstraint constraintWithItem:pwdShowLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:pwdShowCb attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:pwdShowLbConstraintY];
    // pwdShowLb.width >= 0
    NSLayoutConstraint *pwdShowLbConstraintWidth = [NSLayoutConstraint constraintWithItem:pwdShowLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
    [self.view addConstraint:pwdShowLbConstraintWidth];
    // pwdShowLb.height >= pwdShowCb.height
    NSLayoutConstraint *pwdShowLbConstraintHeight = [NSLayoutConstraint constraintWithItem:pwdShowLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:pwdShowCb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:pwdShowLbConstraintHeight];
    
    pwdShowLb.text = @"show password";
    
    // ssidHiddenCb
    // ESPUICheckBox don't adapt to autolayout mechanism thoroughly at present,so CGRectNull will give you a surprise
    ESPUICheckBox *ssidHiddenCb = [[ESPUICheckBox alloc]initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
    ssidHiddenCb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:ssidHiddenCb];
    
    // ssidHiddenCb.leading = ssidTitleLb.leading
    NSLayoutConstraint *ssidHiddenCbConstraintX = [NSLayoutConstraint constraintWithItem:ssidHiddenCb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:ssidTitleLb attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:ssidHiddenCbConstraintX];
    // ssidHiddenCb.top = pwdShowLb.bottom + 30.0
    NSLayoutConstraint *ssidHiddenCbConstraintY = [NSLayoutConstraint constraintWithItem:ssidHiddenCb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:pwdShowLb attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30.0];
    [self.view addConstraint:ssidHiddenCbConstraintY];
    // ssidHiddenCb.width = pwdShowCb.width
    NSLayoutConstraint *ssidHiddenCbConstraintWidth = [NSLayoutConstraint constraintWithItem:ssidHiddenCb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:pwdShowCb attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:ssidHiddenCbConstraintWidth];
    // ssidHiddenCb.height = pwdShowCb.height
    NSLayoutConstraint *ssidHiddenCbConstraintHeight = [NSLayoutConstraint constraintWithItem:ssidHiddenCb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:pwdShowCb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:ssidHiddenCbConstraintHeight];
    
    _ssidHiddenCb = ssidHiddenCb;
    
    // ssidHiddenLb
    UILabel *ssidHiddenLb = [[UILabel alloc]init];
    ssidHiddenLb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:ssidHiddenLb];
    
    // ssidHiddenLb.leading = pwdShowLb.leading
    NSLayoutConstraint *ssidHiddenLbConstraintX = [NSLayoutConstraint constraintWithItem:ssidHiddenLb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:pwdShowLb attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:ssidHiddenLbConstraintX];
    // ssidHiddenLb.top = ssidHiddenCb.top
    NSLayoutConstraint *ssidHiddenLbConstraintY = [NSLayoutConstraint constraintWithItem:ssidHiddenLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:ssidHiddenCb attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:ssidHiddenLbConstraintY];
    // ssidHiddenLb.width >= 0
    NSLayoutConstraint *ssidHiddenLbConstraintWidth = [NSLayoutConstraint constraintWithItem:ssidHiddenLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
    [self.view addConstraint:ssidHiddenLbConstraintWidth];
    // ssidHiddenLb.height >= ssidHiddenCb.height
    NSLayoutConstraint *ssidHiddenLbConstraintHeight = [NSLayoutConstraint constraintWithItem:ssidHiddenLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:ssidHiddenCb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:ssidHiddenLbConstraintHeight];
    
    ssidHiddenLb.text = @"is ssid hidden";
    
    // multiDevCb
    // ESPUICheckBox don't adapt to autolayout mechanism thoroughly at present,so CGRectNull will give you a surprise
    ESPUICheckBox *multiDevCb = [[ESPUICheckBox alloc]initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
    multiDevCb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:multiDevCb];
    
    // multiDevCb.leading = ssidTitleLb.leading
    NSLayoutConstraint *multiDevCbConstraintX = [NSLayoutConstraint constraintWithItem:multiDevCb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:ssidTitleLb attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:multiDevCbConstraintX];
    // multiDevCb.top = ssidHiddenLb.bottom + 30.0
    NSLayoutConstraint *multiDevCbConstraintY = [NSLayoutConstraint constraintWithItem:multiDevCb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:ssidHiddenLb attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30.0];
    [self.view addConstraint:multiDevCbConstraintY];
    // multiDevCb.width = pwdShowCb.width
    NSLayoutConstraint *multiDevCbConstraintWidth = [NSLayoutConstraint constraintWithItem:multiDevCb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:pwdShowCb attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:multiDevCbConstraintWidth];
    // multiDevCb.height = pwdShowCb.height
    NSLayoutConstraint *multiDevCbConstraintHeight = [NSLayoutConstraint constraintWithItem:multiDevCb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:pwdShowCb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:multiDevCbConstraintHeight];
    
    _multiDevCb = multiDevCb;
    
    // multiDevLb
    UILabel *multiDevLb = [[UILabel alloc]init];
    multiDevLb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:multiDevLb];
    
    // multiDevLb.leading = pwdShowLb.leading
    NSLayoutConstraint *multiDevLbConstraintX = [NSLayoutConstraint constraintWithItem:multiDevLb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:pwdShowLb attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:multiDevLbConstraintX];
    // multiDevLb.top = multiDevCb.top
    NSLayoutConstraint *multiDevLbConstraintY = [NSLayoutConstraint constraintWithItem:multiDevLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:multiDevCb attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:multiDevLbConstraintY];
    // multiDevLb.width >= 0
    NSLayoutConstraint *multiDevLbConstraintWidth = [NSLayoutConstraint constraintWithItem:multiDevLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
    [self.view addConstraint:multiDevLbConstraintWidth];
    // multiDevLb.height >= multiDevCb.height
    NSLayoutConstraint *multiDevLbConstraintHeight = [NSLayoutConstraint constraintWithItem:multiDevLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:multiDevCb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:multiDevLbConstraintHeight];
    
    multiDevLb.text = @"multiple devices";
    
    // activateCb
    // ESPUICheckBox don't adapt to autolayout mechanism thoroughly at present,so CGRectNull will give you a surprise
    ESPUICheckBox *activateCb = [[ESPUICheckBox alloc]initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
    activateCb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:activateCb];
    
    // activateCb.leading = ssidTitleLb.leading
    NSLayoutConstraint *activateCbConstraintX = [NSLayoutConstraint constraintWithItem:activateCb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:ssidTitleLb attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:activateCbConstraintX];
    // activateCb.top = multiDevLb.bottom + 30.0
    NSLayoutConstraint *activateCbConstraintY = [NSLayoutConstraint constraintWithItem:activateCb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:multiDevLb attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30.0];
    [self.view addConstraint:activateCbConstraintY];
    // activateCb.width = pwdShowCb.width
    NSLayoutConstraint *activateCbConstraintWidth = [NSLayoutConstraint constraintWithItem:activateCb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:pwdShowCb attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:activateCbConstraintWidth];
    // activateCb.height = pwdShowCb.height
    NSLayoutConstraint *activateCbConstraintHeight = [NSLayoutConstraint constraintWithItem:activateCb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:pwdShowCb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:activateCbConstraintHeight];
    
    // activateLb
    UILabel *activateLb = [[UILabel alloc]init];
    activateLb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:activateLb];
    
    // activateLb.leading = pwdShowLb.leading
    NSLayoutConstraint *activateLbConstraintX = [NSLayoutConstraint constraintWithItem:activateLb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:pwdShowLb attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:activateLbConstraintX];
    // activateLb.top = activateCb.top
    NSLayoutConstraint *activateLbConstraintY = [NSLayoutConstraint constraintWithItem:activateLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:activateCb attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:activateLbConstraintY];
    // activateLb.width >= 0
    NSLayoutConstraint *activateLbConstraintWidth = [NSLayoutConstraint constraintWithItem:activateLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
    [self.view addConstraint:activateLbConstraintWidth];
    // activateLb.height >= activateCb.height
    NSLayoutConstraint *activateLbConstraintHeight = [NSLayoutConstraint constraintWithItem:activateLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:activateCb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:activateLbConstraintHeight];
    
    activateLb.text = @"activate device on server";
    
    _activateCb = activateCb;
    
    // check whether is logined
    UIView *lastLb = activateLb;
    ESPUser *user = [ESPUser sharedUser];
    if (!user.espIsLogined) {
        activateLb.hidden = YES;
        activateCb.hidden = YES;
        lastLb = multiDevLb;
    }
    
    // confirmBtn
    UIButton *confirmBtn = [[UIButton alloc]init];
    confirmBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:confirmBtn];
    
    [confirmBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:255.0 alpha:0.4] forState:UIControlStateHighlighted];
    [confirmBtn setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5] forState:UIControlStateDisabled];
    confirmBtn.layer.borderColor = [[UIColor blueColor] CGColor];
    confirmBtn.layer.borderWidth = 1.0f;
    confirmBtn.layer.cornerRadius = 8.0f;
    confirmBtn.layer.masksToBounds = YES;
    
    // confirmBtn.centerX = self.view.trailing * 0.5 * (1-0.35) = self.view.trainling * 0.325
    NSLayoutConstraint *confirmBtnConstraintX = [NSLayoutConstraint constraintWithItem:confirmBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:0.325 constant:0.0];
    [self.view addConstraint:confirmBtnConstraintX];
    // confirmBtn.top = lastLb.bottom + 30.0
    NSLayoutConstraint *confirmBtnConstraintY = [NSLayoutConstraint constraintWithItem:confirmBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastLb attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30.0];
    [self.view addConstraint:confirmBtnConstraintY];
    // confirmBtn.width = self.view.width * 0.35
    NSLayoutConstraint *confirmBtnConstraintWidth = [NSLayoutConstraint constraintWithItem:confirmBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.35 constant:0.0];
    [self.view addConstraint:confirmBtnConstraintWidth];
    // confirmBtn.height = 30.0
    NSLayoutConstraint *confirmBtnConstraintHeight = [NSLayoutConstraint constraintWithItem:confirmBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:30.0];
    [self.view addConstraint:confirmBtnConstraintHeight];
    
    _confirmBtn = confirmBtn;
    
}

- (void) alertIndicatorViewInit {
    self.alertView = [[ESPUIAlertView alloc]init];
    
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

- (void) showAlertViewTitle:(NSString *)title Message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ESPUIAlertView *alertView = self.alertView;
        alertView.espTitle = title;
        alertView.espMessage = message;
        [alertView showTimeInterval:kEspUIAlertViewLongTimeInterval Instant:NO];
    });
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
    [self alertIndicatorViewInit];
    [self updateWifi];
    [self targetActionInit];
}

- (void)test {
    self.view.backgroundColor = [UIColor whiteColor];
    AFXMenu *menu = [[AFXMenu alloc]initWithFrame:CGRectMake(100, 100, 50, 100)];
    [self.view addSubview:menu];
    menu.afxMenuTitle = @"Menu";
    AFXMenuItem *menuItem = [[AFXMenuItem alloc]init];
    menuItem.afxMenuItemId = 0;
    menuItem.afxMenuItemTitle = @"Sharing";
    [menu addMenuItem:menuItem];
    menu.afxParentViewController = self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _devicesLocalBssid = [[NSMutableArray alloc]init];
        _devicesInternet = [[NSMutableArray alloc]init];
        [self registerNotification];
    }
    return self;
}

- (void)dealloc {
    [self unregisterNotification];
}

- (void)registerNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateWifi) name:UIApplicationWillEnterForegroundNotification object:nil];
    [center addObserver:self selector:@selector(contactServer) name:ESPTOUCH_CONTACTING_SERVER object:nil];
    [center addObserver:self selector:@selector(registerDevices) name:ESPTOUCH_REGISTER_DEVICES object:nil];
    [center addObserver:self selector:@selector(newDeviceAdd:) name:ESPTOUCH_ADD_NEW_DEVICE object:nil];
}

- (void)unregisterNotification {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)updateWifi {
    ESPWifi *wifi = [ESPWifi sharedWifi];
    [wifi update];
    if (wifi.espIsSsidExist) {
        self.ssidLb.text = wifi.espSsid;
        [self loadDaoAp:wifi.espBssid];
        self.confirmBtn.enabled = YES;
        self.confirmBtn.layer.borderColor = [[UIColor blueColor] CGColor];
        self.confirmBtn.layer.borderWidth = 1.0f;
        self.confirmBtn.layer.cornerRadius = 8.0f;
        self.confirmBtn.layer.masksToBounds = YES;
    } else {
        self.ssidLb.text = @"";
        self.confirmBtn.enabled = NO;
        self.confirmBtn.layer.borderColor = [[UIColor grayColor] CGColor];
        self.confirmBtn.layer.borderWidth = 1.0f;
        self.confirmBtn.layer.cornerRadius = 8.0f;
        self.confirmBtn.layer.masksToBounds = YES;
    }
}

- (void)contactServer {
    NSString *title = @"Add Device";
    NSString *message = @"contacting the server...";
    [self showAlertViewTitle:title Message:message];
}

- (void)registerDevices {
    NSString *title = @"Add Device";
    NSString *message = @"registering the devices...";
    [self showAlertViewTitle:title Message:message];
}

- (void)newDeviceAdd:(NSNotification *)notification
{
    ESPDevice *newDevice = [notification object];
    if (![self.devicesInternet containsObject:newDevice]) {
        [self.devicesInternet addObject:newDevice];
    }
    NSString *title = @"Add Device";
    NSString *deviceName = newDevice.espDeviceName;
    NSString *message = [NSString stringWithFormat:@"%@ is connected to server",deviceName];
    [self showAlertViewTitle:title Message:message];
}

- (void)targetActionInit {
    
    [self.pwdTf addTarget:self action:@selector(editOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.pwdShowCb addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmBtn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    
    // hide soft-keyboard when touch background
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)editOnExit:(id) sender {
    if (sender==self.pwdTf) {
        [self pwdTfOnExit];
    }
}

- (void)pwdTfOnExit {
    [self.pwdTf resignFirstResponder];
}

- (void)tap:(id) sender {
    if (sender==self.pwdShowCb) {
        [self tapPwdShowCb];
    } else if(sender==self.confirmBtn) {
        [self tapConfirmBtn];
    }
}

- (void)tapPwdShowCb {
    self.pwdTf.secureTextEntry = !self.pwdShowCb.isChecked;
}

- (void)showAddDevicesResult {
    dispatch_async(dispatch_get_main_queue(), ^{
        ESPUser *user = [ESPUser sharedUser];
        NSString *title = @"Add Devices Result";
        NSMutableString *mstr = [[NSMutableString alloc]init];
        // remove devices both in local and internet
        for (NSUInteger i=0; i<self.devicesLocalBssid.count; ++i) {
            NSString *bssid = self.devicesLocalBssid[i];
            for (NSUInteger j=0; j<self.devicesInternet.count; ++j) {
                ESPDevice *device = self.devicesInternet[j];
                NSString *deviceBssid = device.espBssid;
                if ([bssid isEqualToString:deviceBssid]) {
                    [self.devicesLocalBssid removeObjectAtIndex:i--];
                }
            }
        }
        // add local device result
        if (self.devicesLocalBssid.count>0) {
            [mstr appendString:@"Local Devices:\n"];
            for (NSUInteger i=0; i<self.devicesLocalBssid.count; ++i) {
                NSString *bssid = self.devicesLocalBssid[i];
                NSString *deviceName = [ESPBssidUtil genDeviceNameByBssid:bssid];
                if (i!=0) {
                    [mstr appendString:@","];
                }
                [mstr appendString:deviceName];
            }
            [mstr appendString:@"\n"];
        }
        // add internet device result
        if (self.devicesInternet.count>0) {
            [mstr appendString:@"Internet Devices:\n"];
            for (NSUInteger i=0; i<self.devicesInternet.count; ++i) {
                ESPDevice *device = self.devicesInternet[i];
                // add device internet in user
                [user addDeviceInternet:device];
                NSString *deviceName = device.espDeviceName;
                if (i!=0) {
                    [mstr appendString:@","];
                }
                [mstr appendString:deviceName];
            }
            [mstr appendString:@"\n"];
        }
        NSString *message = mstr.length > 0 ? mstr:@"No Devices are added";
        self.alertViewResult = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"I know" otherButtonTitles:nil];
        [self.alertViewResult show];
        
        // notify devices arrive if necessary
        if (self.devicesInternet.count>0) {
            [user notifyDevicesArrive];
        }
        
        // do refresh
        [user doActionRefreshAllDevices:NO];
    });
}

-(void)saveApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPwd:(NSString *)apPwd
{
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        DEspApManager *apManager = [DEspApManager sharedApManager];
        DaoEspAp *daoAp = [[DaoEspAp alloc]init];
        daoAp.espApSsid = apSsid;
        daoAp.espApBssid = apBssid;
        daoAp.espApPwd = apPwd;
        [apManager insertOrUpdate:daoAp];
    };
    
    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    [handler submit:task];
}

-(void)loadDaoAp:(NSString *)apBssid
{
    DEspApManager *apManager = [DEspApManager sharedApManager];
    DaoEspAp *daoAp = [apManager queryByBssid:apBssid];
    self.pwdTf.text = daoAp==nil ? @"" : daoAp.espApPwd;
}

// UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.alertViewResult dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapConfirmBtn {
    ESPUser *user = [ESPUser sharedUser];
    ESPWifi *wifi = [ESPWifi sharedWifi];
    NSString *apSsid = wifi.espSsid;
    NSString *apBssid = wifi.espBssid;
    NSString *apPassword = self.pwdTf.text;
    
    // save password in local database
    [self saveApSsid:apSsid ApBssid:apBssid ApPwd:apPassword];
    
    BOOL isSsidHidden = self.ssidHiddenCb.isChecked;
    BOOL requitedActivate = self.activateCb.isChecked;
    BOOL isMultiDevices = self.multiDevCb.isChecked;

//    NSLog(@"%@ %@ ssid:%@,bssid:%@,pwd:%@,isSsidHidden:%@,requiredActivate:%@,isMultiDevices:%@",self.class,NSStringFromSelector(_cmd),apSsid,apBssid,apPassword,isSsidHidden?@"YES":@"NO",requitedActivate?@"YES":@"NO",isMultiDevices?@"YES":@"NO");
    
    [self startAivAnimating];
    [self.devicesLocalBssid removeAllObjects];
    [self.devicesInternet removeAllObjects];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if (isMultiDevices) {
            [user addDevicesSyncApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden RequiredActivate:requitedActivate Delegate:self];
        } else {
            [user addDeviceSyncApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden RequiredActivate:requitedActivate Delegate:self];
        }
        [self stopAivAnimating];
        [self showAddDevicesResult];
    });
}

// implement ESPTouchDelegate
-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result {
    NSString *title = @"Add Device";
    NSString *bssid = [ESPBssidUtil restoreBssid:result.bssid];
    if (![self.devicesLocalBssid containsObject:bssid]) {
        [self.devicesLocalBssid addObject:bssid];
    }
    NSString *deviceName = [ESPBssidUtil genDeviceNameByBssid:bssid];
    NSString *message = [NSString stringWithFormat:@"%@ is added into wifi",deviceName];
    [self showAlertViewTitle:title Message:message];
}

- (void)tapView {
    [self.view endEditing:YES];
}

- (void)tapTitleBarButtonLeft {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark menu
#define ESP_MENU_ID_SHARING     0
- (BOOL)addMenuItems:(AFXMenu *)menu {
    menu.afxParentViewController = self;
    menu.afxDelegate = self;
    AFXMenuItem *menuItem = [[AFXMenuItem alloc]init];
    menuItem.afxMenuItemId = ESP_MENU_ID_SHARING;
    menuItem.afxMenuItemTitle = @"Sharing";
    [menu addMenuItem:menuItem];
    return NO;
}
-(void)menuItemSelected:(AFXMenuItem*)menuItem {
    switch (ESP_MENU_ID_SHARING) {
        case ESP_MENU_ID_SHARING:
            NSLog(@"%@ %@ sharing",[self class],NSStringFromSelector(_cmd));
            break;
    }
}

@end
