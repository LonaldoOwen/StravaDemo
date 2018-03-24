//
//  Run+CoreDataProperties.h
//  StravaDemo
//
//  Created by owen on 16/9/8.
//  Copyright © 2016年 owen. All rights reserved.
//

//#import "Run+CoreDataClass.h"
#import "Run.h"


NS_ASSUME_NONNULL_BEGIN

@interface Run (CoreDataProperties)

+ (NSFetchRequest<Run *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *distance;
@property (nullable, nonatomic, copy) NSNumber *duration;
@property (nullable, nonatomic, copy) NSDate *timestamp;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *tag;
@property (nullable, nonatomic, copy) NSString *runDescription;
@property (nullable, nonatomic, retain) NSOrderedSet<Location *> *locations;

@end

@interface Run (CoreDataGeneratedAccessors)

- (void)insertObject:(Location *)value inLocationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLocationsAtIndex:(NSUInteger)idx;
- (void)insertLocations:(NSArray<Location *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLocationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLocationsAtIndex:(NSUInteger)idx withObject:(Location *)value;
- (void)replaceLocationsAtIndexes:(NSIndexSet *)indexes withLocations:(NSArray<Location *> *)values;
- (void)addLocationsObject:(Location *)value;
- (void)removeLocationsObject:(Location *)value;
- (void)addLocations:(NSOrderedSet<Location *> *)values;
- (void)removeLocations:(NSOrderedSet<Location *> *)values;

@end

NS_ASSUME_NONNULL_END
