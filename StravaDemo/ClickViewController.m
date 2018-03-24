//
//  ClickViewController.m
//  StravaDemo
//
//  Created by owen on 16/6/15.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "ClickViewController.h"
#import "PopViewController.h"

@interface ClickViewController ()

@property (weak, nonatomic) IBOutlet UIButton *myButton;
//@property (nonatomic) BOOL rideType;

@end

@implementation ClickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //
    self.rideType = 0;
    
    // 2.2 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PassValueNotification:) name:@"PassValueNotification" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    //
    NSLog(@"clickVC:rideType:%d", self.rideType);
}



// 2.3 通知实现方法
- (void)PassValueNotification:(NSNotification *)notification{
    
    NSDictionary *valueDictionary = [notification userInfo];
    self.rideType = [[valueDictionary objectForKey:@"value"] boolValue];
    NSLog(@"click:rideType:%d", self.rideType);
}

- (IBAction)handleMyButtonAction:(id)sender {
    
    // 修改背景图片
    //    UIImage *imageNormal = [UIImage imageNamed:@"red-btn"];
    //    UIImage *imageHighlighted = [UIImage imageNamed:@"green-btn"];
    
    //    if ([self.myButton.currentBackgroundImage isEqual:imageHighlighted]) {
    //        [self.myButton setBackgroundImage:imageHighlighted forState:UIControlStateNormal];
    //        [self.myButton setBackgroundImage:imageNormal forState:UIControlStateHighlighted];
    //    } else {
    //        [self.myButton setBackgroundImage:imageNormal forState:UIControlStateNormal];
    //        [self.myButton setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    //    }
    
    //    [self.myButton setBackgroundImage:imageHighlighted forState:UIControlStateNormal];
    //    [self.myButton setBackgroundImage:imageNormal forState:UIControlStateHighlighted];
    
    // 修改背景色
    //    UIColor *green = [UIColor colorWithRed:51/255.0 green:172/255.0 blue:87/255.0 alpha:1.0];
    //    UIColor *orange = [UIColor colorWithRed:239/255.0 green:52/255.0 blue:9/255.0 alpha:1.0];
    //
    //    if (![self.myButton.backgroundColor isEqual:orange]) {
    //        self.myButton.backgroundColor = orange;
    //    } else {
    //        self.myButton.backgroundColor = green;
    //    }
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //
    PopViewController *popVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"ShowPopVC"]) {
        popVC.rideType = self.rideType;
        // 1.4 实现block
//        popVC.passValueBlock = ^(BOOL typeFlag){
//            self.rideType = typeFlag;
//            NSLog(@"clickVC:in block: rideType:%d", self.rideType);
//        };
    }
}


@end
