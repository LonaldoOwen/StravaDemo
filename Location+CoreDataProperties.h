//
//  Location+CoreDataProperties.h
//  StravaDemo
//
//  Created by owen on 16/10/25.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "Location+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *latitude;
@property (nullable, nonatomic, copy) NSNumber *longitude;
@property (nullable, nonatomic, copy) NSDate *timestamp;
@property (nullable, nonatomic, copy) NSNumber *speed;
@property (nullable, nonatomic, copy) NSNumber *course;
@property (nullable, nonatomic, copy) NSNumber *horizontalAccuracy;
@property (nullable, nonatomic, copy) NSNumber *verticalAccuracy;
@property (nullable, nonatomic, retain) Run *run;

@end

NS_ASSUME_NONNULL_END
