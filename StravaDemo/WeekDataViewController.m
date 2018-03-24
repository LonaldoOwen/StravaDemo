//
//  WeekDataViewController.m
//  StravaDemo
//
//  Created by owen on 16/5/24.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "WeekDataViewController.h"
#import "Page.h"
#import "Goal.h"
#import "Ride.h"
#import "Day.h"
#import "DataContainerViewController.h"

@interface WeekDataViewController ()

@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *mileLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UIView *columnView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet UILabel *goalDistance;

@property (strong, nonatomic) NSMutableArray *positionsY;
@property (strong, nonatomic) NSArray *fromValues;

@property (nonatomic) BOOL isFlag;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;


@end




@implementation WeekDataViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add a button
    //[self setUpAnimationButton];
    
    //
    [self setUpColumnView];
    //
    [self setUpCircleView];
    //
    [self setUpDayLabel];
    //
    self.isFlag = YES;
    
        
    
}



- (void)viewWillAppear:(BOOL)animated{
    //
    //NSLog(@"viewWillAppear,Week");
    
    // 数据转换为模型
    Page *page = self.page;
    Ride *ride = page.ride;
    Ride *run = page.run;
    Goal *goal = [[Goal alloc] init];
    //NSLog(@"page type:%@", self.pageType);
    
    

    // weekLabel
    self.weekLabel.backgroundColor = [UIColor clearColor];
    self.weekLabel.textColor = [UIColor lightGrayColor];
    self.weekLabel.text = [NSString stringWithFormat:@"%ld", (long)page.week];
    
    if ([self.pageType isEqualToString:@"ride"]) {
        
        // milelabel
        self.mileLabel.backgroundColor = [UIColor clearColor];
        self.mileLabel.textColor = [UIColor whiteColor];
        CGFloat mileValue = (CGFloat)ride.distance;
        if (mileValue >= 1000) {
            mileValue = mileValue / 1000.0;//转换为Km
            self.mileLabel.text = [NSString stringWithFormat:@"%0.1fkm", mileValue];
        } else {
            self.mileLabel.text = [NSString stringWithFormat:@"%dm", (int)mileValue];
        }
        
        // timeLabel
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor whiteColor];
        NSInteger timeValue = ride.elapsedTime;
        NSInteger hour = floorl(timeValue / 3600);
        NSInteger minute = floorl((timeValue - hour * 3600) / 60);
        NSInteger second = (timeValue - hour * 3600 - minute * 60 );
        if (hour > 0) {
            self.timeLabel.text = [NSString stringWithFormat:@"%ld小时%ld分钟", (long)hour, (long)minute];
        } else {
            self.timeLabel.text = [NSString stringWithFormat:@"%ld分钟%ld秒", (long)minute, (long)second];
        }
        
        // heightLabel
        self.heightLabel.backgroundColor = [UIColor clearColor];
        self.heightLabel.textColor = [UIColor whiteColor];
        self.heightLabel.text = [NSString stringWithFormat:@"%ldm", (long)ride.elevationGain];
        
        // dayLabel
    
        
        // columnView
        NSArray *toPositionsY = [self caculatePositionYWithDays:ride.days];
        NSArray *fromPositionsY = [self caculatePositionYWithDays:run.days];
        self.fromValues = toPositionsY;
        //NSLog(@"fromValues:%@", self.fromValues);
        //NSLog(@"max:%ld", (long)maxValue);
        
        
        
        if ([toPositionsY count]) {
            
            for (int i = 0; i < [self.columnView.layer.sublayers count]; i++) {
                
                CALayer *layer = [self.columnView.layer.sublayers objectAtIndex:i];
                NSInteger positionY = [[toPositionsY objectAtIndex:i] integerValue];
                NSInteger runPositionY = [[fromPositionsY objectAtIndex:i] integerValue];
                //layer.position = CGPointMake(8 + 20 * i, 30 + 15 - 2 - positionY);
                // 增加动画
                CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.y"];
                move.duration = 1.0;
                move.fromValue = @(43 - runPositionY);
                move.toValue = @(43 - positionY);
                layer.position = CGPointMake(8 + 20 * i, 30 + 15 - 2 - positionY);
                //[layer addAnimation:move forKey:nil];
                if (!self.isFirstLoad) {
                    [layer addAnimation:move forKey:nil];
                }
            }
        }
        
        // circleView
        goal = ride.goal;
        
        if ([goal.type isEqualToString:@"DistanceGoal"]) {
            
            NSInteger goalValue = goal.goal / 1000;
            self.goalDistance.text = [NSString stringWithFormat:@"%ldkm", (long)goalValue];
            
            Goal *runGoal = run.goal;
            CGFloat fromPercentage = [self caculatePercentageWithTypeValue:run.elapsedTime andGoalValue:runGoal.goal];
            CGFloat toPercentage = [self caculatePercentageWithTypeValue:ride.distance andGoalValue:goal.goal];
    
            CAShapeLayer *circleLayer = (CAShapeLayer *)[self.circleView.layer.sublayers objectAtIndex:3];
            //
            CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            move.duration = 1.0;
            move.fromValue = @(fromPercentage);
            move.toValue = @(toPercentage);
            circleLayer.strokeEnd = toPercentage;
            if (!self.isFirstLoad) {
                [circleLayer addAnimation:move forKey:nil];
            }
            
        }
    } else if ([self.pageType isEqualToString:@"run"]){
        
        // milelabel
        self.mileLabel.backgroundColor = [UIColor clearColor];
        self.mileLabel.textColor = [UIColor whiteColor];
        CGFloat mileValue = (CGFloat)run.distance;
        if (mileValue >= 1000) {
            mileValue = mileValue / 1000.0;
            self.mileLabel.text = [NSString stringWithFormat:@"%0.1fkm", mileValue];
        } else {
            self.mileLabel.text = [NSString stringWithFormat:@"%dm", (int)mileValue];
        }
        
        // timeLabel
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor whiteColor];
        NSInteger timeValue = run.elapsedTime;
        NSInteger hour = floorl(timeValue / 3600);
        NSInteger minute = floorl((timeValue - hour * 3600) / 60);
        NSInteger second = (timeValue - hour * 3600 - minute * 60 );
        if (hour > 0) {
            self.timeLabel.text = [NSString stringWithFormat:@"%ld小时%ld分钟", (long)hour, (long)minute];
        } else {
            self.timeLabel.text = [NSString stringWithFormat:@"%ld分钟%ld秒", (long)minute, (long)second];
        }
        
        // heightLabel
        self.heightLabel.backgroundColor = [UIColor clearColor];
        self.heightLabel.textColor = [UIColor whiteColor];
        self.heightLabel.text = [NSString stringWithFormat:@"%ldm", (long)ride.elevationGain];
        
        // dayLabel
        
        
        // columnView
        NSArray *toPositionsY = [self caculatePositionYWithDays:run.days];
        NSArray *fromPositionsY = [self caculatePositionYWithDays:ride.days];
        
        if ([toPositionsY count]) {
            
            for (int i = 0; i < [self.columnView.layer.sublayers count]; i++) {
                
                CALayer *layer = [self.columnView.layer.sublayers objectAtIndex:i];
                NSInteger toPositionY = [[toPositionsY objectAtIndex:i] integerValue];
                NSInteger fromPositionY = [[fromPositionsY objectAtIndex:i] integerValue];
                
                CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.y"];
                move.duration = 1.0;
                move.fromValue = @(43 - fromPositionY);
                move.toValue = @(43 - toPositionY);
                layer.position = CGPointMake(8 + 20 * i, 30 + 15 - 2 - toPositionY);
                //[layer addAnimation:move forKey:nil];
                if (!self.isFirstLoad) {
                    [layer addAnimation:move forKey:nil];
                }
            }
        }
        
        // circleView
        goal = run.goal;
                
        if ([goal.type isEqualToString:@"TimeGoal"]) {
            
            NSInteger goalValue = goal.goal;
            self.goalDistance.text = [NSString stringWithFormat:@"%lds", (long)goalValue];
            
            Goal *rideGoal = ride.goal;
            CGFloat fromPercentage = [self caculatePercentageWithTypeValue:ride.distance andGoalValue:rideGoal.goal];
            CGFloat toPercentage = [self caculatePercentageWithTypeValue:run.elapsedTime andGoalValue:goal.goal];
            
            CAShapeLayer *circleLayer = (CAShapeLayer *)[self.circleView.layer.sublayers objectAtIndex:3];
            
            CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            move.duration = 1.0;
            move.fromValue = @(fromPercentage);
            move.toValue = @(toPercentage);
            circleLayer.strokeEnd = toPercentage;
            [circleLayer addAnimation:move forKey:nil];
        }
        
    }
    
    
    
}






// 设置每天运动量column
- (void)setUpColumnView{
    
    for (int i = 0; i < 7; i++) {
        
        /**
         * 注意：使用RGB颜色时，值要使用float，57.0／255（57/255得零）
         */
        CGFloat red = 57.0/255;//0.22;//57 / 255;
        CGFloat green = 193.0/255;//0.76;//193 / 255;
        CGFloat blue = 125.0/255;//0.49;//125 / 255;
        
        CALayer *bar = [CALayer layer];
        bar.bounds = CGRectMake(0, 0, 5, 30);
        bar.position = CGPointMake(8 + 20 * i, 30 + 15 - 2);
//        NSInteger positionY = [[self.positionsY objectAtIndex:i] integerValue];
//        bar.position = CGPointMake(8 + 20 * i, 30 + 15 - 2 - positionY);
        bar.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
        [self.columnView.layer addSublayer:bar];
        self.columnView.layer.masksToBounds = YES;
        self.columnView.backgroundColor = [UIColor clearColor];
    }
}


// 设置显示天的label
- (void)setUpDayLabel{
    
    // 获取时间日期构件
    NSDate *currentDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitYear|NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear fromDate:currentDate];
    NSInteger weekOfYear = [comps weekOfYear];
    NSInteger weekday = [comps weekday];
    
    Page *page = self.page;
    
    
    // 创建attributedString（未到来的day显示灰色）
    NSString *string = @"一二三四五六日";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    UIColor *color = [UIColor colorWithRed:57.0/255 green:193.0/255 blue:125.0/255 alpha:1.0];//
    
    /**
     * 说明：解决weekLabel星期灰色显示问题
     */
    if (page.week == weekOfYear) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, attributedString.length)];//默认字体颜色都是lightgray
        
        if (weekday ==1 ) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, weekday + 6)];//今天是周日全部显示绿色（按照中国的日历习惯）
        } else {
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, weekday - 1)];//今天是非周日，今天以后显示灰色
        }
        
    } else {
        [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.length)];//全部显示绿色（非本周）
    }
    
    
    [attributedString addAttribute:NSKernAttributeName value:@(6.2) range:NSMakeRange(0, attributedString.length)];//调整字符间距
    
    self.dayLabel.attributedText = attributedString;
    self.dayLabel.backgroundColor = [UIColor clearColor];
    
}


// 设置目标view
- (void)setUpCircleView{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 120, 120)];
    
    CAShapeLayer *backLayer = [[CAShapeLayer alloc] init];
    backLayer.lineWidth = 4.0;
    backLayer.strokeColor = [UIColor blackColor].CGColor;
    backLayer.fillColor = [UIColor clearColor].CGColor;
    backLayer.path = path.CGPath;
    [self.circleView.layer addSublayer:backLayer];
    
    CAShapeLayer *circleLayer = [[CAShapeLayer alloc] init];
    circleLayer.lineWidth = 4.0;
    circleLayer.strokeColor = [UIColor colorWithRed:57.0/255 green:193.0/255 blue:125.0/255 alpha:1.0].CGColor;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.path = path.CGPath;
    circleLayer.strokeStart = 0.0;
    circleLayer.strokeEnd = 0.8;
    [self.circleView.layer addSublayer:circleLayer];
    
    self.circleView.backgroundColor = [UIColor clearColor];
    
    
}

// animation
//- (void)

// 计算position y
- (NSArray *)caculatePositionYWithDays:(NSArray *)days{
    
    NSMutableArray *distanceArray = [NSMutableArray array];
    NSMutableArray *positionsY = [NSMutableArray array];
    
    for (Day *day in days) {
        
        [distanceArray addObject:@(day.distance)];
    }
    
    NSInteger __block maxValue = 0;
    [distanceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        maxValue = MAX(maxValue, [obj integerValue]);
    }];
    //NSLog(@"max:%ld", (long)maxValue);
    
    if (maxValue != 0) {
        for (NSNumber *distance in distanceArray) {
            CGFloat positionY = distance.floatValue / maxValue * 28;
            [positionsY addObject:@(positionY)];
        }
    } else {
        // positionY = 0;
        for (NSNumber *distance in distanceArray) {
            CGFloat positionY = distance.floatValue;
            [positionsY addObject:@(positionY)];
        }
    }
    
    
    
    return positionsY;
}

// 计算percentage
- (CGFloat)caculatePercentageWithTypeValue:(NSInteger)typeValue andGoalValue:(NSInteger)goalValue{
    
    CGFloat goalPercentage = 0;
    NSInteger value1 = typeValue;
    NSInteger value2 = goalValue;
    
    if (value1 >= value2) {
        goalPercentage = 1.0;
    } else {
        goalPercentage = (CGFloat)value1 / value2;
    }
    
    return goalPercentage;
}





@end
