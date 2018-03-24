//
//  Location+CoreDataProperties.m
//  StravaDemo
//
//  Created by owen on 16/10/25.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "Location+CoreDataProperties.h"

@implementation Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Location"];
}

@dynamic latitude;
@dynamic longitude;
@dynamic timestamp;
@dynamic speed;
@dynamic course;
@dynamic horizontalAccuracy;
@dynamic verticalAccuracy;
@dynamic run;

@end
