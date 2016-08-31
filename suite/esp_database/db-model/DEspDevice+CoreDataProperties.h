//
//  DEspDevice+CoreDataProperties.h
//  suite
//
//  Created by 白 桦 on 8/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DEspDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface DEspDevice (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *espDeviceId;
@property (nullable, nonatomic, retain) NSString *espDeviceKey;
@property (nullable, nonatomic, retain) NSString *espDeviceBssid;
@property (nullable, nonatomic, retain) NSNumber *espDeviceType;
@property (nullable, nonatomic, retain) NSNumber *espDeviceState;
@property (nullable, nonatomic, retain) NSNumber *espDeviceIsOwner;
@property (nullable, nonatomic, retain) NSString *espDeviceName;
@property (nullable, nonatomic, retain) NSString *espDeviceRomCur;
@property (nullable, nonatomic, retain) NSString *espDeviceRomLat;
@property (nullable, nonatomic, retain) NSDate *espDeviceActivatedTimestamp;
@property (nullable, nonatomic, retain) NSNumber *espPKUserId;

@end

NS_ASSUME_NONNULL_END
