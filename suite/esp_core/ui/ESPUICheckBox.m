//
//  ESPUICheckBoxButton.m
//  suite
//
//  Created by 白 桦 on 5/17/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPUICheckBox.h"

@interface ESPUICheckBox()

@property (nonatomic, strong) UIImageView *icon;

@end

@implementation ESPUICheckBox

- (instancetype) initWithFrame:(CGRect)frame Checked:(BOOL)isChecked
{
    self = [super initWithFrame:frame];
    if (self) {
        // enable user interaction
        self.userInteractionEnabled = YES;
        // exclude subviews to respond touch event
        self.exclusiveTouch = YES;
        // imageView Frame relative to UICheckBoxButton
        CGRect imageViewFrame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        self.icon = [[UIImageView alloc]initWithFrame:imageViewFrame];
        self.isChecked = isChecked;
        UIImage *image = [self checkBoxImageForChecked:isChecked];
        self.icon.image = image;
        [self addSubview:self.icon];
        [self addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame Checked:NO];
}

- (void)setIsChecked:(BOOL)isChecked
{
    if (isChecked != _isChecked) {
        _isChecked = isChecked;
        UIImage *image = [self checkBoxImageForChecked:isChecked];
        [_icon setImage:image];
    }
}

- (UIImage *)checkBoxImageForChecked:(BOOL)isChecked
{
    return isChecked ? [UIImage imageNamed:@"esp_checkbox_on.png"] : [UIImage imageNamed:@"esp_checkbox_off.png"];
}

- (void)click {
    [self setIsChecked: !_isChecked];
}

@end
