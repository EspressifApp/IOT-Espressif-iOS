//
//  ESPUIUtil.h
//  suite
//
//  Created by 白 桦 on 5/18/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface ESPUIUtil : NSObject

+(CGSize) boundingRectWithSize:(NSString*) txt Font:(UIFont*) font Size:(CGSize) size;

@end
