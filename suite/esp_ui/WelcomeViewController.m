//
//  WelcomeViewController.m
//  suite
//
//  Created by 白 桦 on 5/17/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ESPUICheckBox.h"
#import "ESPUITextField.h"
#import "ESPUIMacro.h"
#import "ESPUIUtil.h"
#import "ESPUser.h"
#import "ESPLoginResult.h"
#import "HZActivityIndicatorView.h"
#import "MainUIViewController.h"
#import "RegisterViewController.h"
#import "ESPStringUtil.h"
#import "ESPConfig.h"

/**
 *       ------------------
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       | 111111111111111 |
 *       | 222222222222222 |
 *       | 3 4444          |
 *       | 55555     66666 |
 *       | 77777           |
 *       | 88888           |
 *       -------------------
 *
 *       1: mailboxTf
 *       2: passwdTf
 *       3: autoLoginCb
 *       4: autoLoginLb
 *       5: loginBtn
 *       6: registerBtn
 *       7: quickUsageBtn
 *       8: versionLb
 */

#define ESP_VERSION @"v1.0.0"

@interface WelcomeViewController ()

@property (nonatomic, strong) ESPUITextField *mailboxTf;
@property (nonatomic, strong) ESPUITextField *passwdTf;
@property (nonatomic, strong) ESPUICheckBox *autoLoginCb;
@property (nonatomic, strong) UILabel *autoLoginLb;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *registerBtn;
@property (nonatomic, strong) UIButton *quickUsageBtn;

@end

@implementation WelcomeViewController

- (void)viewInit {
    // mailboxTf
    self.mailboxTf = [[ESPUITextField alloc]initWithFrame:CGRectNull];
    self.mailboxTf.translatesAutoresizingMaskIntoConstraints = NO;
    self.mailboxTf.placeholder = @"Please input email";
    self.mailboxTf.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:self.mailboxTf];
    
    // self.mailboxTf.centerX = self.view.centerX
    NSLayoutConstraint *mailboxTfConstraintX = [NSLayoutConstraint constraintWithItem:self.mailboxTf attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.view addConstraint:mailboxTfConstraintX];
    // self.mailboxTf.top = self.view.bottom * 0.4
    NSLayoutConstraint *mailboxTfConstraintY = [NSLayoutConstraint constraintWithItem:self.mailboxTf attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.4 constant:0.0];
    [self.view addConstraint:mailboxTfConstraintY];
    // self.mailboxTf.width = self.view.width * 0.8
    NSLayoutConstraint *mailboxTfConstraintWidth = [NSLayoutConstraint constraintWithItem:self.mailboxTf attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0.0];
    [self.view addConstraint:mailboxTfConstraintWidth];
    // self.mailboxTf.height = 30.0
    NSLayoutConstraint *mailboxTfConstraintHeight = [NSLayoutConstraint constraintWithItem:self.mailboxTf attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:30.0];
    [self.view addConstraint:mailboxTfConstraintHeight];
    
    
    // passwdTf
    self.passwdTf = [[ESPUITextField alloc]initWithFrame:CGRectNull];
    self.passwdTf.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwdTf.placeholder = @"Please input password";
    self.passwdTf.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwdTf.secureTextEntry = YES;
    [self.view addSubview:self.passwdTf];
    
    // self.passwdTf.centerX = self.view.centerX
    NSLayoutConstraint *passwdTfConstraintX = [NSLayoutConstraint constraintWithItem:self.passwdTf attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.view addConstraint:passwdTfConstraintX];
    // self.passwdTf.top = self.mailboxTf.bottom + 8
    NSLayoutConstraint *passwdTfConstraintY = [NSLayoutConstraint constraintWithItem:self.passwdTf attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    [self.view addConstraint:passwdTfConstraintY];
    // self.passwdTf.width = self.mailboxTf.width
    NSLayoutConstraint *passwdTfConstraintWidth = [NSLayoutConstraint constraintWithItem:self.passwdTf attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:passwdTfConstraintWidth];
    // self.passwdTf.height = self.mailboxTf.height
    NSLayoutConstraint *passwdTfConstraintHeight = [NSLayoutConstraint constraintWithItem:self.passwdTf attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:passwdTfConstraintHeight];
    
    // autoLoginCb
    // ESPUICheckBox don't adapt to autolayout mechanism thoroughly at present,so CGRectNull will give you a surprise
    self.autoLoginCb = [[ESPUICheckBox alloc]initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
    self.autoLoginCb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.autoLoginCb];
    
    // self.autoLoginCb.leading = self.mailboxTf.leading
    NSLayoutConstraint *autoLoginCbConstraintX = [NSLayoutConstraint constraintWithItem:self.autoLoginCb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:autoLoginCbConstraintX];
    // self.autoLoginCb.top = self.passwdTf.bottom + 8
    NSLayoutConstraint *autoLoginCbConstraintY = [NSLayoutConstraint constraintWithItem:self.autoLoginCb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwdTf attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    [self.view addConstraint:autoLoginCbConstraintY];
    // self.autoLoginCb.width = 30.0
    NSLayoutConstraint *autoLoginCbConstraintWidth = [NSLayoutConstraint constraintWithItem:self.autoLoginCb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:30.0];
    [self.view addConstraint:autoLoginCbConstraintWidth];
    // self.autoLoginCb.height = self.autoLoginCb.width
    NSLayoutConstraint *autoLoginCbConstraintHeight = [NSLayoutConstraint constraintWithItem:self.autoLoginCb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.autoLoginCb attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:autoLoginCbConstraintHeight];
    
    // autoLoginLb
    self.autoLoginLb = [[UILabel alloc]initWithFrame:CGRectNull];
    self.autoLoginLb.translatesAutoresizingMaskIntoConstraints = NO;
    self.autoLoginLb.text = @"Auto Login";
    [self.view addSubview:self.autoLoginLb];
    
    // self.autoLoginLb.leading = self.autoLoginCb.tailing + 8
    NSLayoutConstraint *autoLoginLbConstraintX = [NSLayoutConstraint constraintWithItem:self.autoLoginLb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.autoLoginCb attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0];
    [self.view addConstraint:autoLoginLbConstraintX];
    // self.autoLoginLb.top = self.autoLoginCb.top
    NSLayoutConstraint *autoLoginLbConstraintY = [NSLayoutConstraint constraintWithItem:self.autoLoginLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.autoLoginCb attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:autoLoginLbConstraintY];
    // self.autoLoginLb.width >= 0
    NSLayoutConstraint *autoLoginLbConstraintWidth = [NSLayoutConstraint constraintWithItem:self.autoLoginLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
    [self.view addConstraint:autoLoginLbConstraintWidth];
    // self.autoLoginLb.height >= self.autoLoginCb.height
    NSLayoutConstraint *autoLoginLbConstraintHeight = [NSLayoutConstraint constraintWithItem:self.autoLoginLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.autoLoginCb attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:autoLoginLbConstraintHeight];
    
    // loginBtn
    self.loginBtn = [[UIButton alloc]initWithFrame:CGRectNull];
    self.loginBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.loginBtn setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:255.0 alpha:0.4] forState:UIControlStateHighlighted];
    [self.view addSubview:self.loginBtn];
    self.loginBtn.layer.borderColor = [[UIColor blueColor] CGColor];
    self.loginBtn.layer.borderWidth = 1.0f;
    self.loginBtn.layer.cornerRadius = 8.0f;
    self.loginBtn.layer.masksToBounds = YES;
    
    // self.loginBtn.leading = self.mailboxTf.leading
    NSLayoutConstraint *loginBtnConstraintX = [NSLayoutConstraint constraintWithItem:self.loginBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:loginBtnConstraintX];
    // self.loginBtn.top = self.autoLoginLb.bottom + 8
    NSLayoutConstraint *loginBtnConstraintY = [NSLayoutConstraint constraintWithItem:self.loginBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.autoLoginLb attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    [self.view addConstraint:loginBtnConstraintY];
    // self.loginBtn.width = self.view.width * 0.35
    NSLayoutConstraint *loginBtnConstraintWidth = [NSLayoutConstraint constraintWithItem:self.loginBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.35 constant:0.0];
    [self.view addConstraint:loginBtnConstraintWidth];
    // self.loginBtn.height = 30
    NSLayoutConstraint *loginBtnConstraintHeight = [NSLayoutConstraint constraintWithItem:self.loginBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:30];
    [self.view addConstraint:loginBtnConstraintHeight];
    
    // registerBtn
    self.registerBtn = [[UIButton alloc]init];
    self.registerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.registerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.registerBtn setTitle:@"Register" forState:UIControlStateNormal];
    [self.registerBtn setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:255.0 alpha:0.4] forState:UIControlStateHighlighted];
    [self.view addSubview:self.registerBtn];
    self.registerBtn.layer.borderColor = [[UIColor blueColor] CGColor];
    self.registerBtn.layer.borderWidth = 1.0f;
    self.registerBtn.layer.cornerRadius = 8.0f;
    self.registerBtn.layer.masksToBounds = YES;
    
    // self.registerBtn.trailing = self.mailboxTf.trailing
    NSLayoutConstraint *registerBtnConstraintX = [NSLayoutConstraint constraintWithItem:self.registerBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:registerBtnConstraintX];
    // self.registerBtn.top = self.loginBtn.top
    NSLayoutConstraint *registerBtnConstraintY = [NSLayoutConstraint constraintWithItem:self.registerBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginBtn attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:registerBtnConstraintY];
    // self.registerBtn.width = self.loginBtn.width
    NSLayoutConstraint *registerBtnConstraintWidth = [NSLayoutConstraint constraintWithItem:self.registerBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.loginBtn attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:registerBtnConstraintWidth];
    // self.registerBtn.height = self.loginBtn.height
    NSLayoutConstraint *registerBtnConstraintHeight = [NSLayoutConstraint constraintWithItem:self.registerBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.loginBtn attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:registerBtnConstraintHeight];
    
    // quickUsageBtn
    self.quickUsageBtn = [[UIButton alloc]init];
    self.quickUsageBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.quickUsageBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.quickUsageBtn setTitle:@"QuickUsage" forState:UIControlStateNormal];
    [self.quickUsageBtn setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:255.0 alpha:0.4] forState:UIControlStateHighlighted];
    [self.view addSubview:self.quickUsageBtn];
    self.quickUsageBtn.layer.borderColor = [[UIColor blueColor] CGColor];
    self.quickUsageBtn.layer.borderWidth = 1.0f;
    self.quickUsageBtn.layer.cornerRadius = 8.0f;
    self.quickUsageBtn.layer.masksToBounds = YES;
    
    // self.quickUsageBtn.leading = self.mailboxTf.leading
    NSLayoutConstraint *quickUsageBtnConstraintX = [NSLayoutConstraint constraintWithItem:self.quickUsageBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:quickUsageBtnConstraintX];
    // self.quickUsageBtn.top = self.loginBtn.bottom + 8
    NSLayoutConstraint *quickUsageBtnConstraintY = [NSLayoutConstraint constraintWithItem:self.quickUsageBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginBtn attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    [self.view addConstraint:quickUsageBtnConstraintY];
    // self.quickUsageBtn.width = self.loginBtn.width
    NSLayoutConstraint *quickUsageBtnWidth = [NSLayoutConstraint constraintWithItem:self.quickUsageBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.loginBtn attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:quickUsageBtnWidth];
    // self.quickUsageBtn.height = self.loginBtn.height
    NSLayoutConstraint *quickUsageBtnHeight = [NSLayoutConstraint constraintWithItem:self.quickUsageBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.loginBtn attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:quickUsageBtnHeight];
    
    // versionLb
    UILabel *versionLb = [[UILabel alloc]init];
    versionLb.translatesAutoresizingMaskIntoConstraints = NO;
    versionLb.text = ESP_VERSION;
    [self.view addSubview:versionLb];
    
    // versionLb.trailing = self.mailboxTf.trailing
    NSLayoutConstraint *versionLbConstraintX = [NSLayoutConstraint constraintWithItem:versionLb attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:versionLbConstraintX];
    // versionLb.bottom = self.view.bottom * 0.8
    NSLayoutConstraint *versionLbConstraintY = [NSLayoutConstraint constraintWithItem:versionLb attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.9 constant:0.0];
    [self.view addConstraint:versionLbConstraintY];
    // versionLb.width >= 0
    NSLayoutConstraint *versionLbConstraintWidth = [NSLayoutConstraint constraintWithItem:versionLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
    [self.view addConstraint:versionLbConstraintWidth];
    // versionLb.height >= 0
    NSLayoutConstraint *versionLbConstraintHeight = [NSLayoutConstraint constraintWithItem:versionLb attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
    [self.view addConstraint:versionLbConstraintHeight];
}

- (void)targetActionInit
{
    [self.loginBtn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerBtn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self.quickUsageBtn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self.mailboxTf addTarget:self action:@selector(editOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwdTf addTarget:self action:@selector(editOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    // hide soft-keyboard when touch background
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tap:(id) sender
{
    if (sender==self.loginBtn) {
        [self tapLoginBtnAction];
    } else if (sender==self.registerBtn) {
        [self tapRegisterBtnAction];
    } else if (sender==self.quickUsageBtn) {
        [self tapQuickUsageBtnAction];
    }
    else if (sender==self.view) {
        [self tapView];
    }
}

- (void)editOnExit:(id) sender
{
    if (sender==self.mailboxTf) {
        [self editMailboxOnExit];
    } else if (sender==self.passwdTf) {
        [self editPasswordOnExit];
    }
}

- (void)tapView
{
    [self.view endEditing:YES];
}

- (void)tapQuickUsageBtnAction
{
    // hide soft-keyboard
    [self editMailboxOnExit];
    [self editPasswordOnExit];
    
    ESPUser *user = [ESPUser sharedUser];
    
    // load user guest
    [user loadGuest];
    
    MainUIViewController *mainUIvc = [[MainUIViewController alloc]init];
    [self presentViewController:mainUIvc animated:YES completion:^{
        // completion
        [user loadDevices];
    }];
    
    ESPConfig *config = [ESPConfig sharedConfig];
    // save or clear last user email if necessary
    if (self.autoLoginCb.isChecked) {
        [config saveUserEmail:user.espUserEmail];
    } else {
        [config clearUserEmail];
    }
}

- (void)tapLoginBtnAction
{
    // actorView
    __block HZActivityIndicatorView *actorView = [[HZActivityIndicatorView alloc]init];
    actorView.steps = 16;
    actorView.finSize = CGSizeMake(4, 20);
    actorView.indicatorRadius = 10;
    actorView.stepDuration = 0.100;
    actorView.color = [UIColor grayColor];
    actorView.roundedCoreners = UIRectCornerAllCorners;
    actorView.cornerRadii = CGSizeMake(10, 10);
    actorView.translatesAutoresizingMaskIntoConstraints = NO;
    actorView.hidesWhenStopped = YES;
    [self.view addSubview:actorView];
    
    // actorView.centerX = self.view.centerX
    NSLayoutConstraint *actorViewConstraintX = [NSLayoutConstraint constraintWithItem:actorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.view addConstraint:actorViewConstraintX];
    
    // actorView.centerY = self.view.centerY
    NSLayoutConstraint *actorViewConstraintY = [NSLayoutConstraint constraintWithItem:actorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.view addConstraint:actorViewConstraintY];
    
    // actorView.width = actorView.frame.size.width
    NSLayoutConstraint *actorViewConstraintWidth = [NSLayoutConstraint constraintWithItem:actorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:actorView.frame.size.width];
    [self.view addConstraint:actorViewConstraintWidth];
    
    // actorView.height = actorView.width
    NSLayoutConstraint *actorViewConstraintHeight = [NSLayoutConstraint constraintWithItem:actorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:actorView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:actorViewConstraintHeight];
    
    [actorView startAnimating];
    

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        ESPUser *user = [ESPUser sharedUser];
        NSString *userEmail = self.mailboxTf.text;
        NSString *userPassword = self.passwdTf.text;
        // check user email valid
        if (![ESPStringUtil isValidateEmail:userEmail]) {
            NSString *alertTitle = @"LOGIN";
            NSString *alertMessage = @"Please input valid email";
            __block UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [actorView stopAnimating];
                [alertView show];
            });
            // dimiss alert view after 1 seconds
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
            });
            return;
        }
        // check user password valid
        if ([userPassword length]==0) {
            NSString *alertTitle = @"LOGIN";
            NSString *alertMessage = @"Please input password";
            __block UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [actorView stopAnimating];
                [alertView show];
            });
            // dimiss alert view after 1 seconds
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
            });
            return;
        }
        
        __block ESPLoginResult *result = [user doActionUserLoginInternetUserEmail:userEmail UserPassword:userPassword];
        
        __block UIAlertView *alertView;
        __block NSString *alertTitle = @"LOGIN";
        __block NSString *alertMessage;
        __block MainUIViewController *mainUIvc;
        
        ESPConfig *config = [ESPConfig sharedConfig];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // hide soft-keyboard
            [self editMailboxOnExit];
            [self editPasswordOnExit];
            
            [actorView stopAnimating];
            switch (result.loginResult) {
                case LOGIN_SUC:
                    mainUIvc = [[MainUIViewController alloc]init];
                    [self presentViewController:mainUIvc animated:YES completion:^{
                        // completion
                        ESPUser *user = [ESPUser sharedUser];
                        [user loadDevices];
                        [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
                    }];
                    alertMessage = @"login suc";
                    
                    // save user
                    [user saveUser];
                    
                    // save last user email if necessary
                    if (self.autoLoginCb.isChecked) {
                        [config saveUserEmail:user.espUserEmail];
                    } else {
                        [config clearUserEmail];
                    }
                    break;
                case LOGIN_PASSWORD_ERR:
                    alertMessage = @"password error";
                    break;
                case LOGIN_NOT_REGISTER:
                    alertMessage = @"account hasn't been registered";
                    break;
                case LOGIN_NETWORK_UNACCESSIBLE:
                    alertMessage = @"network unaccessible";
                    break;
            }
            // create alert view
            alertView = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
            [alertView show];
            NSLog(@"alertview show");
            // dimiss alert view after 2 seconds
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2ull * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
            });
        });
    });
}

- (void)tapRegisterBtnAction
{
    RegisterViewController *registerVC = [[RegisterViewController alloc]init];
    registerVC.delegate = self;
    [self presentViewController:registerVC animated:YES completion:nil];
}

- (void)editMailboxOnExit {
    [self.passwdTf becomeFirstResponder];
}

- (void)editPasswordOnExit {
    [self.passwdTf resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
    [self targetActionInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword {
    self.mailboxTf.text = userEmail;
    self.passwdTf.text = userPassword;
}

- (void)viewDidAppear:(BOOL)animated
{
    ESPConfig *config = [ESPConfig sharedConfig];
    if (!config.espIsAppLaunched) {
        config.espIsAppLaunched = YES;
        // load config
        [config loadConfig];
        NSString *userEmail = config.espConfigLastUserEmail;
        if (userEmail!=nil) {
            // load user
            ESPUser *user = [ESPUser sharedUser];
            user.espUserEmail = userEmail;
            if ([userEmail isEqualToString:ESP_USER_EMAIL_GUEST]) {
                [user loadGuest];
            } else{
                [user loadUser];
            }
            
            if (user.espUserKey!=nil) {
                
                // present view controller
                MainUIViewController *mainUIvc = [[MainUIViewController alloc]init];
                [self presentViewController:mainUIvc animated:YES completion:^{
                    [user loadDevices];
                }];
            }
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
