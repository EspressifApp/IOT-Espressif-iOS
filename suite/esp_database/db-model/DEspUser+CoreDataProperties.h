//
//  DEspUser+CoreDataProperties.h
//  suite
//
//  Created by 白 桦 on 8/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DEspUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface DEspUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *espUserId;
@property (nullable, nonatomic, retain) NSString *espUserEmail;
@property (nullable, nonatomic, retain) NSString *espUserKey;
@property (nullable, nonatomic, retain) NSString *espUserName;

@end

NS_ASSUME_NONNULL_END
