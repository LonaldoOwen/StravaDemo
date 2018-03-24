//
//  PopViewController.m
//  StravaDemo
//
//  Created by owen on 16/6/14.
//  Copyright © 2016年 owen. All rights reserved.
//

/**
  * 功能：实现Pov VC功能。
  1、假pop：通过设置view的hidden属性实现
  2、真pop：VC2的root view背景色设置为透明，添加maskViewbejs为半透明，VC1的storyboard segue 的presentation设置为Over Current Context
 */

#import "PopViewController.h"

@interface PopViewController ()

@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *myButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rideButton;
@property (weak, nonatomic) IBOutlet UIButton *runButton;
@property (nonatomic) BOOL isRideSelected;
@property (nonatomic) BOOL isRunSelected;

@end

#define orange [UIColor colorWithRed:239/255.0 green:52/255.0 blue:9/255.0 alpha:1.0];
//UIColor *orange = [UIColor colorWithRed:239/255.0 green:52/255.0 blue:9/255.0 alpha:1.0];


@implementation PopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //
    NSLog(@"popVC:viewDidLoad");
    
    // setup maskView
    [self setUpMaskView];
    //
    //[self setUpMyButton];
    //UIButton *myButton = [[UIButton alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    //
    NSLog(@"self.rideType:%d", self.rideType);
    
    //
    if (!self.rideType) {
        self.isRideSelected = YES;//1代表ride；0代表run
        self.isRunSelected = !self.isRideSelected;
    } else {
        self.isRideSelected = NO;
        self.isRunSelected = !self.isRideSelected;
    }
    
    if (!self.isRideSelected) {
        self.rideButton.backgroundColor = [UIColor whiteColor];
        self.runButton.backgroundColor = orange;
    } else {
        self.rideButton.backgroundColor = orange;
        self.runButton.backgroundColor = [UIColor whiteColor];
    }
    

}

- (void)setUpMaskView{
    
    //
    /**
     * 说明：模仿pop view，通过view的hidden属性模仿pop view效果
     */
//    self.maskView.hidden = YES;
//    self.backgroundView.layer.cornerRadius = 5;
//    self.backgroundView.clipsToBounds = YES;
    
//    //
//    self.isRideSelected = self.rideType;
//    self.isRunSelected = !self.isRideSelected;
    
    //
    UITapGestureRecognizer *tapMaskView = [[UITapGestureRecognizer alloc] init];
    [tapMaskView addTarget:self action:@selector(handleTapMaskView)];
    [self.maskView addGestureRecognizer:tapMaskView];
}

//
//- (void)setUpMyButton{
//    
//    // BackgroundImage:forState:
//    /**
//     * 说明：button的背景图片通常设置两种模式：UIControlStateNormal（正常）、UIControlStateHighlighted（高亮，即点击后）
//     */
//    [self.myButton setBackgroundImage:[UIImage imageNamed:@"green-btn"] forState:UIControlStateHighlighted];
//    //self.myButton.backgroundColor = [UIColor whiteColor];
//}

- (IBAction)handleRideButtonAction:(id)sender {
    
    self.isRideSelected = YES;
    self.isRunSelected = !self.isRideSelected;
    
    if (!self.isRideSelected) {
        self.rideButton.backgroundColor = [UIColor whiteColor];
    } else {
        self.rideButton.backgroundColor = orange;
    }
    
    self.rideType = self.isRideSelected ? 0 : 1;
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self dismissPopVC];
}

- (IBAction)handleRunButtonAction:(id)sender {
    
    self.isRideSelected = NO;
    self.isRunSelected = !self.isRideSelected;
    
    if (!self.isRunSelected) {
        self.runButton.backgroundColor = [UIColor whiteColor];
    } {
        self.runButton.backgroundColor = orange;
    }
    
    self.rideType = self.isRideSelected ? 0 : 1;
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self dismissPopVC];
}




//- (IBAction)handleTapAction:(id)sender {
//    
//    //self.maskView.hidden = NO;
//}

- (void)handleTapMaskView{
    
    // popVC消失
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self dismissPopVC];
    
}

- (void)dismissPopVC{
    
    //
    NSLog(@"PopVC:rideType:%d", self.rideType);
    
    // 1.3 调用block
//    self.passValueBlock(self.rideType);
    
    // 2、通知传值
    // 2.1 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PassValueNotification" object:self userInfo:@{@"value":@(self.rideType)}];
    
    // popVC消失
    [self dismissViewControllerAnimated:YES completion:nil];

}


//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSLog(@"segue.destinationVC:%@", segue.destinationViewController);
}





@end
