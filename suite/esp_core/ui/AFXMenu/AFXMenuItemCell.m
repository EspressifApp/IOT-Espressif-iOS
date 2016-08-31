//
//  AFXMenuItemCell.m
//  AFXMenu
//
//  Created by 白 桦 on 7/12/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "AFXMenuItemCell.h"

@interface AFXMenuItemCell()

@property (nonatomic, strong) AFXMenuItem *afxMenuItem;

@end

@implementation AFXMenuItemCell

-(instancetype)initWithMenuItem:(AFXMenuItem *)menuItem
{
    self = [super init];
    if (self) {
        _afxMenuItem = menuItem;
        self.textLabel.textAlignment =  NSTextAlignmentCenter;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
