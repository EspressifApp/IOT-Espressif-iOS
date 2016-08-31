//
//  AFXMenuTableViewController.h
//  AFXMenu
//
//  Created by 白 桦 on 7/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFXMenu.h"

#define kAFXMenuTableViewHeightMaxRatio  0.4

@interface AFXMenuTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) id<AFXMenuDelegate> afxDelegate;
@property (nonatomic, weak) UIViewController *afxParentViewController;

-(void) addMenuItem:(AFXMenuItem *)menuItem;
-(void) removeMenuItem:(AFXMenuItem *)menuItem;

-(void) showMenuItems;
-(void) dismissMenuItems;

@end
