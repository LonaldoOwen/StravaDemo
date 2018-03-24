//
//  ContainerViewController.m
//  StravaDemo
//
//  Created by owen on 16/5/25.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "ContainerViewController.h"
#import "CustomView.h"

@interface ContainerViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1Width;


@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    //UITabBar
    
    // 设置view1的固定宽度
    [self.view1Width setConstant:CGRectGetWidth(self.view.frame)];
    
    //
//    CustomView *customView = [[CustomView alloc] init];
//    customView.frame = CGRectMake(0, 0, 300, 200);
//    [self.view addSubview:customView];
}


@end
