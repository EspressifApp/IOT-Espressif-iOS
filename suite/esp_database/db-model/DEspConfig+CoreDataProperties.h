//
//  DEspConfig+CoreDataProperties.h
//  suite
//
//  Created by 白 桦 on 8/12/16.
//  Copyright © 2016 白 桦. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DEspConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface DEspConfig (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *espConfigLastUserEmail;
@property (nullable, nonatomic, retain) NSString *espConfigLastApBssid;

@end

NS_ASSUME_NONNULL_END
