//
//  ESPDeviceBaseViewController.m
//  suite
//
//  Created by 白 桦 on 10/14/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDeviceBaseViewController.h"
#import "ESPUser.h"

/**
 *       ------------------
 *       | 111111111111111 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       -------------------
 *
 *       1: titlebar
 *
 *       titlebar:
 *       ------------------
 *       |10             11|
 *       -------------------
 *
 *       10: titlebarLeftBtn
 *       11: titlebarRightBtn
 */
@interface ESPDeviceBaseViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *aiv;

@end

@implementation ESPDeviceBaseViewController

- (ESPDevice *)deviceBase {
    NSLog(@"ERROR %@ %@ should be override by subclass",self.class,NSStringFromSelector(_cmd));
    abort();
}

- (void)viewInitBase {
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
    navigationItem.title = self.deviceBase.espDeviceName;
    
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

- (void) tapTitlebarButtonLeft {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self viewInitBase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark menu
#define ESP_MENU_ID_UPGRADING_LOCAL     0
#define ESP_MENU_ID_UPGRADING_INTERNET  1
- (BOOL)addMenuItems:(AFXMenu *)menu {
    menu.afxParentViewController = self;
    menu.afxDelegate = self;
    NSString *romVerCur = self.deviceBase.espRomVersionCurrent;
    NSString *romVerLat = self.deviceBase.espRomVersionLatest;
    BOOL isOwner = self.deviceBase.espIsOwner;
    if (isOwner && romVerLat!=nil && ![romVerLat isEqualToString:romVerCur]) {
        if (self.deviceBase.espDeviceState.isStateLocal) {
            AFXMenuItem *menuItem = [[AFXMenuItem alloc]init];
            menuItem.afxMenuItemId = ESP_MENU_ID_UPGRADING_LOCAL;
            menuItem.afxMenuItemTitle = [NSString stringWithFormat:@"Upgrading Local to %@",romVerLat];
            [menu addMenuItem:menuItem];
        }
        if (self.deviceBase.espDeviceState.isStateInternet) {
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
        [user doActionUpgradeDeviceLocal:self.deviceBase];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)menuItemActionUpgradeInternet {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        ESPUser *user = [ESPUser sharedUser];
        [user doActionUpgradeDeviceInternet:self.deviceBase];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
