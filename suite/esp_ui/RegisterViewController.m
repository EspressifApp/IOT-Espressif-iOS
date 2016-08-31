//
//  RegisterViewController.m
//  suite
//
//  Created by 白 桦 on 5/19/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "RegisterViewController.h"
#import "ESPUITextField.h"
#import "MainUIViewController.h"
#import "ESPStringUtil.h"
#import "ESPUser.h"
#import "HZActivityIndicatorView.h"

/**
 *       ------------------
 *       |                 |
 *       |                 |
 *       |                 |
 *       | 111111111111111 |
 *       | 222222222222222 |
 *       | 333333333333333 |
 *       | 444444444444444 |
 *       | 555         666 |
 *       |                 |
 *       |                 |
 *       -------------------
 *
 *       1: userNameTf
 *       2: mailboxTf
 *       3: passwdTf
 *       4: passwdAgainTf
 *       5: cancelBtn
 *       6: confirmBtn
 */

@interface RegisterViewController()

@property (nonatomic, strong) ESPUITextField *userNameTf;
@property (nonatomic, strong) ESPUITextField *mailboxTf;
@property (nonatomic, strong) ESPUITextField *passwdTf;
@property (nonatomic, strong) ESPUITextField *passwdAgainTf;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation RegisterViewController

- (void)viewInit {
    // userNameTf
    self.userNameTf = [[ESPUITextField alloc]init];
    self.userNameTf.translatesAutoresizingMaskIntoConstraints = NO;
    self.userNameTf.placeholder = @"Please input user name";
    self.userNameTf.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:self.userNameTf];

    // self.userNameTf.centerX = self.view.centerX
    NSLayoutConstraint *userNameTfConstraintX = [NSLayoutConstraint constraintWithItem:self.userNameTf attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.view addConstraint:userNameTfConstraintX];
    // self.userNameTf.top = self.view.bottom * 0.4
    NSLayoutConstraint *userNameTfConstraintY = [NSLayoutConstraint constraintWithItem:self.userNameTf attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.4 constant:0.0];
    [self.view addConstraint:userNameTfConstraintY];
    // self.userNameTf.width = self.view.width * 0.8
    NSLayoutConstraint *userNameTfConstraintWidth = [NSLayoutConstraint constraintWithItem:self.userNameTf attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0.0];
    [self.view addConstraint:userNameTfConstraintWidth];
    // self.userNameTf.height = 30.0
    NSLayoutConstraint *userNameTfConstraintHeight = [NSLayoutConstraint constraintWithItem:self.userNameTf attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:30.0];
    [self.view addConstraint:userNameTfConstraintHeight];
    
    // mailboxTf
    self.mailboxTf = [[ESPUITextField alloc]init];
    self.mailboxTf.translatesAutoresizingMaskIntoConstraints = NO;
    self.mailboxTf.placeholder = @"Please input user email";
    self.mailboxTf.keyboardType = UIKeyboardTypeASCIICapable;
    [self.view addSubview:self.mailboxTf];
    
    // self.mailboxTf.leading = self.userNameTf.leading
    NSLayoutConstraint *mailboxTfConstraintX = [NSLayoutConstraint constraintWithItem:self.mailboxTf attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.userNameTf attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:mailboxTfConstraintX];
    // self.mailboxTf.top = self.userNameTf.bottom + 8.0
    NSLayoutConstraint *mailboxTfConstraintY = [NSLayoutConstraint constraintWithItem:self.mailboxTf attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameTf attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    [self.view addConstraint:mailboxTfConstraintY];
    // self.mailboxTf.width = self.userNameTf.width
    NSLayoutConstraint *mailboxTfConstraintWidth = [NSLayoutConstraint constraintWithItem:self.mailboxTf attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.userNameTf attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:mailboxTfConstraintWidth];
    // self.mailboxTf.height = self.userNameTf.height
    NSLayoutConstraint *mailboxTfConstraintHeight = [NSLayoutConstraint constraintWithItem:self.mailboxTf attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.userNameTf attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:mailboxTfConstraintHeight];
    
    // passwdTf
    self.passwdTf = [[ESPUITextField alloc]init];
    self.passwdTf.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwdTf.placeholder = @"Please input password";
    self.passwdTf.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwdTf.secureTextEntry = YES;
    [self.view addSubview:self.passwdTf];
    
    // self.passwdTf.leading = self.mailboxTf.leading
    NSLayoutConstraint *passwdTfConstraintX = [NSLayoutConstraint constraintWithItem:self.passwdTf attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:passwdTfConstraintX];
    // self.passwdTf.top = self.mailboxTf.bottom + 8.0
    NSLayoutConstraint *passwdTfConstraintY = [NSLayoutConstraint constraintWithItem:self.passwdTf attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    [self.view addConstraint:passwdTfConstraintY];
    // self.passwdTf.width = self.mailboxTf.width
    NSLayoutConstraint *passwdTfConstraintWidth = [NSLayoutConstraint constraintWithItem:self.passwdTf attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:passwdTfConstraintWidth];
    // self.passwdTf.height = self.mailboxTf.height
    NSLayoutConstraint *passwdTfConstraintHeight = [NSLayoutConstraint constraintWithItem:self.passwdTf attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.mailboxTf attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:passwdTfConstraintHeight];
    
    // passwdAgainTf
    self.passwdAgainTf = [[ESPUITextField alloc]init];
    self.passwdAgainTf.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwdAgainTf.placeholder = @"Please input password again";
    self.passwdAgainTf.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwdAgainTf.secureTextEntry = YES;
    [self.view addSubview:self.passwdAgainTf];
    
    // self.passwdAgainTf.leading = self.passwdTf.leading
    NSLayoutConstraint *passwdAgainTfConstraintX = [NSLayoutConstraint constraintWithItem:self.passwdAgainTf attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.passwdTf attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:passwdAgainTfConstraintX];
    // self.passwdAgainTf.top = self.passwdTf.bottom + 8.0
    NSLayoutConstraint *passwdAgainTfConstraintY = [NSLayoutConstraint constraintWithItem:self.passwdAgainTf attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwdTf attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    [self.view addConstraint:passwdAgainTfConstraintY];
    // self.passwdAgainTf.width = self.passwdTf.width
    NSLayoutConstraint *passwdAgainTfConstraintWidth = [NSLayoutConstraint constraintWithItem:self.passwdAgainTf attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.passwdTf attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:passwdAgainTfConstraintWidth];
    // self.passwdAgainTf.height = self.passwdTf.height
    NSLayoutConstraint *passwdAgainTfConstraintHeight = [NSLayoutConstraint constraintWithItem:self.passwdAgainTf attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.passwdTf attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:passwdAgainTfConstraintHeight];
 
    
    // cancelBtn
    self.cancelBtn = [[UIButton alloc]init];
    self.cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:255.0 alpha:0.4] forState:UIControlStateHighlighted];
    self.cancelBtn.layer.borderColor = [[UIColor blueColor] CGColor];
    self.cancelBtn.layer.borderWidth = 1.0f;
    self.cancelBtn.layer.cornerRadius = 8.0f;
    self.cancelBtn.layer.masksToBounds = YES;
    [self.view addSubview:self.cancelBtn];
    
    // self.cancelBtn.leading = self.passwdAgainTf.leading
    NSLayoutConstraint *cancelBtnConstraintX = [NSLayoutConstraint constraintWithItem:self.cancelBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.passwdAgainTf attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:cancelBtnConstraintX];
    // self.cancelBtn.top = self.passwdAgainTf.bottom + 8.0
    NSLayoutConstraint *cancelBtnConstraintY = [NSLayoutConstraint constraintWithItem:self.cancelBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwdAgainTf attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    [self.view addConstraint:cancelBtnConstraintY];
    // self.cancelBtn.width = self.view.width * 0.35
    NSLayoutConstraint *cancelBtnConstraintWidth = [NSLayoutConstraint constraintWithItem:self.cancelBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.35 constant:0.0];
    [self.view addConstraint:cancelBtnConstraintWidth];
    // self.cancelBtn.height = 30.0
    NSLayoutConstraint *cancelBtnConstraintHeight = [NSLayoutConstraint constraintWithItem:self.cancelBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:30.0];
    [self.view addConstraint:cancelBtnConstraintHeight];
    
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
    
    // self.confirmBtn.trailing = self.passwdAgainTf.trailing
    NSLayoutConstraint *confirmBtnConstraintX = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.passwdAgainTf attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:confirmBtnConstraintX];
    // self.confirmBtn.top = self.cancelBtn.top
    NSLayoutConstraint *confirmBtnConstraintY = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cancelBtn attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:confirmBtnConstraintY];
    // self.confirmBtn.width = self.cancelBtn.width
    NSLayoutConstraint *confirmBtnConstraintWidth = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.cancelBtn attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:confirmBtnConstraintWidth];
    // self.confirmBtn.height = self.cancelBtn.height
    NSLayoutConstraint *confirmBtnConstraintHeight = [NSLayoutConstraint constraintWithItem:self.confirmBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.cancelBtn attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:confirmBtnConstraintHeight];
}

- (void)targetActionInit {
    [self.cancelBtn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmBtn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.userNameTf addTarget:self action:@selector(editOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.mailboxTf addTarget:self action:@selector(editOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwdTf addTarget:self action:@selector(editOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwdAgainTf addTarget:self action:@selector(editOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    
    // hide soft-keyboard when touch background
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tap:(id) sender {
    if (sender==self.cancelBtn) {
        [self tapCancelBtnAction];
    } else if(sender==self.confirmBtn) {
        [self tapConfirmBtnAction];
    }
}

- (void)tapCancelBtnAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapConfirmBtnAction {
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
    
    __block UIAlertView *alertView;
    __block NSString *alertTitle = @"Register";
    __block NSString *alertMessage;
    NSString *userName = self.userNameTf.text;
    NSString *mailbox = self.mailboxTf.text;
    NSString *password = self.passwdTf.text;
    NSString *passwordAgaing = self.passwdAgainTf.text;
    __block BOOL isValid = YES;
    // check username
    if (isValid && [userName length]==0) {
        isValid = NO;
        alertMessage = @"user name can't be null";
    }
    // check mailbox
    if (isValid && ![ESPStringUtil isValidateEmail:mailbox]) {
        isValid = NO;
        alertMessage = @"user email is invalid";
    }
    // check password
    if (isValid && [password length] < 6) {
        isValid = NO;
        alertMessage = @"user password length shouldn't less than 6";
    }
    // check passwordAgain
    if (isValid && ![password isEqualToString:passwordAgaing]) {
        isValid = NO;
        alertMessage = @"user password should be the same";
    }
    if (!isValid) {
        alertView = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        // dimiss alert view after 1 seconds
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
        });
        return;
    }
    
    [actorView startAnimating];
    
    __block MainUIViewController *mainUIvc;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        ESPUser *user = [ESPUser sharedUser];
        ESPRegisterResult *result = [user doActionUserRegisterInternetUserName:userName UserEmail:mailbox UserPassword:password];
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (result.registerResult) {
                case REGISTER_SUC:
                    mainUIvc = [[MainUIViewController alloc]init];
                    // inverse transmission value
                    [self.delegate setUserEmail:mailbox UserPassword:password];
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                        // completion
                        [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
                    }];
                    alertMessage = @"register suc";
                    break;
                case REGISTER_USER_OR_EMAIL_EXIST_ALREADY:
                    NSLog(@"user or email exist already");
                    alertMessage = @"user or email exist already";
                    break;
                case REGISTER_USER_OR_EMAIL_ERR_FORMAT:
                    alertMessage = @"email format error";
                    break;
                case REGISTER_NETWORK_UNACCESSIBLE:
                    alertMessage = @"network unaccessible";
                    break;
            }
            // create alert view
            alertView = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
            [actorView stopAnimating];
            [alertView show];
            // dimiss alert view after 2 seconds
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2ull * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
            });
        });
    });
}

- (void)tapView
{
    [self.view endEditing:YES];
}

- (void)editOnExit:(id) sender
{
    if (sender==self.userNameTf) {
        [self editUserNameOnExit];
    } else if (sender==self.mailboxTf) {
        [self editMailboxOnExit];
    } else if (sender==self.passwdTf) {
        [self editPasswdOnExit];
    } else if (sender==self.passwdAgainTf) {
        [self editPasswdAgainOnExit];
    }
}

- (void)editUserNameOnExit
{
    [self.mailboxTf becomeFirstResponder];
}

- (void)editMailboxOnExit
{
    [self.passwdTf becomeFirstResponder];
}


- (void)editPasswdOnExit
{
    [self.passwdAgainTf becomeFirstResponder];
}

- (void)editPasswdAgainOnExit
{
    [self.passwdAgainTf resignFirstResponder];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self viewInit];
    [self targetActionInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
