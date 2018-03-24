//
//  DataContainerViewController.m
//  StravaDemo
//
//  Created by owen on 16/5/25.
//  Copyright © 2016年 owen. All rights reserved.
//
/**
 * 功能：主要数据及动画页面
   1、
   2、
 */

#import "DataContainerViewController.h"
#import "WeekDataViewController.h"
#import "Page.h"
#import "Goal.h"
#import "Ride.h"
//#import "Run.h"
#import "Day.h"



@interface DataContainerViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *json;
@property (strong, nonatomic) NSMutableArray *pages;
@property (strong, nonatomic) NSString *pageType;
@property (assign, nonatomic) BOOL isFirstLoad;
@property (strong, nonnull) NSMutableArray *rideDistances;
@property (strong, nonatomic) NSMutableArray *runDistances;
@property (strong, nonatomic) CAShapeLayer *shapeShift;
@property (strong, nonatomic) CAShapeLayer *shapeCurrentPoint;
@property (assign, nonatomic) NSInteger currentPage;
@property (strong, nonatomic) CALayer *pointBackgound;

@property (weak, nonatomic) IBOutlet UIButton *rideButton;
@property (weak, nonatomic) IBOutlet UIButton *runButton;

//@property (strong, nonatomic) UIPageControl *pageControl;




@end

@implementation DataContainerViewController

- (void)viewDidLoad {
    //
    NSLog(@"dataContainerVC:viewDidLoad");
    
    [super viewDidLoad];
    
    //
    self.pageType = @"run";
    self.isFirstLoad = YES;
    self.currentPage = 0;
    self.view.backgroundColor = [UIColor colorWithRed:42.0/255 green:42.0/255 blue:42.0/255 alpha:1.0];
    
    // laod data
    [self loadData];

    // setup scrollView
    [self setUpScrollView];
    self.scrollView.delegate = self;
    
    // setup pageControllView
    [self setUpPageControlView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"DataContainerViewController:viewWillAppear");
}

- (void)viewWillLayoutSubviews{
    
    // 调整启动时track line and point 位置
    CGFloat pageWidth = [UIScreen mainScreen].bounds.size.width;
    CGPoint point = CGPointMake(([self.pages count] - 1) * pageWidth, 0);
    if (self.isFirstLoad) {
        [self.scrollView setContentOffset:point animated:NO];
    }
    
}



- (IBAction)handleButtonTap:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    UIColor *black = [UIColor colorWithRed:32.0/255 green:32.0/255 blue:32.0/255 alpha:1.0];
    UIColor *lightGray = [UIColor colorWithRed:42.0/255 green:42.0/255 blue:42.0/255 alpha:1.0];
    
    if ([button.titleLabel.text isEqualToString:@"Ride"]) {
        NSLog(@"Ride");
        if ([self.pageType isEqual: @"ride"]) {
            return;//点击当前type的button不做任何改变，直接退出
        }
        self.pageType = @"ride";
        self.rideButton.backgroundColor = lightGray;
        self.runButton.backgroundColor = black;
    } else {
        NSLog(@"Run");
        if ([self.pageType isEqualToString:@"run"]) {
            return;
        }
        self.pageType = @"run";
        self.runButton.backgroundColor = lightGray;
        self.rideButton.backgroundColor = black;
    }
    
    // 方法一：重新加载scrollview（试验结果－－可行）
    /**
     * 注意：每次都加载界面会耗费内存，且不释放（应该怎么释放呢？？？）
     * 解决：在加载新的VC前，删除当前VC中上次添加childViewControllers和contentView的subviews（从而达到释放内存目的－－先释放后加载）
     */
    // 释放VC
    for (UIViewController *controller in self.childViewControllers) {
        [controller removeFromParentViewController];
    }
    // 释放contentView
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    // 释放pageControlView的layer的sublayers
    /**
     * 问题：以下移除layer的方法，会造成闪退
       解决：
     */
//    for (CALayer *layer in self.pageControlView.layer.sublayers) {
//        [layer removeFromSuperlayer];
//    }
    
    NSMutableArray *layerArray = [self.pageControlView.layer.sublayers mutableCopy];
    NSArray *tempArray = [NSArray arrayWithArray:layerArray];
    for (CALayer *layer in tempArray) {
        [layer removeFromSuperlayer];
    }
    
    //
    self.isFirstLoad = NO;
    
    // 重新加载页面
    [self setUpScrollView];
    //NSLog(@"self childcontrollers:%@", self.childViewControllers);
    //NSLog(@"self contentview subviews:%@", self.contentView.subviews);
    
    //
    [self setUpPageControlView];
    
    
    //
    
    // 方法二：通过subviews获取WeekDataViewControler中的view（试验结果－－未试验）
//    UIView *pageView = [self.contentView.subviews objectAtIndex:0];
//    UIView *contentView = [pageView.subviews objectAtIndex:0];
//    UILabel *weekLabel = [contentView.subviews objectAtIndex:0];
//    weekLabel.text = @"33";
//    
//    UIView *columnView = [contentView.subviews objectAtIndex:4];
//    Page *page1 = [self.pages objectAtIndex:0];
//    Ride *ride = page1.ride;
//    Ride *run = page1.run;
//    NSArray *toPositionsY = [self caculatePositionYWithDays:run.days];
//    NSArray *fromPositionsY = [self caculatePositionYWithDays:ride.days];
//    
//    for (int i = 0; i < [columnView.layer.sublayers count]; i ++) {
//        CALayer *layer = [columnView.layer.sublayers objectAtIndex:i];
//        NSInteger fromPositionY = [[fromPositionsY objectAtIndex:i] integerValue];
//        NSInteger toPositionY = [[toPositionsY objectAtIndex:i] integerValue];
//        
//        CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.y"];
//        move.duration = 1.0;
//        move.fromValue = @(43 - fromPositionY);
//        move.toValue = @(43 - toPositionY);
//        layer.position = CGPointMake(8 + 20 * i, 43 - toPositionY);
//        [layer addAnimation:move forKey:nil];
//    }
    WeekDataViewController *pageVC = [self.childViewControllers objectAtIndex:0];
    pageVC.pageType = @"";
    
    

}


//
- (void)loadData{
    //
    NSLog(@"load json");
    
    // 获取模版json
    //NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"ProgressGoalSampleWithMoreWeeks" ofType:@"json"];
    
    // 获取实际json
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *fileUrl = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *dataUrl = [fileUrl URLByAppendingPathComponent:@"pages_run.json"];
    NSString *dataPath = [dataUrl path];
    
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    self.json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    //NSLog(@"json:%@", self.json);
    
    self.pages = [NSMutableArray array];
    self.rideDistances = [NSMutableArray array];
    self.runDistances = [NSMutableArray array];
    
    for (NSDictionary *dict in self.json) {
        
        Page *page = [[Page alloc] init];
        
        page.week = [[dict objectForKey:@"week"] integerValue];
        page.year = [[dict objectForKey:@"year"] integerValue];
        
        Ride *ride = [[Ride alloc] init];
        NSDictionary *rideDict = [dict objectForKey:@"ride"];
        ride.distance = [[rideDict objectForKey:@"distance"] integerValue];
        ride.elapsedTime = [[rideDict objectForKey:@"elapsed_time"] integerValue];
        ride.elevationGain = [[rideDict objectForKey:@"elevation_gain"] integerValue];
        ride.movingTime = [[rideDict objectForKey:@"moving_time"] integerValue];
        //ride.goal = [rideDict objectForKey:@"goal"];
        
        //
        /**
         * 注意：不要让下面的内容修改rideGoal内容，否则ride.goal的值也会被修改（因为使用的是指针）
         */
        Goal *rideGoal = [[Goal alloc] init];
        NSDictionary *goalDict = [rideDict objectForKey:@"goal"];
        rideGoal.goal = [[goalDict objectForKey:@"goal"] integerValue];
        rideGoal.type = [goalDict objectForKey:@"type"];
        ride.goal = rideGoal;
        
        NSArray *daysArray = [rideDict objectForKey:@"days"];
        
        NSMutableArray *tempDays = [NSMutableArray array];
        for (NSDictionary *dict in daysArray) {
            Day *day = [[Day alloc] init];
            day.distance = [[dict objectForKey:@"distance"] integerValue];
            day.elapsedTime = [[dict objectForKey:@"elapsed_time"] integerValue];
            day.elevationGain = [[dict objectForKey:@"elevation_gain"] integerValue];
            day.movingTime = [[dict objectForKey:@"moving_time"] integerValue];
            [tempDays addObject:day];
        }
        ride.days = tempDays;
        page.ride = ride;
        [self.rideDistances addObject:@(ride.distance)];//添加ride point数组
        
        // run
        Ride *run = [[Ride alloc] init];
        Goal *runGoal = [[Goal alloc] init];
        NSDictionary *runDict = [dict objectForKey:@"run"];
        run.distance = [[runDict objectForKey:@"distance"] integerValue];
        run.elapsedTime = [[runDict objectForKey:@"elapsed_time"] integerValue];
        run.elevationGain = [[runDict objectForKey:@"elevation_gain"] integerValue];
        run.movingTime = [[runDict objectForKey:@"moving_time"] integerValue];
        
        goalDict = [runDict objectForKey:@"goal"];
        runGoal.goal = [[goalDict objectForKey:@"goal"] integerValue];
        runGoal.type = [goalDict objectForKey:@"type"];
        run.goal = runGoal;
        
        NSArray *runDaysArray = [runDict objectForKey:@"days"];
        NSMutableArray *tempRunArray = [NSMutableArray array];
        for (NSDictionary *dict in runDaysArray) {
            Day *day = [[Day alloc] init];
            day.distance = [[dict objectForKey:@"distance"] integerValue];
            day.elapsedTime = [[dict objectForKey:@"elapsed_time"] integerValue];
            day.elevationGain = [[dict objectForKey:@"elevation_gain"] integerValue];
            day.movingTime = [[dict objectForKey:@"moving_time"] integerValue];
            [tempRunArray addObject:day];
        }
        run.days = tempRunArray;
        page.run = run;
        [self.runDistances addObject:@(run.distance)];//添加run point 数组
        
        //page.type = @"run";
        
        [self.pages addObject:page];
    }
    
    self.pageType = @"ride";
    
}

- (void)setUpScrollView{
    
    //
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;//调整滚动速度

    
    // load page
    WeekDataViewController *page1 = [self loadPageWithData:[self.pages objectAtIndex:11]];
    WeekDataViewController *page2 = [self loadPageWithData:[self.pages objectAtIndex:10]];
    WeekDataViewController *page3 = [self loadPageWithData:[self.pages objectAtIndex:9]];
    WeekDataViewController *page4 = [self loadPageWithData:[self.pages objectAtIndex:8]];
    WeekDataViewController *page5 = [self loadPageWithData:[self.pages objectAtIndex:7]];
    WeekDataViewController *page6 = [self loadPageWithData:[self.pages objectAtIndex:6]];
    WeekDataViewController *page7 = [self loadPageWithData:[self.pages objectAtIndex:5]];
    WeekDataViewController *page8 = [self loadPageWithData:[self.pages objectAtIndex:4]];
    WeekDataViewController *page9 = [self loadPageWithData:[self.pages objectAtIndex:3]];
    WeekDataViewController *page10 = [self loadPageWithData:[self.pages objectAtIndex:2]];
    WeekDataViewController *page11 = [self loadPageWithData:[self.pages objectAtIndex:1]];
    WeekDataViewController *page12 = [self loadPageWithData:[self.pages objectAtIndex:0]];
    
    
    // constraints
    UIView *view1 = page1.view;
    UIView *view2 = page2.view;
    UIView *view3 = page3.view;
    UIView *view4 = page4.view;
    UIView *view5 = page5.view;
    UIView *view6 = page6.view;
    UIView *view7 = page7.view;
    UIView *view8 = page8.view;
    UIView *view9 = page9.view;
    UIView *view10 = page10.view;
    UIView *view11 = page11.view;
    UIView *view12 = page12.view;
    
    // horizontal
    [view1.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:0].active = YES;
    [view2.leftAnchor constraintEqualToAnchor:view1.rightAnchor constant:0].active = YES;
    [view3.leftAnchor constraintEqualToAnchor:view2.rightAnchor constant:0].active = YES;
    [view4.leftAnchor constraintEqualToAnchor:view3.rightAnchor constant:0].active = YES;
    [view5.leftAnchor constraintEqualToAnchor:view4.rightAnchor constant:0].active = YES;
    [view6.leftAnchor constraintEqualToAnchor:view5.rightAnchor constant:0].active = YES;
    [view7.leftAnchor constraintEqualToAnchor:view6.rightAnchor constant:0].active = YES;
    [view8.leftAnchor constraintEqualToAnchor:view7.rightAnchor constant:0].active = YES;
    [view9.leftAnchor constraintEqualToAnchor:view8.rightAnchor constant:0].active = YES;
    [view10.leftAnchor constraintEqualToAnchor:view9.rightAnchor constant:0].active = YES;
    [view11.leftAnchor constraintEqualToAnchor:view10.rightAnchor constant:0].active = YES;
    [view12.leftAnchor constraintEqualToAnchor:view11.rightAnchor constant:0].active = YES;
    [self.contentView.rightAnchor constraintEqualToAnchor:view12.rightAnchor constant:0].active = YES;
    
    [view1.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:0].active = YES;
    [view2.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    [view3.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    [view4.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    [view5.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    [view6.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    [view7.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    [view8.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    [view9.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    [view10.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    [view11.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    [view12.widthAnchor constraintEqualToAnchor:view1.widthAnchor constant:0].active = YES;
    
    
    // vertical
    [view1.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view2.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view3.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view4.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view5.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view6.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view7.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view8.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view9.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view10.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view11.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [view12.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view1.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view2.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view3.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view4.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view5.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view6.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view7.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view8.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view9.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view10.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view11.bottomAnchor constant:0].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:view12.bottomAnchor constant:0].active = YES;
    [view1.heightAnchor constraintEqualToConstant:200].active = YES;
    //[view2.heightAnchor constraintEqualToConstant:200].active = YES;
}

//
- (void)setUpPageControlView{
    
    //
    self.pageControlView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //
    CGFloat pageWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat kColumnWidth = (pageWidth - 40 - 20) / 11;//两点间距离
    //CGFloat kMaxHeight = 80.0;// 点的最大距离
    UIColor *backgrounColor = [UIColor colorWithRed:32.0/255 green:32.0/255 blue:32.0/255 alpha:1.0];// black
    UIColor *fillColor = [UIColor colorWithRed:42.0/255 green:42.0/255 blue:42.0/255 alpha:1.0];// lightgray
    self.pageControlView.layer.backgroundColor = backgrounColor.CGColor;
    
    // 判断page类型
    NSArray *fromPositionsY = [NSArray array];
    NSArray *toPositionsY = [NSArray array];
    
    if ([self.pageType isEqualToString:@"ride"]) {
        fromPositionsY = [self convertDistanceToPositionY:self.runDistances];
        toPositionsY = [self convertDistanceToPositionY:self.rideDistances];
    } else if ([self.pageType isEqualToString:@"run"]) {
        fromPositionsY = [self convertDistanceToPositionY:self.rideDistances];
        toPositionsY = [self convertDistanceToPositionY:self.runDistances];
        // 构造数据
        //toPositionsY = @[@(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0)];
    }
    
    
    // draw background
    /**
     * 说明：使用CAShapeLayer＋UIBezierPath画虚线
     */
    UIBezierPath *dashLinePath = [UIBezierPath bezierPath];
    [dashLinePath moveToPoint:CGPointMake(0, 1)];
    [dashLinePath addLineToPoint:CGPointMake(pageWidth - 20 -10, 1)];
//    CGFloat pattern[4] = {5, 2, 3, 2};
//    [dashLinePath setLineDash:pattern count:4 phase:6];
    
    CAShapeLayer *shapeDashLong = [CAShapeLayer layer];
    shapeDashLong.bounds = CGRectMake(0, 0, pageWidth - 20 - 10 , 2);
    shapeDashLong.position = CGPointMake((pageWidth + 10) / 2, 20);
    shapeDashLong.backgroundColor = [UIColor clearColor].CGColor;
    
    shapeDashLong.path = dashLinePath.CGPath;
    shapeDashLong.lineWidth = 2.0;
    shapeDashLong.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeDashLong.lineDashPattern = @[@(10), @(10)];//虚线宽10、空白10
    [self.pageControlView.layer addSublayer:shapeDashLong];
    
    UIBezierPath *verticalDash = [UIBezierPath bezierPath];
    [verticalDash moveToPoint:CGPointMake(5, 80)];
    [verticalDash addLineToPoint:CGPointMake(5, 0)];
    
    CAShapeLayer *shapeVertical = [CAShapeLayer layer];
    shapeVertical.bounds = CGRectMake(0, 0, 10, 80);
    shapeVertical.position = CGPointMake(25, 60);
    
    shapeVertical.path = verticalDash.CGPath;
    shapeVertical.lineWidth = 10;
    shapeVertical.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeVertical.lineDashPattern = @[@(2), @(18)];//虚线宽2，空白18
    //shapeVertical.backgroundColor = [UIColor orangeColor].CGColor;
    [self.pageControlView.layer addSublayer:shapeVertical];
    
    
    
    // draw line and fill area
    CAShapeLayer *shapeLine = [CAShapeLayer layer];
    shapeLine.bounds = self.pageControlView.layer.bounds;
    shapeLine.position = CGPointMake(CGRectGetMidX(self.pageControlView.layer.bounds), CGRectGetMidY(self.pageControlView.layer.bounds));
    shapeLine.backgroundColor = [UIColor clearColor].CGColor;
    [self.pageControlView.layer addSublayer:shapeLine];
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    linePath = [self createBezierPathWithPoints:fromPositionsY];

    UIBezierPath *toLinePath = [UIBezierPath bezierPath];
    toLinePath = [self createBezierPathWithPoints:toPositionsY];
    
    //shapeLine.path = linePath.CGPath;
    //shapeLine.path = toLinePath.CGPath;
    shapeLine.lineWidth = 1.0;
    shapeLine.strokeColor = fillColor.CGColor;
    shapeLine.fillColor = fillColor.CGColor;
    
    // aniamtion--wave)(可行)
    CABasicAnimation *wave = [CABasicAnimation animationWithKeyPath:@"path"];
    wave.duration = 1.0;
    wave.fromValue = (__bridge id _Nullable)(linePath.CGPath);
    wave.toValue = (__bridge id _Nullable)(toLinePath.CGPath);
    shapeLine.path = toLinePath.CGPath;
    if (!self.isFirstLoad) {

        [shapeLine addAnimation:wave forKey:nil];
    }
    
    
    // draw background
//    CAShapeLayer *shapeDashLong = [CAShapeLayer layer];
//    shapeDashLong.bounds = CGRectMake(0, 0, pageWidth - 20 -20, 50);
//    shapeDashLong.position = CGPointMake(CGRectGetMidX(self.pageControlView.layer.bounds), 20);
//    shapeDashLong.backgroundColor = [UIColor orangeColor].CGColor;
//    [self.pageControlView.layer addSublayer:shapeDashLong];
    
    
    
    // draw seperator line
    for (int i = 1; i < [toPositionsY count] - 1; i ++) {
        
        CGFloat fromPositionY = [[fromPositionsY objectAtIndex:i] floatValue];
        CGFloat toPositionY = [[toPositionsY objectAtIndex:i] floatValue];
        
        UIBezierPath *fromPath = [UIBezierPath bezierPath];
        [fromPath moveToPoint:CGPointMake(0, 80)];
        [fromPath addLineToPoint:CGPointMake(0, 80 - fromPositionY)];
        
        UIBezierPath *toPath = [UIBezierPath bezierPath];
        [toPath moveToPoint:CGPointMake(0, 80)];
        [toPath addLineToPoint:CGPointMake(0, 80 - toPositionY)];
        
        // 可以实现seperator（但bounds和position都和points有关联）
//        CAShapeLayer *shapeSeperator = [CAShapeLayer layer];
//        shapeSeperator.bounds = CGRectMake(0, 0, 1, toPositionY);
//        shapeSeperator.position = CGPointMake(40 + kColumnWidth * i, 100 - toPositionY / 2);
//        shapeSeperator.backgroundColor = [UIColor redColor].CGColor;
//        [self.pageControlView.layer addSublayer:shapeSeperator];
        
        //
        CAShapeLayer *shapeSeperator = [CAShapeLayer layer];
        shapeSeperator.bounds = CGRectMake(0, 0, 1, 80);
        shapeSeperator.position = CGPointMake(40 + kColumnWidth * i, 20 + 40);
        shapeSeperator.backgroundColor = [UIColor clearColor].CGColor;
        [self.pageControlView.layer addSublayer:shapeSeperator];
        
        //shapeSeperator.path = fromPath.CGPath;
        shapeSeperator.lineWidth = 1.0;
        shapeSeperator.strokeColor = backgrounColor.CGColor;
        
        // animation
        CABasicAnimation *seperatorMove = [CABasicAnimation animationWithKeyPath:@"path"];
        seperatorMove.duration = 1.0;
        seperatorMove.fromValue = (__bridge id _Nullable)(fromPath.CGPath);
        seperatorMove.toValue = (__bridge id _Nullable)(toPath.CGPath);
        shapeSeperator.path = toPath.CGPath;
        if (!self.isFirstLoad) {
            [shapeSeperator addAnimation:seperatorMove forKey:nil];
        }
        
        
        
    }
    
    
    // draw point type
    for (int i = 0; i < [fromPositionsY count]; i ++) {
        
        CGFloat fromPositionY = [[fromPositionsY objectAtIndex:i] floatValue];
        CGFloat toPositionY = [[toPositionsY objectAtIndex:i] floatValue];
        
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 5, 5)];
        
        CAShapeLayer *shapePoint = [[CAShapeLayer alloc] init];
        shapePoint.bounds = CGRectMake(0, 0, 5, 5);
        //shapePoint.position = CGPointMake((40 + kColumnWidth * i), (100 - fromPositionY));
        shapePoint.path = circlePath.CGPath;
        shapePoint.lineWidth = 2.0;
        shapePoint.strokeColor = [UIColor whiteColor].CGColor;
        shapePoint.fillColor = backgrounColor.CGColor;
        [self.pageControlView.layer addSublayer:shapePoint];
        
        // animation
        CABasicAnimation *pointMove = [CABasicAnimation animationWithKeyPath:@"position.y"];
        pointMove.duration = 1.0;
        pointMove.fromValue = @(100 - fromPositionY);
        pointMove.toValue = @(100 - toPositionY);
        shapePoint.position = CGPointMake((40 + kColumnWidth * i), (100 - toPositionY));
        if (!self.isFirstLoad) {
            
            [shapePoint addAnimation:pointMove forKey:nil];

        }
        
    }
    
    
    // draw shift line
    UIBezierPath *shiftLinePath = [UIBezierPath bezierPath];
    [shiftLinePath moveToPoint:CGPointMake(1, 80)];
    [shiftLinePath addLineToPoint:CGPointMake(1, 0)];
    
    self.shapeShift = [CAShapeLayer layer];
    self.shapeShift.bounds = CGRectMake(0, 0, 1, 80);
    self.shapeShift.position = CGPointMake(40 + kColumnWidth * self.currentPage, 20 + 40);
    self.shapeShift.path = shiftLinePath.CGPath;
    self.shapeShift.lineWidth = 2.0;
    self.shapeShift.strokeColor = [UIColor redColor].CGColor;
    [self.pageControlView.layer addSublayer:self.shapeShift];
    
    
    
    // draw current page
    UIColor *color = [UIColor colorWithRed:57.0/255 green:193.0/255 blue:125.0/255 alpha:1.0];
//    UIBezierPath *circlePointPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 8, 8)];
//    
//    self.shapeCurrentPoint = [CAShapeLayer layer];
//    self.shapeCurrentPoint.bounds = CGRectMake(0, 0, 8, 8);
//    self.shapeCurrentPoint.path = circlePointPath.CGPath;
//    self.shapeCurrentPoint.lineWidth = 2.0;
//    self.shapeCurrentPoint.strokeColor = backgrounColor.CGColor;
//    self.shapeCurrentPoint.fillColor = color.CGColor;
//    [self.pageControlView.layer addSublayer:self.shapeCurrentPoint];
//    
//    CABasicAnimation *movePoint = [CABasicAnimation animationWithKeyPath:@"position.y"];
//    movePoint.duration = 1.0;
//    movePoint.fromValue = @(100 - [[fromPositionsY objectAtIndex:self.currentPage] floatValue]);
//    movePoint.toValue = @(100 - [[toPositionsY objectAtIndex:self.currentPage] floatValue]);
//    self.shapeCurrentPoint.position = CGPointMake(40 + kColumnWidth * self.currentPage, 100 - [[toPositionsY objectAtIndex:self.currentPage] floatValue]);
//    if (!self.isFirstLoad) {
//        [self.shapeCurrentPoint addAnimation:movePoint forKey:nil];
//    }
    
    // 方法二：track point通过显示和隐藏来实现
    self.pointBackgound = [CALayer layer];
    self.pointBackgound.bounds = self.pageControlView.layer.bounds;
    self.pointBackgound.position = CGPointMake(CGRectGetMidX(self.pageControlView.layer.bounds), CGRectGetMidY(self.pageControlView.layer.bounds));
    [self.pageControlView.layer addSublayer:self.pointBackgound];
    
    for (int i = 0; i < [toPositionsY count]; i ++) {
        
        CGFloat fromPositionY = [[fromPositionsY objectAtIndex:i] floatValue];
        CGFloat toPositionY = [[toPositionsY objectAtIndex:i] floatValue];
        
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 8, 8)];
        
        CAShapeLayer *shapeCirclePoint = [CAShapeLayer layer];
        shapeCirclePoint.bounds = CGRectMake(0, 0, 8, 8);
        //shapeCirclePoint.position = CGPointMake(40 + kColumnWidth * i, (100 - toPositionY));
        shapeCirclePoint.path = circlePath.CGPath;
        shapeCirclePoint.lineWidth = 2.0;
        shapeCirclePoint.strokeColor = backgrounColor.CGColor;
        shapeCirclePoint.fillColor = color.CGColor;
        [self.pointBackgound addSublayer:shapeCirclePoint];
        
        CABasicAnimation *pointMove = [CABasicAnimation animationWithKeyPath:@"position.y"];
        pointMove.duration = 1.0;
        pointMove.fromValue = @(100 - fromPositionY);
        pointMove.toValue = @(100 - toPositionY);
        shapeCirclePoint.position = CGPointMake(40 + kColumnWidth * i, (100 - toPositionY));
        if (!self.isFirstLoad) {
            [shapeCirclePoint addAnimation:pointMove forKey:nil];
        }
        
        shapeCirclePoint.hidden = YES;
        if (i == self.currentPage) {
            shapeCirclePoint.hidden = NO;
        }
    }
  
    
}



//#MARK: helper method
- (WeekDataViewController *)loadPageWithData:(Page *)inPage{
    
    WeekDataViewController *pageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WeekDataViewController"];
    //
    [self setViewController:pageVC withData:inPage];
    
    pageVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:pageVC.view];
    [self addChildViewController:pageVC];
    [pageVC didMoveToParentViewController:self];
    
    return pageVC;
    
}

- (void)setViewController:(UIViewController *)viewController withData:(Page *)inPage{
    
//    Page *page = [[Page alloc] init];
//    page.week = [[data objectForKey:@"week"] integerValue];
//    page.year = [[data objectForKey:@"year"] integerValue];
//    page.ride = [data objectForKey:@"ride"];
//    NSString *distance = [NSString stringWithFormat:@"%@", [page.ride objectForKey:@"distance"]];
//    NSString *elapsedTime = [NSString stringWithFormat:@"%@", [page.ride objectForKey:@"elapsed_time"]];
//    NSString *elevationGain = [NSString stringWithFormat:@"%@", [page.ride objectForKey:@"elevation_gain"]];
//    
//    WeekDataViewController *pageVC = (WeekDataViewController *)viewController;
//    pageVC.weekText = [NSString stringWithFormat:@"%ld", (long)page.week];
//    pageVC.mileText = distance;
//    pageVC.timeText =elapsedTime;
//    pageVC.heightText = elevationGain;
//    pageVC.goal = [page.ride objectForKey:@"goal"];
//    pageVC.days = [page.ride objectForKey:@"days"];
    
    Page *page = inPage;
    
    WeekDataViewController *pageVC = (WeekDataViewController *)viewController;
    pageVC.page = page;
    /**
     * 设置page type 用于切换ride 和run
     */
    pageVC.pageType = self.pageType;
    
    //
    /**
     * 说明：传递一个标志，用于判断WeekDataVC是否是第一次加载
     */
    pageVC.isFirstLoad = self.isFirstLoad;
    
    
}


//
// 计算position y
- (NSArray *)caculatePositionYWithDays:(NSArray *)days{
    
    NSMutableArray *distanceArray = [NSMutableArray array];
    NSMutableArray *positionsY = [NSMutableArray array];
    
    for (Day *day in days) {
        
        [distanceArray addObject:@(day.distance)];
    }
    
    // 筛选出数组中的最大值
    NSInteger __block maxValue = 0;
    [distanceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        maxValue = MAX(maxValue, [obj integerValue]);
    }];
    //NSLog(@"max:%ld", (long)maxValue);
    
    // 根据根据最大值，计算各个值
    if (maxValue != 0) {
        for (NSNumber *distance in distanceArray) {
            CGFloat positionY = distance.floatValue / maxValue * 28;
            [positionsY addObject:@(positionY)];
        }
    } else {
        // positionY = 0
        for (NSNumber *distance in distanceArray) {
            CGFloat positionY = distance.floatValue;
            [positionsY addObject:@(positionY)];
        }

    }

    return positionsY;
}

// 创建bezier path 使用points数组
- (UIBezierPath *)createBezierPathWithPoints:(NSArray *)points{
    
    //
    CGFloat pageWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat kColumnWidth = (pageWidth - 40 - 20) / 11;//两点间距离
    //CGFloat kMaxHeight = 80.0;// 点的最大距离
    
    //
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(40, 100)];
    for (int i = 0; i < [points count]; i ++) {
        [path addLineToPoint:CGPointMake(40 + kColumnWidth * i, 100 - [[points objectAtIndex:i] floatValue])];
    }
    [path addLineToPoint:CGPointMake(40 + kColumnWidth * 11, 100)];
    
    return path;
}

// 将距离数组转换为位置数组
- (NSArray *)convertDistanceToPositionY:(NSArray *)distances{

    CGFloat kMaxHeight = 80.0;// 点的最大距离
    
    NSMutableArray *positionsY = [NSMutableArray array];
    NSArray *array = distances;
    
    CGFloat __block maxDistance = 0;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        maxDistance = MAX(maxDistance, [obj floatValue]);
    }];
    
    if (maxDistance != 0) {
        for (NSNumber *item in array) {
            CGFloat positionY = item.floatValue;
            positionY = positionY / maxDistance *kMaxHeight;
            [positionsY addObject:@(positionY)];
        }
    } else {
        // 当一周内的数据为0时，positionY = 0
        for (NSNumber *item in array) {
            CGFloat positionY = item.floatValue;
            [positionsY addObject:@(positionY)];
        }
    }
    
    
    return positionsY;
}


//#MARK:UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //
    //NSLog(@"did;contentOffset:%@", NSStringFromCGPoint(scrollView.contentOffset));
    
    //
    CGFloat pageWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat kColumnWidth = (pageWidth - 40 - 20) / 11;//两点间距离
    
    // 计算current page
    NSInteger page = floorf( (scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.currentPage = page;
    NSLog(@"page:%ld", (long)page);
    NSLog(@"will ;current page:%ld", (long)self.currentPage);

    
    //
    /**
     * 说明：目前这两个都没有达到预期效果（反应迟钝）
     */
    // 调整track line的位置
    CGFloat positionX = scrollView.contentOffset.x / pageWidth * kColumnWidth;
    
    /**
     * 说明：如果没放手track line随positionX变化；放手了直接跳到下一点（如果都使用positionX，当松手后，track line移动有延时、迟钝感）
     */
    if (!self.scrollView.decelerating) {
        self.shapeShift.position = CGPointMake(40 + positionX, 60);
    } else {
        self.shapeShift.position = CGPointMake(40 + kColumnWidth * self.currentPage, 60);
    }
    
    
    
    
    // 调整track point的位置
    
    // 判断page类型
//    NSArray *fromPositionsY = [NSArray array];
//    NSArray *toPositionsY = [NSArray array];
//    
//    if ([self.pageType isEqualToString:@"ride"]) {
//        fromPositionsY = [self convertDistanceToPositionY:self.runDistances];
//        toPositionsY = [self convertDistanceToPositionY:self.rideDistances];
//    } else if ([self.pageType isEqualToString:@"run"]) {
//        fromPositionsY = [self convertDistanceToPositionY:self.rideDistances];
//        //toPositionsY = [self convertDistanceToPositionY:self.runDistances];
//        toPositionsY = @[@(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0)];
//    }
//    
//    self.shapeCurrentPoint.position = CGPointMake(40 + kColumnWidth * page, 100 - [[toPositionsY objectAtIndex:page] floatValue]);
    
    // 通过hidden方法实现track point的显示
    for (int i = 0; i < [self.pointBackgound.sublayers count]; i ++) {
        CALayer *point = [self.pointBackgound.sublayers objectAtIndex:i];
        point.hidden = YES;
        if (i == self.currentPage) {
            point.hidden = NO;
        }
    }
}






@end
