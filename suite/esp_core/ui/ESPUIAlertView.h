//
//  ESPUIAlertView.h
//  suite
//
//  Created by 白 桦 on 8/1/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPVersionMacro.h"

#define kEspUIAlertViewLongTimeInterval     3.5
#define kEspUIAlertViewShortTimeInterval    2.0

@interface ESPUIAlertView : NSObject

@property (nonatomic, strong) NSString *espTitle;

@property (nonatomic, strong) NSString *espMessage;

- (void) showTimeInterval:(NSTimeInterval) timeInterval Instant:(BOOL) isInstant;

@end
