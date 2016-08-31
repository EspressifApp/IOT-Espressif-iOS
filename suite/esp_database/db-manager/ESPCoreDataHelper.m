//
//  ESPCoreDataHelper.m
//  CoreDataWarehouse
//
//  Created by 白 桦 on 8/9/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCoreDataHelper.h"

//#define debug

@interface ESPCoreDataHelper()

@property (nonatomic, readonly) NSManagedObjectModel            *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator    *coordinator;
@property (nonatomic, readonly) NSPersistentStore               *store;
@property (nonatomic, readonly) NSRecursiveLock                 *recursiveLock;

@end

@implementation ESPCoreDataHelper

DEFINE_SINGLETON_FOR_CLASS(CoreDataHelper, ESP);

#pragma mark - FILES
NSString *storeFilename = @"Espressif-IOT.sqlite";

#pragma mark - PATHS
-(NSString *)applicationDocumentsDirectory {
#ifdef debug
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
#endif
    return [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES)lastObject];
}

-(NSURL *)applicationStoresDirectory {
#ifdef debug
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
#endif
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]]URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
#ifdef debug
            NSLog(@"Successfully created Stores directory");
#endif
        } else {
            NSLog(@"FAILED to create Stores directory. Error: %@ in %@",error,self.class);
            abort();
        }
    }
    return storesDirectory;
}

-(NSURL *)storeURL {
#ifdef debug
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
#endif
    return [[self applicationStoresDirectory]URLByAppendingPathComponent:storeFilename];
}

#pragma mark - SETUP
-(instancetype)init{
#ifdef debug
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
#endif
    self = [super init];
    if (self) {
        _recursiveLock = [[NSRecursiveLock alloc]init];
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        _coordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:_model];
        _context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_context setPersistentStoreCoordinator:_coordinator];
        [self setupCoreData];
    }
    return self;
}

-(void)loadStore{
#ifdef debug
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
#endif
    NSError *error = nil;
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption  :@"YES",
                              NSInferMappingModelAutomaticallyOption        :@"YES",
                              NSSQLitePragmasOption                         :@{@"journal_mode":@"DELETE"}
                              };
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
    if (!_store) {
        NSLog(@"Failed to add store. Error: %@ in %@", error, self.class);
        abort();
    } else {
#ifdef debug
        NSLog(@"Successfully added store: %@",_store);
#endif
    }
}

-(void)setupCoreData{
#ifdef debug
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
#endif
    [self loadStore];
}

#pragma mark - SAVING
-(void)saveContext{
#ifdef debug
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
#endif
    if ([_context hasChanges]) {
        [_context performBlock:^{
            [self lock];
            NSError *error = nil;
            if ([_context save:&error]) {
#ifdef debug
                NSLog(@"_context SAVED changes to persistent store");
#endif
            } else {
                NSLog(@"Failed to save _context: %@ in %@",error,self.class);
            }
            [self unlock];
        }];

    } else {
#ifdef debug
        NSLog(@"SKIPPED _context save, there are no changes!");
#endif
    }
}

#pragma mark - LOCK
-(void)lock{
#ifdef debug
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
#endif
    [_recursiveLock lock];
}

-(void)unlock{
#ifdef debug
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
#endif
    [_recursiveLock unlock];
}

@end
