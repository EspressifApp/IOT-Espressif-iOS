//
//  ESPUICheckBox.h
//  suite
//
//  Created by 白 桦 on 5/17/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESPUICheckBox : UIControl

@property (nonatomic, assign) BOOL isChecked;

- (instancetype) initWithFrame:(CGRect)frame;

- (instancetype) initWithFrame:(CGRect)frame Checked:(BOOL)isChecked;

@end
