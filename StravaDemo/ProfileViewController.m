//
//  ProfileViewController.m
//  StravaDemo
//
//  Created by owen on 16/5/25.
//  Copyright © 2016年 owen. All rights reserved.
//
//
/**
 * 功能：个人主页：显示个人运动数据
   1、
   2、
   3、
 */


#import "ProfileViewController.h"
#import "DataContainerViewController.h"
#import "WeekDataViewController.h"
#import "Run.h"
#import "Day.h"
#import "Ride.h"
#import "Goal.h"
#import "Page.h"


@interface ProfileViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIView *yearGoalView;
@property (weak, nonatomic) IBOutlet UIView *imageContainerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subNameLabel;

@property (strong, nonatomic) NSArray *pastRuns;
@property (strong, nonatomic) NSArray *pastRides;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSDate *dayStamp;



@end

@implementation ProfileViewController

// 宏定义
#define blackColor [UIColor colorWithRed:32.0/255 green:32.0/255 blue:32.0/255 alpha:1.0];
#define grayColor [UIColor colorWithRed:42.0/255 green:42.0/255 blue:42.0/255 alpha:1.0];

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"profileVC: viewDidLoad");
    
    // 基本UI配置
    self.view.backgroundColor = blackColor;
    self.yearGoalView.backgroundColor = grayColor;
    
    // setup navigation titleView
    [self setUpTitleView];
    
    // 配置头部view
    [self setUpHeaderView];
    
    // test：日期
    //[self caculateData];
    
    // 从数据库加载数据
    //[self loadData];// 转移到DataStore中进行
    
    // 创建json
    //[self createJSON];// 转移到DataStore中进行
    
    // 配置tableView
    self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, -20, 0);//设置tableView距离四周边界的距离
    self.myTableView.separatorColor = [UIColor redColor];
    self.myTableView.dataSource = self;
    
    //
    
}

// 配置导航栏
- (void)setUpTitleView{
    
    /**
     * 功能：修改导航栏样式为黑色不透明
     */
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = blackColor;
    
    self.title = @"Profile";
    
}

// 配置头部view
- (void)setUpHeaderView{
    
    // 配置view
    self.headerView.backgroundColor = blackColor;
    
    // avatar：头像显示圆形
    self.avatar.layer.cornerRadius = 35.0;
    self.avatar.layer.masksToBounds = YES;
    
    // name
    self.nameLabel.text = @"Lonaldo.Owen";
    self.nameLabel.textColor = [UIColor whiteColor];
    self.subNameLabel.text = @"millan,Italy";
    self.subNameLabel.textColor = [UIColor lightGrayColor];
}

// 加载数据
- (void)loadData{
    NSLog(@"profile load DB");
    
    // 获取managedObjectContext
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
    NSLog(@"create JSON");
    
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
    
    
    // pages（数组转模型）
    NSMutableArray *pages = [NSMutableArray array];
    for (int j = 12; j >= 1; j--) {
        
        // page0
        Page *page0 = [[Page alloc] init];
        Ride *runRide = [[Ride alloc] init];//run
        Ride *ride = [[Ride alloc] init];//ride
        
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
            self.dayStamp = [gregorian dateFromComponents:comps];
            NSLog(@"i:%d;dayStamp:%@", i, self.dayStamp);
            
            //
            NSInteger sumRun = 0;
            NSInteger sumDuration = 0;
            for (Run *run in self.pastRuns) {
                
                NSString *timestampString = [formatter stringFromDate:run.timestamp];
                NSString *daystampString = [formatter stringFromDate:self.dayStamp];
                
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
                NSString *daystampString = [formatter stringFromDate:self.dayStamp];
                
                if ([timestampString isEqualToString:daystampString]) {
                    sumRide += run.distance.floatValue ;
                    sumRideDuration += run.duration.floatValue;
                }
            }
            rideDay.distance = sumRide + [self createRandomIntegerWithMultiplier:10000];//500000,假数据
            rideDay.elapsedTime = sumRideDuration + [self createRandomIntegerWithMultiplier:1000];//6000，假数据
            rideDay.movingTime = 0;
            rideDay.elevationGain = [self createRandomIntegerWithMultiplier:100];//500，假数据
            
            [rideDaysArray addObject:rideDay];
            ride.distance += rideDay.distance;
            ride.elapsedTime += rideDay.elapsedTime;
            ride.elevationGain += rideDay.elevationGain;
            ride.movingTime += rideDay.movingTime;
            
        }
        NSLog(@"daysArray:%@", daysArray);
        
        // create goal
        Goal *runGoal = [[Goal alloc] init];
        runGoal.goal = [self createRandomIntegerWithMultiplier:1000];
        runGoal.type = @"TimeGoal";
        
        Goal *rideGoal = [[Goal alloc] init];
        rideGoal.goal = [self createRandomIntegerWithMultiplier:1000];
        rideGoal.type = @"DistanceGoal";
        
        runRide.goal = rideGoal;
        ride.goal = runGoal;
        
        
        runRide.days = daysArray;
        ride.days = rideDaysArray;
        page0.year = year;
        page0.week = weekOfYear;
        page0.run = runRide;
        page0.ride = ride;
        
        
        [pages addObject:page0];
        weekOfYear = weekOfYear - 1;
    }
    
    
    
    
    // 模型转JSON
    NSMutableArray *pagesArray = [NSMutableArray array];
    for (Page *page in pages) {
        
        NSMutableDictionary *pageDict = [[NSMutableDictionary alloc] init];
        pageDict[@"year"] = @(page.year);
        pageDict[@"week"] = @(page.week);
        //pageDict[@"run"] = ;
        
        // run
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
        
        // ride
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

//
- (void)caculateData{
    
    // 根据日期计算当前日期的NSDateComponents属性（如：第几周等）
//    NSDateComponents *_comps = [[NSDateComponents alloc] init];
//    [_comps setDay:7];
//    [_comps setMonth:6];
//    [_comps setYear:2016];
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDate *_date = [gregorian dateFromComponents:_comps];
//    
//    // 一周中哪一天
//    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:_date];
//    NSInteger _weekday = [weekdayComponents weekday];
//    // 这个月中的第几个工作日(工作日的顺序，即：在这个月某个工作日第几次出线)
//    NSDateComponents *weekdayOrdinalComponents = [gregorian components:NSCalendarUnitWeekdayOrdinal fromDate:_date];
//    NSInteger _weekdayOrdinal = [weekdayOrdinalComponents weekdayOrdinal];
//    // 一个月中的第几周
//    NSDateComponents *weekOfMonthComponents = [gregorian components:NSCalendarUnitWeekOfMonth fromDate:_date];
//    NSInteger _weekOfMonth = [weekOfMonthComponents weekOfMonth];
//    
//    NSLog(@"_weekday:%ld, _weekdayOrdinal:%ld, _weekOfMonth:%ld", (long)_weekday, (long)_weekdayOrdinal, (long)_weekOfMonth);
//    NSLog(@"今天是这个月的第几周:%ld,第几个：%ld 星期：%ld", _weekOfMonth, _weekdayOrdinal, _weekday);
    
    
    // 返回一个新的NSDate(和现在差一定时间)
    /**
     * 说明：[NSDate date]返回的是个标准时间，转换成系统时区时间
     */
//    NSDate *currentDate = [NSDate date];
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [timeZone secondsFromGMTForDate:currentDate];
//    NSDate *localDate = [currentDate dateByAddingTimeInterval:interval];
    
    //NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
//    NSDateComponents *comps = [[NSDateComponents alloc] init];
//    [comps setMonth:-2];
//    [comps setDay:3];
//    NSDate *date = [gregorian dateByAddingComponents:comps toDate:localDate options:0];//获取距离现在某个时间间隔的date
//    NSLog(@"time zome:%@,currentDate:%@,localDate:%@ date:%@", timeZone, currentDate, localDate, date);
    
    // 根据NSDateComponents计算日期时间
//    NSDateComponents *comps = [[NSDateComponents alloc] init];
//    [comps setYear:2016];
//    [comps setWeekOfYear:25];
//    [comps setWeekOfMonth:3];
//    [comps setWeekday:1];
//    NSDate *date = [gregorian dateFromComponents:comps];
//    NSDate *localDate = [self convertDateToLocalDate:date];
//    NSLog(@"date:%@;\n localDate:%@", date, localDate);
    
//    NSDate *date = [NSDate date];
//    NSDate *localDate = [self convertDateToLocalDate:date];
//    NSLog(@"convert date to local from:%@ to :%@", date, localDate);
//    
//    /**
//     * 说明：通过formatter和setDateStyle:、setTimeStyle:将date转换为string后得到的也是当前时区的时间
//     */
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterMediumStyle];
//    NSLog(@"formatter date:%@", [formatter stringFromDate:date]);
//    NSLog(@"formatter localDate:%@", [formatter stringFromDate:localDate]);
    
    
    
    
    // 日期时间格式类型
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"'公元前/后:'G  '年份:'u'='yyyy'='yy '季度:'q'='qqq'='qqqq '月份:'M'='MMM'='MMMM '今天是今年第几周:'w '今天是本月第几周:'W  '今天是今年第几天:'D '今天是本月第几天:'d '星期:'c'='ccc'='cccc '上午/下午:'a '小时:'h'='H '分钟:'m '秒:'s '毫秒:'SSS  '这一天已过多少毫秒:'A  '时区名称:'zzzz'='vvvv '时区编号:'Z "];
//    NSLog(@"%@", [dateFormatter stringFromDate:[NSDate date]]);

    
}


// 将date转换成当前系统时区的时间
- (NSDate *)convertDateToLocalDate:(NSDate *)date{
    
    /**
     * 说明：将date转换成系统当前时区的时间
     */
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger interval = [timeZone secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:interval];
    
    return localDate;
}


//#MARK: /************        data source      ************/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 3;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
        
    cell.textLabel.text = [NSString stringWithFormat:@"Cell row:%ld", (long)indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"subtitle"];
    
    return cell;
}


// #MARK: /**********         UITableViewDelegate    *************/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 点击cell后取消cell的选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



@end
