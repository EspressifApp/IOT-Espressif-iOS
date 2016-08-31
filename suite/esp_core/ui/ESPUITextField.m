//
//  ESPUITextField.m
//  suite
//
//  Created by 白 桦 on 5/18/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPUITextField.h"

@implementation ESPUITextField

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, CGRectMake(0.5, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5));
}

@end
