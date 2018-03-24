//
//  AppDelegate.m
//  StravaDemo
//
//  Created by owen on 16/5/22.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "DataStore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (NSManagedObjectModel *)managedObjectModel{
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelPath = [[NSBundle mainBundle] URLForResource:@"SDDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
    
    return _managedObjectModel;
}


-(NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsPath = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *storeFile = [documentsPath URLByAppendingPathComponent:@"run_data.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeFile options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext{
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    /**
     * 注意：NSManagedObjectContext初始化不用init了，改用initWithConcurrencyType：了？？？
     */
    if (self.persistentStoreCoordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    
    return _managedObjectContext;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 修改tabBarItem选中颜色
    [UITabBar appearance].tintColor = [UIColor colorWithRed:273/255.0 green:59/255.0 blue:19/255.0 alpha:1.0];
    
    //
    DataStore *dataStore = [DataStore sharedInstance];
    [dataStore loadData];
    [dataStore createJSON];
    
    return YES;
}



- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //
    [self saveContext];
}

- (void)saveContext{
    
    NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            //
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
