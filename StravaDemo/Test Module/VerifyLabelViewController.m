//
//  VerifyLabelViewController.m
//  StravaDemo
//
//  Created by owen on 16/9/14.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "VerifyLabelViewController.h"

@interface VerifyLabelViewController ()

@property (weak, nonatomic) IBOutlet UIView *timeView;

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) int seconds;

@end

@implementation VerifyLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickStartButtonAction:(id)sender {
    NSLog(@"start");
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:true];
    
}

- (IBAction)clickStopButtonAction:(id)sender {
    NSLog(@"stop");
    
    // 停止定时
    [self.timer invalidate];
}

// 更新时间
- (void)updateTime{
    
    // 使用self.seconds来作为总的计时时间（暂停、开始可以继续计时，不会从0开始）
    self.seconds ++;
    NSTimeInterval passedTime = self.seconds;
    
    //
    //NSLog(@"passed time:%f", passedTime);
    int hours = passedTime / 3600;
    //NSLog(@"hours:%d", hours);
    passedTime -= hours * 3600;
    int minutes = passedTime / 60;
    int minutesTen = minutes / 10;          // 获取分钟的十位
    int minutesOne = minutes % 10;          // 获取分钟的个位
    //NSLog(@"minutes:%d", minutes);
    passedTime -= minutes * 60;
    int seconds = passedTime;
    //NSLog(@"passedTime:%f", passedTime);
    //NSLog(@"self.seconds:%d", self.seconds);
    // 将seconds拆分为两部分
    int secondsTen = seconds / 10;
    int secondsOne = seconds % 10;
    
//    NSString *stringHours = [NSString stringWithFormat:@"%02d", hours];
//    NSString *stringMinutes = [NSString stringWithFormat:@"%02d", minutes];
//    NSString *stringSeconds = [NSString stringWithFormat:@"%02d", seconds];
    
    // 显示计时
    /**
     * 问题：数字变化时，能看到变化效果???
       解决：把每个数字单独设置为一个lable，没次只更新一个数字
     */
    // 情况一：lable居中显示－－闪烁
    // 情况二：label不添加约束－－闪烁
    // 情况三：label添加上、左约束－－闪烁，但变得轻微了许多
    // 情况四：label添加四周约束－－闪烁
    // 情况五：把每个数字单独设置为一个lable，没次只更新一个数字－－不存在闪烁感
    //UILabel *timeLabel = [self.timeView viewWithTag:11];
    //timeLabel.text = [NSString stringWithFormat:@"%@:%@:%@", stringHours, stringMinutes, stringSeconds];
//    UILabel *hoursLabel = [self.timeView viewWithTag:11];
//    UILabel *minutesLabel = [self.timeView viewWithTag:12];
//    UILabel *secondesLabel = [self.timeView viewWithTag:12];

    
    UILabel *minutesTenLabel = [self.timeView viewWithTag:21];
    UILabel *minutesOneLabel = [self.timeView viewWithTag:22];

    UILabel *secondsTenLabel = [self.timeView viewWithTag:31];
    UILabel *secondsOneLabel = [self.timeView viewWithTag:32];
    
    
//    hoursLabel.text = [NSString stringWithFormat:@"%@", stringHours];
//    minutesLabel.text = [NSString stringWithFormat:@"%@", stringMinutes];
    
    minutesTenLabel.text = [NSString stringWithFormat:@"%d", minutesTen];
    minutesOneLabel.text = [NSString stringWithFormat:@"%d", minutesOne];
    
    secondsTenLabel.text = [NSString stringWithFormat:@"%d", secondsTen];
    secondsOneLabel.text = [NSString stringWithFormat:@"%d", secondsOne];

    
    // contrast view:使用stack view 进行对比
    // 配置一：distribution设置为full proportionally－－闪烁
    // 配置二：distribution设置为full equally－－不闪烁
    // 配置三：distribution设置为equal spacing－－闪烁
    UIView *contrastView = [self.timeView viewWithTag:99];
    
    UILabel *contrastMimutesTenLabel = [contrastView viewWithTag:221];
    UILabel *contrastMinutesOneLabel = [contrastView viewWithTag:222];
    
    UILabel *contrastSecondsTenLabel = [contrastView viewWithTag:231];
    UILabel *contrastSecondsOneLabel = [contrastView viewWithTag:232];
    
    contrastMimutesTenLabel.text = [NSString stringWithFormat:@"%d", minutesTen];
    contrastMinutesOneLabel.text = [NSString stringWithFormat:@"%d", minutesOne];
    
    contrastSecondsTenLabel.text = [NSString stringWithFormat:@"%d", secondsTen];
    contrastSecondsOneLabel.text = [NSString stringWithFormat:@"%d", secondsOne];
    
    
    
}







/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
