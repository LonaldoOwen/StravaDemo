//
//  MapViewController.m
//  StravaDemo
//
//  Created by owen on 16/6/4.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "KCAnnotation.h"
#import "KCUserLocation.h"
#import "customButtonRun.h"
#import "SavingDataViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface MapViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;//旧mapView

@property (weak, nonatomic) IBOutlet MKMapView *secondMapView;
@property (weak, nonatomic) IBOutlet UIView *customNavigationBar;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (strong, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *speedView;

@property (strong, nonatomic) IBOutlet UIView *settingView;
@property (strong, nonatomic) IBOutlet UIView *stopView;
@property (weak, nonatomic) IBOutlet customButtonRun *runButton;
@property (strong, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UILabel *indicatorLabel;
@property (weak, nonatomic) IBOutlet UIView *locationUpdateView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;


@property (weak, nonatomic) IBOutlet UILabel *timeLabel;            // 旧的timeView显示计时的label
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *pauseTimeLabel;       // 停止时stopView显示计时的label
@property (weak, nonatomic) IBOutlet UILabel *pauseSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *pauseDistanceLabel;


@property (strong, nonatomic) customButtonRun *doneButton;


@property (assign, nonatomic) BOOL stoped;
@property (assign, nonatomic) BOOL showMap;

// 位置相关
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (nonatomic) CGFloat distanceTraveled;

// 计时相关
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSTimeInterval ziroTime;
@property (strong, nonatomic) NSDate *stopDate;
@property int seconds;//
@property CGFloat distance;//
//@property (assign, nonatomic) BOOL isStart;
//@property (assign, nonatomic) BOOL paused;

// 数组
@property (strong, nonatomic) NSMutableArray *locations;//存过滤的位置
@property (strong, nonatomic) NSMutableArray *allUpdateLocations;//存所有的位置

// test
@property (nonatomic) NSUInteger index;
@property (strong, nonatomic) UIView *testNavigationView;


@end




@implementation MapViewController


- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
        NSLog(@"item...");
    }
    
    return self;
}

- (void)setUp{
    
    //
    //UIImage *image = [UIImage imageNamed:@"z_tabbar_find_normal"];
    //UIImage *image = [UIImage imageNamed:@"z_tabbar_me_normal"];
    //image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"Run" image:image tag:2];
    //self.tabBarItem = item;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //self.navigationController.navigationBar.translucent = NO;
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:32.0/255 green:32.0/255 blue:32.0/255 alpha:1.0];
    //self.title = @"Run";
    
    // 设置地图
    [self setUpMapView];
    self.mapView.hidden = YES;
    
    // add timeView as subview
    [self addTimeView];
    
    // 设置标志变量
    self.stoped = YES;
    self.showMap = NO;
    
    self.mapButton.hidden = YES;
    
    
    // 设置位置
    [self setUpLocation];
    
    // 添加双击手势，显示位置变化数据
    [self addGesture];
    
    // 注册通知（接收来自SavingDataViewController的通知）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationFromSavingVC:) name:@"NotificationToMapVC" object:nil];
    
    
}

- (void)viewDidLayoutSubviews{
    
    //
    NSLog(@"viewDidLayoutSubviews");
}


// 处理通知事件
- (void)handleNotificationFromSavingVC:(NSNotification *)notification{
    NSLog(@"receive notification");
    
    NSDictionary *passDic = [notification userInfo];
    NSString *passValue = [passDic objectForKey:@"value"];
    
    if ([passValue isEqualToString:@"dismissMapVC"]) {
        
        [self performSelector:@selector(closeMapVC:) withObject:nil];
        
    } else if ([passValue isEqualToString:@"resumeRun"]){
    
        [self performSelector:@selector(clickRunButtonAction:) withObject:nil];
        
    }
}



// 添加gesture recognizer（double tap）
- (void)addGesture{
    
    // 添加隐藏手势：显示定位数据
    UITapGestureRecognizer *doubleTapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapPress:)];
    doubleTapPress.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapPress];
    //
    self.locationUpdateView.hidden = YES;
}

// double tap gesture recognizer 事件处理
- (void)handleDoubleTapPress:(UIGestureRecognizer *)gestureRecgnizer{
    
    //NSLog(@"double");
    
    self.locationUpdateView.hidden = self.locationUpdateView.hidden ? NO : YES;
}



- (IBAction)closeMapVC:(id)sender {
    NSLog(@"closeMapVC:");
    
    /**
     *  说明：present 出的VC，使用unwind segue不起作用？？？
     */
    //
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)close:(UIStoryboardSegue *)segue{
    
}


- (IBAction)clickRunButtonAction:(id)sender {
    
    /**
     * 说明：run button同时负责计时页面的动画和停止提示条的设置
     */
    
    //
    CGFloat frameW = CGRectGetWidth(self.customNavigationBar.frame);
    CGFloat frameH = CGRectGetHeight(self.customNavigationBar.frame);
    CGRect fromFrameOfIndicatorView = CGRectMake(0, frameH - 20, frameW, 20);
    CGRect toFrameOfIndicatorView = CGRectMake(0, frameH, frameW, 20);
    
    if (self.stoped) {
        
        // 切换run button显示图
        [self.runButton setBackgroundImage:[UIImage imageNamed:@"btn_stop"] forState:UIControlStateNormal];
        
        // 显示mapButton
        self.mapButton.hidden = NO;
        [self.mapButton addTarget:self action:@selector(clickMapButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        
        //
        CGRect fromFrame = self.timeView.frame;
        CGRect toFrame = fromFrame;
        toFrame.origin.y = 0;
        
        //
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            
            if (self.doneButton == nil) {
                // 隐藏导航栏
                [self hideNavigationBar];
            }
            
            // timeView出现动画
            self.timeView.frame = toFrame;
            // done button隐藏动画
            if (self.doneButton != nil && !self.doneButton.hidden) {
                [self hideDoneButtonAnimation];
            }
            // 隐藏停止提示条
            self.indicatorView.frame = fromFrameOfIndicatorView;
            
        } completion:^(BOOL finished) {
            
            // 添加done button
            if ([self.doneButton superview] == nil) {
                
                self.doneButton = [[customButtonRun alloc] init];
                CGRect doneButtonFrame = self.runButton.frame;
                //doneButtonFrame.origin.x += 50;
                self.doneButton.frame = doneButtonFrame;
                //[self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
                [self.doneButton setBackgroundImage:[UIImage imageNamed:@"btn_finish"] forState:UIControlStateNormal];
                [self.doneButton addTarget:self action:@selector(clickDoneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                //self.doneButton.showsTouchWhenHighlighted = YES;//点击时闪烁
                if ([self.doneButton superview] == nil) {
                    [self.controlView insertSubview:self.doneButton belowSubview:self.runButton];
                }
                self.doneButton.hidden = YES;
            }
            // indicatorView从父view中移除
            //[self.indicatorView removeFromSuperview];
            
            // 开始计时，定位
            [self startUpdateTimeAndLocation];
            [self.locationManager startUpdatingLocation];

            
        }];
        
        
    } else {
        
        // 停止
        // 切换run button 图片
        [self.runButton setBackgroundImage:[UIImage imageNamed:@"btn_run"] forState:UIControlStateNormal];
        
        // 停止计时，定位
        [self stopUpdateTimeAndLocation];
        [self.locationManager stopUpdatingLocation];
        
        //
        CGRect fromFrame = self.timeView.frame;
        CGRect toFrame = fromFrame;
        toFrame.origin.y = fromFrame.size.height - 90;
        
        self.stopView.hidden = NO;
        //NSLog(@"self.controlView.subviews:%@", self.controlView.subviews);
        
        /**
         * 说明：
           问题：在此处添加indicatorView到自定义导航栏，停止时导航栏直接显示（原因？？？）
           解决：mapView加载时就将indicatorView直接添加到导航栏上，只添加一次，不移除（暂时可行）
         */
        //
        //[self.customNavigationBar insertSubview:self.indicatorView atIndex:0];
        //[self.customNavigationBar addSubview:self.indicatorView];
        self.indicatorView.frame = fromFrameOfIndicatorView;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            // timeview隐藏动画
            self.timeView.frame = toFrame;
            // done button显示动画
            [self showDoneButtonAnimation];
            // 显示停止提示条
            self.indicatorView.frame = toFrameOfIndicatorView;
            
        } completion:^(BOOL finished) {
            //
            NSLog(@"after animation customNavigationBar:%@", NSStringFromCGRect(self.customNavigationBar.frame));

        }];
        
        
    }
    
    //
    self.stoped = !self.stoped;
}

- (void)clickMapButtonTouchDown:(id)sender {
    // touchDown
    NSLog(@"clickMapButtonTouchDown");
    
    //
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeScale(0.6, 0.6);
    
    [UIView animateWithDuration:0.3 animations:^{
        
        //
        self.mapButton.transform = transform;
        
    }];
    
}


- (IBAction)clickMapButton:(id)sender {
    // touchUpInsight
    NSLog(@"clickMapButton:");
    
    CGRect fromFrame ;
    CGRect toFrame ;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeScale(1.0, 1.0);

    
    //
    if (!self.showMap) {
        
        // 显示mapView
        fromFrame = self.timeView.frame;
        toFrame = fromFrame;
        toFrame.origin.x = -fromFrame.size.width;
        
        //
        //transform = CGAffineTransformMakeScale(0.5, 0.5);
        
    } else {
        
        // 遮蔽mapView
        fromFrame = self.timeView.frame;
        toFrame = fromFrame;
        toFrame.origin.x = 0;
        
        //
        //transform = CGAffineTransformIdentity;
    }
    
    //
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        
        // mapButton点击动画
        self.mapButton.transform = transform;
        // 显示mapView动画
        self.timeView.frame = toFrame;
        // 隐藏导航栏
        [self hideNavigationBar];
        
    } completion:^(BOOL finished) {
        
        if (self.showMap) {
            
            // 显示导航栏
            //self.customNavigationBar.hidden = NO;
            [self showNavigationBar];
        }
        
        // mapButton恢复动画
        //[UIView animateWithDuration:0.3 animations:^{
            //
        //    self.mapButton.transform = CGAffineTransformIdentity;
            
        //}];
        
        
    }];
    
    self.showMap = !self.showMap;
    
}

- (IBAction)clickLogButton:(id)sender {
    
    //
    NSLog(@"customNavigationBar:%@", NSStringFromCGRect(self.customNavigationBar.frame));
    NSLog(@"customNavigationBar.subviews:%@", self.customNavigationBar.subviews);
    
    // 验证计时label计时时，导航栏自动归位(通过看是否调用了viewDidLayoutSubviews方法)
    // yes
    //self.timeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.index];
    //self.index++;
    // yes
    //[self.runButton setTitle:@"Test" forState:UIControlStateHighlighted];
    
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    testView.backgroundColor = [UIColor orangeColor];
    // yes
    //[self.view addSubview:testView];
    // no
    //[self.timeView addSubview:testView];
    // no
    //[self.controlView addSubview:testView];
    // no
    //[self.view layoutIfNeeded];
    
    // 验证手动调用button的selector
    //[self performSelector:@selector(clickRunButtonAction:) withObject:nil];
    [self performSelector:@selector(closeMapVC:) withObject:nil];
    
}


// MARK:helper mothed

//
- (void)addTimeView{
    
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    
    // add customNavigationView
    CGRect navigationFrame = CGRectMake(0, 0, screenWidth, 80);
    self.customNavigationBar.frame = navigationFrame;
    [self.view insertSubview:self.customNavigationBar belowSubview:self.controlView];
    
    // add timeView to self.view
    CGRect timeViewFrame = self.view.frame;
    timeViewFrame.origin.y = screenHeight - 90.0;
    self.timeView.frame = timeViewFrame;
    //[self.view addSubview:self.timeView];
    [self.view insertSubview:self.timeView belowSubview:self.controlView];
    
    // add settingView to timeView
    CGFloat settingViewHeight = 44.0;
    CGRect settingViewFrame = CGRectMake(0, -settingViewHeight, screenWidth, settingViewHeight);
    self.settingView.frame = settingViewFrame;
    [self.timeView addSubview:self.settingView];
    
    // add stopView to timeView
    CGFloat stopViewHeight = 0.5 * screenHeight;
    CGRect stopViewFrame = CGRectMake(0, - (stopViewHeight + settingViewHeight), screenWidth, stopViewHeight);
    self.stopView.frame = stopViewFrame;
    [self.timeView addSubview:self.stopView];
    self.stopView.hidden = YES;
    
    // add indicatorView to customNavigationBar
    [self.customNavigationBar insertSubview:self.indicatorView atIndex:0];
    
    // test
    self.testNavigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 60)];
    self.testNavigationView.backgroundColor = [UIColor orangeColor];
    //[self.view insertSubview:self.testNavigationView aboveSubview:self.secondMapView];
}

// hide navigationBar
- (void)hideNavigationBar{
    
    CGRect fromFrame = self.customNavigationBar.frame;
    CGRect toFrame = fromFrame;
    toFrame.origin.y = - fromFrame.size.height - 20;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionOverrideInheritedDuration animations:^{
        //
        self.customNavigationBar.frame = toFrame;
        // test
        //self.testNavigationView.frame = toFrame;
        
    } completion:^(BOOL finished) {
        //
    }];
}

// show navigationBar
- (void)showNavigationBar{
    
    CGRect fromFrame = self.customNavigationBar.frame;
    CGRect toFrame = fromFrame;
    toFrame.origin.y = 0;
    
    //[self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionOverrideInheritedDuration animations:^{
        //
        self.customNavigationBar.frame = toFrame;
    } completion:^(BOOL finished) {
        //
    }];
}


// show done button animation
- (void)showDoneButtonAnimation{
    
    if (self.doneButton.hidden) {
        self.doneButton.hidden = NO;

    }
    
    CGRect fromFrameOfRunButton = self.runButton.frame;
    CGRect toFrameOfRunButton = fromFrameOfRunButton;
    toFrameOfRunButton.origin.x -= 50;
    
    CGRect fromFrameOfDoneButton = self.doneButton.frame;
    CGRect toFrameOfDoneButton = fromFrameOfDoneButton;
    toFrameOfDoneButton.origin.x += 50;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionOverrideInheritedDuration animations:^{
        //
        self.runButton.frame = toFrameOfRunButton;
        self.doneButton.frame = toFrameOfDoneButton;
        
    } completion:^(BOOL finished) {
        //
    }];
}

// hide done button animation
- (void)hideDoneButtonAnimation{
    
    CGRect fromFrameOfRunButton = self.runButton.frame;
    CGRect toFrameOfRunButton = fromFrameOfRunButton;
    toFrameOfRunButton.origin.x += 50;
    
    CGRect fromFrameOfDoneButton = self.doneButton.frame;
    CGRect toFrameOfDoneButton = fromFrameOfDoneButton;
    toFrameOfDoneButton.origin.x -= 50;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionOverrideInheritedDuration animations:^{
        //
        self.runButton.frame = toFrameOfRunButton;
        self.doneButton.frame = toFrameOfDoneButton;
        
    } completion:^(BOOL finished) {
        // done button隐藏后从父view移除
        //[self.doneButton removeFromSuperview];
        self.doneButton.hidden = YES;
        
    }];
}

// 点击done button跳转存储VC
- (void)clickDoneButtonAction:(id)sender{

    NSLog(@"Click done button");
    
    // VC在storyboard中嵌入到navigation controller，使用此方法转场
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"SavingDataVCNC"];
    [self presentViewController:nav animated:YES completion:nil];
    
    //
    NSLog(@"navigationController.viewControllers:%@", nav.viewControllers);
    SavingDataViewController *savingDataVC = [nav.viewControllers firstObject];
    savingDataVC.distance = self.distance;
    savingDataVC.seconds = self.seconds;
    savingDataVC.locations = self.locations;
}


//
- (void)setUpMapView{
    
    self.secondMapView.delegate = self;
    

    // 地图类型
    self.secondMapView.mapType = MKMapTypeStandard;
    
    // 显示用户位置
    [self showUserLocation];
    
    
    // 大头针
//    CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(39.915352,116.397105);
//    KCAnnotation *annotation1 = [[KCAnnotation alloc] init];
//    annotation1.coordinate = location1;
//    annotation1.title = @"title:";
//    annotation1.subtitle = @"subtitle:";
//    [self.mapView addAnnotation:annotation1];
    
    // add another userLocation
    //CLLocationCoordinate2D location2 = CLLocationCoordinate2DMake(39.95, 116.35);
//    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:39.95 longitude:116.35];
//    KCUserLocation *otherUser = [[KCUserLocation alloc] init];
//    otherUser.location = location2;
//    [self.mapView addAnnotation:otherUser];
    
    
    // add overlay
    // 矩形
//    CLLocationCoordinate2D points[4];
//    
//    points[0] = CLLocationCoordinate2DMake(41.000512, -109.050116);
//    points[1] = CLLocationCoordinate2DMake(41.002371, -102.052066);
//    points[2] = CLLocationCoordinate2DMake(36.993076, -102.041981);
//    points[3] = CLLocationCoordinate2DMake(36.99892, -109.045267);
//    
//    MKPolygon* poly = [MKPolygon polygonWithCoordinates:points count:4];
//    poly.title = @"Calorado";
// 
//    [self.mapView addOverlay:poly];
    
    
    // 线型overlay
    
//    CLLocationCoordinate2D points[2];
//    
//    points[0] = CLLocationCoordinate2DMake(39.915352,116.397105);
//    points[1] = CLLocationCoordinate2DMake(39.13, 117.20);
//    
//    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:points count:2];
//    polyLine.title = @"Line";
//    
//    [self.mapView addOverlay:polyLine];
//    
//    // 设置地图显示区域（缩放比例）
//    //CLLocationCoordinate2D coordintae = CLLocationCoordinate2DMake(39.915352,116.397105);
//    //MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
//    
//    MKCoordinateRegion region;
//    
//    region.center.latitude = (points[1].latitude + points[0].latitude) / 2.0f;
//    region.center.longitude = (points[1].longitude + points[0].longitude) / 2.0f;
//    /**
//     * 往往设置latitudeDela决定了显示范围？？？（不对）
//     */
//    region.span.latitudeDelta = (points[0].latitude - points[1].latitude) * 1.5f;
//    region.span.longitudeDelta = (points[1].longitude - points[0].longitude) * 1.5f;
//    
//    self.mapView.region = region;

    
    //
    //MKCircle *circlePoly =;
    
    
}

// 追踪用户位置
- (void)showUserLocation{
    
    self.secondMapView.showsUserLocation = YES;
    self.secondMapView.userTrackingMode = MKUserTrackingModeFollow;
}


// set up location
- (void)setUpLocation{
    
    // 实例化locationManager对象
    self.locationManager = [[CLLocationManager alloc] init];
    // 申请试用位置功能
    [self.locationManager requestWhenInUseAuthorization];
    // 设置运行后台运行
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    // 设置代理
    self.locationManager.delegate = self;
    // 基本配置
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.startLocation = nil;//起始位置
    self.lastLocation = nil;//上一位置
    self.distanceTraveled = 0.0;//移动距离
    self.locations = [NSMutableArray array];//存放location
    
}


// 计时开始、定位开始
- (void)startUpdateTimeAndLocation{
    
    // 开启定时
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatingTime) userInfo:nil repeats:true];
    self.ziroTime = [NSDate timeIntervalSinceReferenceDate];
    
    //
    self.stopDate = [NSDate date];//设置stopDate初始值
    
    // 开启定位
    //[self.locationManager startUpdatingLocation];
    
    // 交换button显示内容
    //[self.runButton setTitle:@"Stop" forState:UIControlStateNormal];
}

// 计时暂停、定位停止
- (void)stopUpdateTimeAndLocation{
    
    [self.timer invalidate];//停止计时
    //[self.locationManager stopUpdatingLocation];//停止定位
    //[self.runButton setTitle:@"Run" forState:UIControlStateNormal];
    //
    //self.pauseTimeLabel.text = self.timeLabel.text;
    self.pauseSpeedLabel.text = self.speedLabel.text;
    self.pauseDistanceLabel.text = self.distanceLabel.text;
}

// 计时及显示计时时间
- (void)updatingTime{
    
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
    int hoursTen = hours / 10;
    int hoursOne = hours % 10;
    //NSLog(@"hours:%d", hours);
    passedTime -= hours * 3600;
    int minutes = passedTime / 60;
    int minutesTen = minutes / 10;
    int minutesOne = minutes % 10;
    //NSLog(@"minutes:%d", minutes);
    passedTime -= minutes * 60;
    int seconds = passedTime;
    int secondsTen = seconds / 10;
    int secondsOne = seconds % 10;
    //NSLog(@"passedTime:%f", passedTime);
    //NSLog(@"self.seconds:%d", self.seconds);
    
    NSString *stringHours = [NSString stringWithFormat:@"%02d", hours];
    NSString *stringMinutes = [NSString stringWithFormat:@"%02d", minutes];
    NSString *stringSeconds = [NSString stringWithFormat:@"%02d", seconds];
    
    // 显示计时
    /**
     * 问题：数字变化时，能看到变化效果???
       解决：拆分时、分、秒，使每个数字使用一个label；设置约束，或者使用stack view，设置distribution为full equally
     */
    // 为了让pauseTimelabel可以显示
    //self.timeLabel.text = [NSString stringWithFormat:@"%@:%@:%@", stringHours, stringMinutes, stringSeconds];
    self.pauseTimeLabel.text = [NSString stringWithFormat:@"%@:%@:%@", stringHours, stringMinutes, stringSeconds];
    //self.hoursLabel.text = stringHours;
    //self.minutesLabel.text = stringMinutes;
    //self.secondsLabel.text = stringSeconds;
//    UILabel *hoursLabel = [self.timeView viewWithTag:11];
//    UILabel *minutesLabel = [self.timeView viewWithTag:12];
//    UILabel *secondsLabel = [self.timeView viewWithTag:13];
    
//    hoursLabel.text = [NSString stringWithFormat:@"%@", stringHours];
//    minutesLabel.text = [NSString stringWithFormat:@"%@", stringMinutes];
//    secondsLabel.text = [NSString stringWithFormat:@"%@", stringSeconds];
    
    // 拆分为每个数字一个label；获取label并设置数据
    UILabel *label = nil;
    
    label = [self.timeView viewWithTag:11];
    label.text = [NSString stringWithFormat:@"%d", hoursTen];
    label = [self.timeView viewWithTag:12];
    label.text = [NSString stringWithFormat:@"%d", hoursOne];
    
    label = [self.timeView viewWithTag:21];
    label.text = [NSString stringWithFormat:@"%d", minutesTen];
    label = [self.timeView viewWithTag:22];
    label.text = [NSString stringWithFormat:@"%d", minutesOne];
    
    label = [self.timeView viewWithTag:31];
    label.text = [NSString stringWithFormat:@"%d", secondsTen];
    label = [self.timeView viewWithTag:32];
    label.text = [NSString stringWithFormat:@"%d", secondsOne];




    
    
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





//#MARK:MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    //
    //NSLog(@"didUpdateUserLocation;userLocation:%@", userLocation);
    
    //
//    CLLocationCoordinate2D coordinate = userLocation.coordinate;
//    [self.mapView setCenterCoordinate:coordinate];
    
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    //
    NSLog(@"rendererForOverlay");

    // 矩形overlay
//    if ([overlay isKindOfClass:[MKPolygon class]]) {
//        MKPolygonRenderer *aRenderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
//        aRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
//        aRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
//        aRenderer.lineWidth = 3;
//        
//        return aRenderer;
//    }
    
    // 线型overlay
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *lineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        
        lineRenderer.fillColor = [UIColor blueColor];
        lineRenderer.strokeColor = [UIColor redColor];
        lineRenderer.lineWidth = 5;
        
        return lineRenderer;
    }
    
    //
    
    
    return nil;
}


// MARK:CLLocationManagerDelegate
// 位置更新
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"didUpdateLocations:/* *********************************************/");
    
    // 启动后，先把当前位置装进self.locations
    //    if (self.locations.count == 0) {
    //        [self.locations addObject:[locations lastObject]];
    //    }
    
    //
    //NSLog(@"locations description:%@", locations.description);
    //NSLog(@"locations count:%lu", (unsigned long)[locations count]);
    //NSLog(@"self.locations:%@", self.locations);
    //NSLog(@"self.lastLocation:%@", self.lastLocation);
    //NSLog(@"self.allUpdateLocations:%@", self.allUpdateLocations);
    
    
    // 存储location数据（不是所有数据都有，有一定的过滤），计算移动距离
    for (CLLocation *newLocation in locations) {
        
        // 存储所有收到的location数据
        [self.allUpdateLocations addObject:newLocation];
        //NSLog(@"newLocation:%@", newLocation);
        
        // 调试label
        self.descriptionTextView.text = [NSString stringWithFormat:@"Location:\n latitude:%f\n longitude:%f\n altitude:%f\n hAccuracy:%f\n vAccuracy:%f\n course:%f\n speed:%f\n timetamp:%@\n floor:%@\n self.locations.count:%lu\n self.allLocations.count:%lu\n self.lastLocation:%@", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.altitude, newLocation.horizontalAccuracy, newLocation.verticalAccuracy, newLocation.course, newLocation.speed, newLocation.timestamp, newLocation.floor, (unsigned long)self.locations.count, (unsigned long)self.allUpdateLocations.count, self.lastLocation];
        
        
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
        
//        if (self.locations.count != 0) {
//            
//            NSTimeInterval lastLocationInterval = [self.lastLocation.timestamp timeIntervalSince1970];
//            CLLocation *lastLocationInAll = [self.allUpdateLocations lastObject];
//            NSTimeInterval lastLocationInAllInterval = [lastLocationInAll.timestamp timeIntervalSince1970];
//            NSTimeInterval timeInterval = lastLocationInAllInterval - lastLocationInterval;
//            
//            if (timeInterval > 10 && !(lastLocationInAll.speed > 0)) {
//                NSLog(@"timeInterval:%f", timeInterval);
//                
//                if (self.paused) {
//                    return;
//                }
//                
//                //self.isStart = NO;//暂停但不是停止，停止时设置isStart
//                // 暂停定时
//                [self stopUpdateTimeAndLocation];//暂停计时
//                self.paused = YES;
//                //
//                UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Cycling paused: Location changing" preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *alerAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//                [alerVC addAction:alerAction];
//                [self presentViewController:alerVC animated:YES completion:nil];
//                
//            } else {
//                
//                if (self.paused) {
//                    // 采用此种条件，启动有些快
//                    if (newLocation.speed > 0 && self.lastLocation.speed > 0) {
//                        // 开启定时
//                        [self startUpdateTimeAndLocation];
//                        self.paused = NO;
//                        //
//                        UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Cycling resumed: Location changing!" preferredStyle:UIAlertControllerStyleAlert];
//                        UIAlertAction *alerAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//                        [alerVC addAction:alerAction];
//                        [self presentViewController:alerVC animated:YES completion:nil];
//                    }
//                }
//                
//            }
//        }
        
        
        
        
        
        
        
    }
    
    // 显示计算后的信息
    self.lastLocation = [self.locations lastObject];
    
    // 显示距离
    self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f", self.distanceTraveled / 1000];//距离转换为千米
    // 显示瞬时速度
    CGFloat currentSpeed = self.lastLocation.speed * 3.8;//瞬时速度：Km／h
    currentSpeed = ABS(currentSpeed);// 取绝对值
    self.speedLabel.text = [NSString stringWithFormat:@"%0.2f", (self.lastLocation.speed > 0) ? currentSpeed: 0];
    
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


// MARK:

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"touches:%@", touches);
    NSLog(@"event:%@", event);
}









@end
