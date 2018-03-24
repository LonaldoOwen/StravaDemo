//
//  ActivityViewController.m
//  StravaDemo
//
//  Created by owen on 16/6/2.
//  Copyright © 2016年 owen. All rights reserved.
//

/**
 * 功能：记时页面设计思路：各区域按比例添加约束，view2：view1= 3:2，view3=view2＋20（这样可以保证适配不同设备时按比例缩放）；文字适配可能需要使用代码来根据机型来判断了
   1、定时功能
   2、显示运动信息：速度、距离
   3、保存运动
 */

#import "ActivityViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Run.h"
#import "Location.h"
#import "DetailViewController.h"

static NSString *const detailSegueName = @"RunDetail";


@interface ActivityViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *minutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;


@property (weak, nonatomic) IBOutlet UILabel *averageSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;


@property (assign, nonatomic) NSTimeInterval ziroTime;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL isStart;
@property (strong, nonatomic) NSDate *stopDate;
@property (assign, nonatomic) BOOL paused;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (assign, nonatomic) CGFloat distanceTraveled;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) Run *run;
@property (strong, nonatomic) NSMutableArray *locations;
@property int seconds;//
@property CGFloat distance;//
@property (strong ,nonatomic) NSMutableArray *allUpdateLocations;


@end

@implementation ActivityViewController

// MARK:
- (NSMutableArray *)allUpdateLocations{
    
    if (_allUpdateLocations == nil) {
        _allUpdateLocations = [NSMutableArray array];
    }
    
    return _allUpdateLocations;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSURL *documnets = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    // setup location
    [self setUpLocation];
    self.isStart = NO;
    
    // add gesture
    [self addGesture];

}


// 配置定位功能
- (void)setUpLocation{
    
    // 实例化CLLocationManager对象
    self.locationManager = [[CLLocationManager alloc] init];
    
    
    // 申请使用位置功能权限
    /**
     * 说明：
     1、requestWhenInUseAuthorization前台使用，配合allowsBackgroundLocationUpdates一起使用，后台时可实现位置更新，顶部显示蓝条
     2、requestAlwaysAuthorization前台／后台均可使用，app会一直更新位置信息，后台时顶部不显示蓝条
     */
    [self.locationManager requestWhenInUseAuthorization];//前台使用
    //[self.locationManager requestAlwaysAuthorization];//前台／后台均可使用
    
    
    // 允许后台运行：设置allowsBackgroundLocationUpdates
    /**
     * 注意：开启后台模式，运行后台使用位置更新，同时也要allowsBackgroundLocationUpdates为YES，否则在后台无法更新位置，开启这个设置后，进入后台会在顶部显示蓝条
     */
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    
    
    // 设置代理
    self.locationManager.delegate = self;
    // 配置精度
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // 运动类型
    self.locationManager.activityType = CLActivityTypeFitness;
    // 位置过滤（移动达到最小距离才更新一次locaions）
    //self.locationManager.distanceFilter = 10;//默认1s更新一个location信息
    // 属性值初始设置
    self.startLocation = nil;//起始位置
    self.lastLocation = nil;//上一位置
    self.distanceTraveled = 0.0;//移动距离
    self.locations = [NSMutableArray array];//存放location
}


// 添加gesture recognizer（double tap）
- (void)addGesture{
    
    // 添加隐藏手势：显示定位数据
    UITapGestureRecognizer *doubleTapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapPress:)];
    doubleTapPress.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapPress];
    //
    self.descriptionLabel.hidden = YES;
}


// gesture recognizier事件处理
- (IBAction)handleStartAction:(id)sender {
    
    //
    self.isStart = !self.isStart;
    
    if (self.isStart) {
        
        // 开启定时
        /**
         * 问题：暂停后，定时从0开始，应该继续最好
           解决：
         */
        [self startUpdateTimeAndLocation];
        // 开启定位
        [self.locationManager startUpdatingLocation];
        
    } else {
       
        [self stopUpdateTimeAndLocation];
        [self.locationManager stopUpdatingLocation];//停止定位
        
    }

}


// save button事件处理
- (IBAction)handleSaveAction:(id)sender {
    
    // 保存run数据
    if (self.distance > 0) {
        [self saveRun];
    }
}


//MARK: helper mothod
// 计时开始、定位开始
- (void)startUpdateTimeAndLocation{
    
    // 开启定时
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:true];
    self.ziroTime = [NSDate timeIntervalSinceReferenceDate];
    
    //
    self.stopDate = [NSDate date];//设置stopDate初始值
    
    // 开启定位
    //[self.locationManager startUpdatingLocation];
    
    // 交换button显示内容
    [self.startButton setTitle:@"停止" forState:UIControlStateNormal];
}

// 计时暂停、定位停止
- (void)stopUpdateTimeAndLocation{
    
    [self.timer invalidate];//停止计时
    //[self.locationManager stopUpdatingLocation];//停止定位
    [self.startButton setTitle:@"开始" forState:UIControlStateNormal];
}

// 计时及显示计时时间
- (void)updateTime{
    
    // 统计总时长
    //self.seconds ++;
    
    // 计算定时时间并转换为秒、分、时，转换为字符串
//    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];//
//    NSTimeInterval passedTime = currentTime - self.ziroTime ;//流逝时间
    
    // 使用self.seconds来作为总的计时时间（暂停、开始可以继续计时，不会从0开始）
    self.seconds ++;
    NSTimeInterval passedTime = self.seconds;
    
    //passedTime += 3700;// for test
    //NSLog(@"passed time:%f", passedTime);
    int hours = passedTime / 3600;
    //NSLog(@"hours:%d", hours);
    passedTime -= hours * 3600;
    int minutes = passedTime / 60;
    //NSLog(@"minutes:%d", minutes);
    passedTime -= minutes * 60;
    int seconds = passedTime;
    //NSLog(@"passedTime:%f", passedTime);
    //NSLog(@"self.seconds:%d", self.seconds);
    
    NSString *stringHours = [NSString stringWithFormat:@"%02d", hours];
    NSString *stringMinutes = [NSString stringWithFormat:@"%02d", minutes];
    NSString *stringSeconds = [NSString stringWithFormat:@"%02d", seconds];
    
    // 显示计时
    /**
     * 问题：数字变化时，能看到变化效果???
     */
    //self.timeLabel.text = [NSString stringWithFormat:@"%@:%@:%@", stringHours, stringMinutes, stringSeconds];
    //self.hoursLabel.text = stringHours;
    //self.minutesLabel.text = stringMinutes;
    //self.secondsLabel.text = stringSeconds;
    
    
    // 处理自动暂停（主要针对开始时，位置未变化情况）
    //[self performSelector:@selector(handleStartAction:)];
//    NSTimeInterval lastStopInterval = [self.stopDate timeIntervalSince1970];
//    NSDate *currentDate = [NSDate date];
//    NSTimeInterval currentInterval = [currentDate timeIntervalSince1970];
//    NSTimeInterval stopInterval = currentInterval - lastStopInterval;
//    NSLog(@"self.stopDate:%@ currentDate:%@", self.stopDate, currentDate);
//    NSLog(@"lastStopInterval:%f currentInterval:%f stopInterval:%f", lastStopInterval, currentInterval, stopInterval);
//    
//    if (stopInterval > 10 && self.lastLocation == nil) {
//        
//        //
//        self.stopDate = [NSDate date];// 设置停止时的时间点
//        NSLog(@"self.stopDate:%@", self.stopDate);
//        self.isStart = NO;
//        [self stopUpdateTimeAndLocation];
//        //[self performSelector:@selector(handleStartAction:)];//闪退？？？
//        
//        //
//        NSLog(@"self.sconds >= 10");
//        UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"Notice" message:@"self.seconds>=10 Location not changed!" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *alerAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//        [alerVC addAction:alerAction];
//        [self presentViewController:alerVC animated:YES completion:nil];
//    }
}




// double tap gesture recognizer 事件处理
- (void)handleDoubleTapPress:(UIGestureRecognizer *)gestureRecgnizer{
    
    //NSLog(@"double");
    
    self.descriptionLabel.hidden = self.descriptionLabel.hidden ? NO : YES;
}


// 保存数据
- (void)saveRun{
    //
    NSLog(@"Activity:saveRun");
    
    // 获取managedObjectContext
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    // 创建Run实体
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    
    newRun.distance = [NSNumber numberWithFloat:self.distance];//
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    /**
     * 说明：此处不用将date转换为系统时间，因为显示时间字符串时，NSDateFormatter自动以系统时间作为参考，转换为系统时间
     */
    newRun.timestamp = [NSDate date];//此时间时间为UTC时间，和系统时间差8小时
    //newRun.timestamp = [self convertDateToLocalDate:[NSDate date]];
    NSLog(@"save run;date:%@, convert:%@", [NSDate date], newRun.timestamp);
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        
        // 创建Location实体
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = @(location.coordinate.latitude);
        locationObject.longitude = @(location.coordinate.longitude);
        locationObject.speed = @(location.speed);
        locationObject.course = @(location.course);
        locationObject.horizontalAccuracy = @(location.horizontalAccuracy);
        locationObject.verticalAccuracy = @(location.verticalAccuracy);
        [locationArray addObject:locationObject];
    }
    
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    // save the context
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}



// 将date转换成当前系统时区的时间
- (NSDate *)convertDateToLocalDate:(NSDate *)date{
    
    /**
     * 说明：将UTC时间转换为系统时间
     */
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger interval = [timeZone secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:interval];
    
    return localDate;
}


//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"RunDetail"]) {
        
        // 跳转到详情页
        /**
         * 说明：seugeactivityVC直接指向的navigationVC，detaiVC嵌入在其中，
         */
        UINavigationController *nav = segue.destinationViewController;
        DetailViewController *detailVC = nav.childViewControllers.firstObject;
        detailVC.run = self.run;
    }
    
}


// MARK:CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"didUpdateLocations:/* *********************************************/");
    
    // 启动后，先把当前位置装进self.locations
//    if (self.locations.count == 0) {
//        [self.locations addObject:[locations lastObject]];
//    }
    
    //
    NSLog(@"locations description:%@", locations.description);
    NSLog(@"locations count:%lu", (unsigned long)[locations count]);
    NSLog(@"self.locations:%@", self.locations);
    NSLog(@"self.lastLocation:%@", self.lastLocation);
    NSLog(@"self.allUpdateLocations:%@", self.allUpdateLocations);
    
    
    // 存储location数据（不是所有数据都有，有一定的过滤），计算移动距离
    for (CLLocation *newLocation in locations) {
        
        // 存储所有收到的location数据
        [self.allUpdateLocations addObject:newLocation];
        NSLog(@"newLocation:%@", newLocation);
        
        // 调试label
        self.descriptionLabel.text = [NSString stringWithFormat:@"Location:\n latitude:%f\n longitude:%f\n altitude:%f\n hAccuracy:%f\n vAccuracy:%f\n course:%f\n speed:%f\n timetamp:%@\n floor:%@\n self.locations.count:%lu\n self.allLocations.count:%lu\n self.lastLocation:%@", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.altitude, newLocation.horizontalAccuracy, newLocation.verticalAccuracy, newLocation.course, newLocation.speed, newLocation.timestamp, newLocation.floor, (unsigned long)self.locations.count, (unsigned long)self.allUpdateLocations.count, self.lastLocation];
        
        
        // 过滤location数据（满足条件的才存储）
        /**
         * 说明：有效的位置：水平精度小于20、速度大于0
         */
        if (newLocation.horizontalAccuracy < 20 && newLocation.speed > 0) {
            NSTimeInterval sinceNow = [newLocation.timestamp timeIntervalSinceNow];
            NSLog(@"sinceNow:%f", sinceNow);
            
            if (self.locations.count > 0) {
                // 更新距离
                CGFloat distance = [newLocation distanceFromLocation:[self.locations lastObject]];//最新位置和上一位置间的距离间隔
                self.distanceTraveled += distance;
                self.distance = self.distanceTraveled;
                
            }
            
            // 存储位置信息
            [self.locations addObject:newLocation];
            NSLog(@"self.locatons count:%lu", (unsigned long)[self.locations count]);
            
        }
        
        // 自动暂停-恢复（当运动停止时）
        
        if (self.locations.count != 0) {
            
            NSTimeInterval lastLocationInterval = [self.lastLocation.timestamp timeIntervalSince1970];
            CLLocation *lastLocationInAll = [self.allUpdateLocations lastObject];
            NSTimeInterval lastLocationInAllInterval = [lastLocationInAll.timestamp timeIntervalSince1970];
            NSTimeInterval timeInterval = lastLocationInAllInterval - lastLocationInterval;
            
            if (timeInterval > 10 && !(lastLocationInAll.speed > 0)) {
                NSLog(@"timeInterval:%f", timeInterval);
                
                if (self.paused) {
                    return;
                }
                
                //self.isStart = NO;//暂停但不是停止，停止时设置isStart
                // 暂停定时
                [self stopUpdateTimeAndLocation];//暂停计时
                self.paused = YES;
                //
                UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Cycling paused: Location changing" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alerAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alerVC addAction:alerAction];
                [self presentViewController:alerVC animated:YES completion:nil];
                
            } else {
                
                if (self.paused) {
                    // 采用此种条件，启动有些快
                    if (newLocation.speed > 0 && self.lastLocation.speed > 0) {
                        // 开启定时
                        [self startUpdateTimeAndLocation];
                        self.paused = NO;
                        //
                        UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Cycling resumed: Location changing!" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *alerAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                        [alerVC addAction:alerAction];
                        [self presentViewController:alerVC animated:YES completion:nil];
                    }
                }
                
            }
        }
        
        
        
        
        
        
        
    }
    
    // 显示计算后的信息
    self.lastLocation = [self.locations lastObject];
    
    // 显示距离
    self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f", self.distanceTraveled / 1000];//距离转换为千米
    // 显示瞬时速度
    CGFloat currentSpeed = self.lastLocation.speed * 3.8;//瞬时速度：Km／h
    currentSpeed = ABS(currentSpeed);// 取绝对值
    self.averageSpeedLabel.text = [NSString stringWithFormat:@"%0.2f", (self.lastLocation.speed > 0) ? currentSpeed: 0];
    
    // 隐藏调试label
    /**
     CLLocationCoordinate2D coordinate;     //经纬度坐标
     CLLocationDistance altitude;           //海拔
     CLLocationAccuracy horizontalAccuracy; //水平精度(水平误差范围)
     CLLocationAccuracy verticalAccuracy;   //垂直精度
     CLLocationDirection course             //方向
     CLLocationSpeed speed                  //瞬时速度
     NSDate *timestamp;                     //时间戳（获取位置信息时的时间）
     CLFloor *floor                         //
     NSString *description;                 //
     */
    //self.descriptionLabel.text = [NSString stringWithFormat:@"Location:\n latitude:%f\n longitude:%f\n altitude:%f\n hAccuracy:%f\n vAccuracy:%f\n course:%f\n speed:%f\n timetamp:%@\n floor:%@", self.lastLocation.coordinate.latitude, self.lastLocation.coordinate.longitude, self.lastLocation.altitude, self.lastLocation.horizontalAccuracy, self.lastLocation.verticalAccuracy, self.lastLocation.course, self.lastLocation.speed, self.lastLocation.timestamp, self.lastLocation.floor];
    
    // 平均速度：Km／h
    //CGFloat tempPace = (self.distance / 1000) / ((CGFloat)self.seconds / 3600);
    //NSLog(@"tempPace:%f", tempPace);
    
}

// 自动暂停
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager{
    NSLog(@"locationManagerDidPauseLocationUpdates");
    self.descriptionLabel.text = @"locationManagerDidPauseLocationUpdates";
    
}

// 自动恢复
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager{
    NSLog(@"locationManagerDidResumeLocationUpdates");
    self.descriptionLabel.text = @"locationManagerDidResumeLocationUpdates";
}






@end
