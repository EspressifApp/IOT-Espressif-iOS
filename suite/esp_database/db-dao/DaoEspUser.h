//
//  DaoEspUser.h
//  suite
//
//  Created by 白 桦 on 8/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DaoEspUser : NSObject

@property (nullable, nonatomic, retain) NSNumber *espUserId;
@property (nullable, nonatomic, retain) NSString *espUserEmail;
@property (nullable, nonatomic, retain) NSString *espUserKey;
@property (nullable, nonatomic, retain) NSString *espUserName;

@end
