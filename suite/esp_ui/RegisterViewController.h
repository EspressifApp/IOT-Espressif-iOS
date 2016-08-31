//
//  RegisterViewController.h
//  suite
//
//  Created by 白 桦 on 5/19/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegisterViewDelegate <NSObject>

- (void)setUserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword;

@end

@interface RegisterViewController : UIViewController

@property (nonatomic,unsafe_unretained) id<RegisterViewDelegate>delegate;

@end
