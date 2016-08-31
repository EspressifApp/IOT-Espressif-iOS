//
//  AFXMenuItem.m
//  AFXMenu
//
//  Created by 白 桦 on 7/10/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "AFXMenuItem.h"

@implementation AFXMenuItem

@synthesize afxMenuItemHeight=_afxMenuItemHeight;

-(CGFloat) afxMenuItemHeight
{
    if (!_afxMenuItemHeight) {
        _afxMenuItemHeight = kAfxMenuItemHeightDefault;
    }
    return _afxMenuItemHeight;
}

@end
