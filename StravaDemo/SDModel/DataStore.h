//
//  DataStore.h
//  StravaDemo
//
//  Created by owen on 16/6/13.
//  Copyright © 2016年 owen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataStore : NSObject

+ (instancetype)sharedInstance;
- (void)loadData;
- (void)createJSON;

@end
