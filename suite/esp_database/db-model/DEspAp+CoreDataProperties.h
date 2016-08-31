//
//  DEspAp+CoreDataProperties.h
//  suite
//
//  Created by 白 桦 on 8/12/16.
//  Copyright © 2016 白 桦. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DEspAp.h"

NS_ASSUME_NONNULL_BEGIN

@interface DEspAp (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *espApBssid;
@property (nullable, nonatomic, retain) NSString *espApPwd;
@property (nullable, nonatomic, retain) NSString *espApSsid;

@end

NS_ASSUME_NONNULL_END
