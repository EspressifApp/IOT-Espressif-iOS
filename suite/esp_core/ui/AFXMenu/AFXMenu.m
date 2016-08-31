//
//  AFXMenu.m
//  AFXMenu
//
//  Created by 白 桦 on 7/10/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "AFXMenu.h"
#import "AFXMenuTableViewController.h"

@interface AFXMenu()

@property (nonatomic, strong) AFXMenuTableViewController *afxMenuController;

@end

@implementation AFXMenu

- (void) initInternal
{
    _afxMenuController = [[AFXMenuTableViewController alloc]init];
    [self addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
    // default color is blue
    self.afxMenuColor = [UIColor blueColor];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initInternal];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initInternal];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initInternal];
    }
    return self;
}

-(void) addMenuItem:(AFXMenuItem *)menuItem
{
    [_afxMenuController addMenuItem:menuItem];
}

-(void) removeMenuItem:(AFXMenuItem *)menuItem
{
    [_afxMenuController removeMenuItem:menuItem];
}

#pragma -mark tap action handling
-(void) tap
{
    [self showMenuItems];
}

-(void) showMenuItems
{
    [_afxMenuController showMenuItems];
}

-(CGSize) sizeString:(NSString *)str WithFont:(UIFont *)font
{
    NSDictionary* attribs = @{NSFontAttributeName:font};
    CGSize size = [str sizeWithAttributes:attribs];
    size.height = ceilf(size.height);
    size.width = ceilf(size.width);
    return size;
}

#pragma -mark layout title and image
-(void) layoutTitleImage
{
    NSString *title = _afxMenuTitle;
    UIImage *image = _afxMenuImage;
    if (image!=nil) {
        // image exist
        [self setTitle:title forState:UIControlStateNormal];
        [self setImage:image forState:UIControlStateNormal];
        // [-leftMargin-image-middleMargin-title-rightMargin-]
        // leftMargin=10,middleMargin=5,rightMargin>=leftMargin
        CGFloat leftMargin = 8.0f;
        CGFloat middleMargin = 5.0f;
        UIFont *font = self.titleLabel.font;
        CGSize titleSize = [self sizeString:title WithFont:font];
        CGFloat totalLen = titleSize.width + middleMargin + image.size.width;
        CGFloat rightMargin = self.bounds.size.width - totalLen - leftMargin;
        if (rightMargin<leftMargin) {
            rightMargin = leftMargin;
        }
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, leftMargin, 0, middleMargin+rightMargin)];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, leftMargin+middleMargin, 0, rightMargin)];
    } else {
        // image inexist
        [self setTitle:title forState:UIControlStateNormal];
        // [-edgeMargin-title-edgeMargin-]
        UIFont *font = self.titleLabel.font;
        CGSize titleSize = [self sizeString:title WithFont:font];
        CGFloat edgeMargin = (self.bounds.size.width-titleSize.width)/2;
        if (edgeMargin<0) {
            edgeMargin = 0;
        }
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeMargin, 0, edgeMargin)];
    }
}

#pragma -mark get/set methods

-(void) setAfxMenuTitle:(NSString *)afxMenuTitle
{
    _afxMenuTitle = afxMenuTitle;
    [self layoutTitleImage];
}

-(void) setAfxMenuImage:(UIImage *)afxMenuImage
{
    _afxMenuImage = afxMenuImage;
    [self layoutTitleImage];
}

-(void) setAfxMenuColor:(UIColor *)afxMenuColor
{
    _afxMenuColor = afxMenuColor;
    [self setTitleColor:afxMenuColor forState:UIControlStateNormal];
}

-(void) setAfxDelegate:(id<AFXMenuDelegate>)afxDelegate
{
    _afxMenuController.afxDelegate = afxDelegate;
}

-(void) setAfxParentViewController:(UIViewController *)afxParentViewController
{
    _afxMenuController.afxParentViewController = afxParentViewController;
}

@end
