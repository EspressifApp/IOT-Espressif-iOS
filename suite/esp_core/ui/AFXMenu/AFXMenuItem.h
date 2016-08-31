//
//  AFXMenuItem.h
//  AFXMenu
//
//  Created by 白 桦 on 7/10/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAfxMenuItemHeightDefault   53.0f

@interface AFXMenuItem : NSObject
@property (nonatomic, strong) NSString *afxMenuItemTitle;
@property (nonatomic, strong) UIImage *afxMenuItemImage;
@property (nonatomic, assign) NSUInteger afxMenuItemId;
@property (nonatomic, assign) CGFloat afxMenuItemHeight;
@end
