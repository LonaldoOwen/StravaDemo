//
//  DataStore.m
//  StravaDemo
//
//  Created by owen on 16/6/13.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "DataStore.h"
#import "Run.h"
#import "AppDelegate.h"
#import "Page.h"
#import "Day.h"
#import "Goal.h"

@interface DataStore ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *pastRuns;
@property (strong, nonatomic) NSArray *pastRides;

@end

@implementation DataStore

+ (instancetype)sharedInstance{
    
    static DataStore *sharedStore = nil;
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        sharedStore = [[self alloc] init];
    });
    
    return sharedStore;
}

// 加载数据
- (void)loadData{
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *run = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:run];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.pastRuns = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    //
    self.pastRides = self.pastRuns;
    
}


// create json
- (void)createJSON{
    
    NSDateFormatter *formatter = [[ NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSDate *currentDate = [NSDate date];
    //NSString *currentDateString = [formatter stringFromDate:currentDate];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitYear|NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear fromDate:currentDate];
    
    NSInteger year = [comps year];
    NSInteger weekday = [comps weekday];
    NSInteger weekOfYear = [comps weekOfYear];
    NSLog(@"currenDate:%@;year:%ld, weekday:%ld, weekOfYear:%ld",currentDate, (long)year, (long)weekday, (long)weekOfYear);
    
    
    // pages
    NSMutableArray *pages = [NSMutableArray array];
    for (int j = 12; j >= 1; j--) {
        
        // page0
        Page *page0 = [[Page alloc] init];
        Ride *runRide = [[Ride alloc] init];
        Ride *ride = [[Ride alloc] init];
        
        NSMutableArray *daysArray = [NSMutableArray array];
        NSMutableArray *rideDaysArray = [NSMutableArray array];
        for (int i = 1; i <= 7; i++) {
            
            Day *day = [[Day alloc] init];
            Day *rideDay = [[Day alloc] init];
            
            //
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setYear:year];
            [comps setWeekday:i];
            [comps setWeekOfYear:weekOfYear];
            
            //
            NSDate *dayStamp = [gregorian dateFromComponents:comps];
            NSLog(@"i:%d;dayStamp:%@", i, dayStamp);
            
            //
            NSInteger sumRun = 0;
            NSInteger sumDuration = 0;
            for (Run *run in self.pastRuns) {
                
                NSString *timestampString = [formatter stringFromDate:run.timestamp];
                NSString *daystampString = [formatter stringFromDate:dayStamp];
                
                if ([timestampString isEqualToString:daystampString]) {
                    sumRun += run.distance.floatValue;
                    sumDuration += run.duration.floatValue;
                }
                
            }
            day.distance = sumRun;
            day.elapsedTime = sumDuration;
            day.movingTime = i;//验证数组中元素顺序
            day.elevationGain = [self createRandomIntegerWithMultiplier:100];
            
            [daysArray addObject:day];
            runRide.distance += day.distance;
            runRide.elapsedTime += day.elapsedTime;
            runRide.elevationGain += day.elevationGain;
            runRide.movingTime += day.movingTime;
            
            //
            NSInteger sumRide = 0;
            NSInteger sumRideDuration = 0;
            for (Run *run in self.pastRides) {
                
                NSString *timestampString = [formatter stringFromDate:run.timestamp];
                NSString *daystampString = [formatter stringFromDate:dayStamp];
                
                if ([timestampString isEqualToString:daystampString]) {
                    sumRide += run.distance.floatValue ;
                    sumRideDuration += run.duration.floatValue;
                }
            }
            rideDay.distance = sumRide + [self createRandomIntegerWithMultiplier:10000];//500000
            rideDay.elapsedTime = sumRideDuration + [self createRandomIntegerWithMultiplier:1000];//6000;
            rideDay.movingTime = 0;
            rideDay.elevationGain = [self createRandomIntegerWithMultiplier:100];//500;
            
            [rideDaysArray addObject:rideDay];
            ride.distance += rideDay.distance;
            ride.elapsedTime += rideDay.elapsedTime;
            ride.elevationGain += rideDay.elevationGain;
            ride.movingTime += rideDay.movingTime;
            
        }
        NSLog(@"daysArray:%@", daysArray);
        
        // create goal（假数据）
        Goal *runGoal = [[Goal alloc] init];
        runGoal.goal = [self createRandomIntegerWithMultiplier:1000];
        runGoal.type = @"TimeGoal";
        Goal *rideGoal = [[Goal alloc] init];
        rideGoal.goal = [self createRandomIntegerWithMultiplier:100000];
        rideGoal.type = @"DistanceGoal";
        runRide.goal = runGoal;
        ride.goal = rideGoal;
        
        runRide.days = daysArray;
        ride.days = rideDaysArray;
        page0.year = year;
        page0.week = weekOfYear;
        page0.run = runRide;
        page0.ride = ride;
        
        [pages addObject:page0];
        weekOfYear = weekOfYear - 1;
    }
    
    
    
    
    // 转换成json格式
    NSMutableArray *pagesArray = [NSMutableArray array];
    for (Page *page in pages) {
        
        NSMutableDictionary *pageDict = [[NSMutableDictionary alloc] init];
        pageDict[@"year"] = @(page.year);
        pageDict[@"week"] = @(page.week);
        //pageDict[@"run"] = ;
        
        //
        NSMutableDictionary *runDict = [NSMutableDictionary dictionary];
        NSMutableArray *daysArray = [NSMutableArray array];
        for (Day *day in page.run.days) {
            NSMutableDictionary *dayDict = [NSMutableDictionary dictionary];
            dayDict[@"distance"] = @(day.distance);
            dayDict[@"elapsed_time"] = @(day.elapsedTime);
            dayDict[@"elevation_gain"] = @(day.elevationGain);//
            dayDict[@"moving_time"] = @(day.movingTime);
            [daysArray addObject:dayDict];
        }
        runDict[@"distance"] = @(page.run.distance);
        runDict[@"elapsed_time"] = @(page.run.elapsedTime);
        runDict[@"elevation_gain"] = @(page.run.elevationGain);
        runDict[@"moving_time"] = @(page.run.movingTime);
        // goal
        NSMutableDictionary *runGoalDict = [NSMutableDictionary dictionary];
        runGoalDict[@"goal"] = @(page.run.goal.goal);
        runGoalDict[@"type"] = page.run.goal.type;
        runDict[@"goal"] = runGoalDict;
        runDict[@"days"] = daysArray;
        
        pageDict[@"run"] = runDict;
        runDict[@"days"] = daysArray;
        pageDict[@"run"] = runDict;
        
        //
        NSMutableDictionary *rideDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *rideDaysArray = [NSMutableArray array];
        for (Day *day in page.ride.days) {
            NSMutableDictionary *rideDayDict = [NSMutableDictionary dictionary];
            rideDayDict[@"distance"] = @(day.distance);
            rideDayDict[@"elapsed_time"] = @(day.elapsedTime);
            rideDayDict[@"elevation_gain"] = @(day.elevationGain);//
            rideDayDict[@"moving_time"] = @(day.movingTime);//
            [rideDaysArray addObject:rideDayDict];
        }
        rideDict[@"distance"] = @(page.ride.distance);
        rideDict[@"elapsed_time"] = @(page.ride.elapsedTime);
        rideDict[@"elevation_gain"] = @(page.ride.elevationGain);
        rideDict[@"days"] = rideDaysArray;
        rideDict[@"moving_time"] = @(page.ride.movingTime);//
        // goal
        NSMutableDictionary *rideGoalDict = [NSMutableDictionary dictionary];
        rideGoalDict[@"goal"] = @(page.ride.goal.goal);
        rideGoalDict[@"type"] = page.ride.goal.type;
        rideDict[@"goal"] = rideGoalDict;
        
        pageDict[@"ride"] = rideDict;
        
        //
        [pagesArray addObject:pageDict];
    }
    NSLog(@"pagesArray:%@", pagesArray);
    
    
    //
    NSLog(@"create json");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documents = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *jsonFile = [documents URLByAppendingPathComponent:@"pages_run.json"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pagesArray options:NSJSONWritingPrettyPrinted error:nil];
    
    [jsonData writeToURL:jsonFile atomically:YES];

    
}

// 创建随机数
- (NSInteger)createRandomIntegerWithMultiplier:(NSInteger)multiplier{
    
    NSInteger random = arc4random() % 10;
    NSLog(@"random:%ld", (long)random);
    random = random * multiplier;
    
    
    return random;
}


@end
