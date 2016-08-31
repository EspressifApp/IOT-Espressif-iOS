//
//  AFXMenu.h
//  AFXMenu
//
//  Created by 白 桦 on 7/10/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFXMenuItem.h"

#define DEBUG_ON_AFXMENU    YES

@class AFXMenuTableViewController;
@class AFXMenuItem;

@protocol AFXMenuDelegate <NSObject>
-(void)menuItemSelected:(AFXMenuItem*)menuItem;
@end

@interface AFXMenu : UIButton

// never forget to set afxParentViewController
@property (nonatomic, strong) UIViewController *afxParentViewController;
@property (nonatomic, strong) UIImage *afxMenuImage;
@property (nonatomic, strong) NSString *afxMenuTitle;
@property (nonatomic, strong) UIColor *afxMenuColor;
@property (nonatomic, strong) id<AFXMenuDelegate> afxDelegate;

-(void) addMenuItem:(AFXMenuItem *)menuItem;
-(void) removeMenuItem:(AFXMenuItem *)menuItem;

@end
