//
//  Run+CoreDataProperties.m
//  StravaDemo
//
//  Created by owen on 16/9/8.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "Run+CoreDataProperties.h"

@implementation Run (CoreDataProperties)

+ (NSFetchRequest<Run *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Run"];
}

@dynamic distance;
@dynamic duration;
@dynamic timestamp;
@dynamic name;
@dynamic type;
@dynamic tag;
@dynamic runDescription;
@dynamic locations;

@end
