//
//  WeekDataViewController.h
//  StravaDemo
//
//  Created by owen on 16/5/24.
//  Copyright © 2016年 owen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Goal.h"
#import "Page.h"

@interface WeekDataViewController : UIViewController


//@property (retain, nonatomic) NSString *weekText;
//@property (retain, nonatomic) NSString *mileText;
//@property (retain, nonatomic) NSString *timeText;
//@property (retain, nonatomic) NSString *heightText;
//@property (retain, nonatomic) NSString *dayText;
//@property (retain, nonatomic) NSArray *days;
//@property (retain, nonatomic) NSDictionary *goal;

@property (strong, nonatomic) Page *page;
@property (copy, nonatomic) NSString *pageType;
@property (assign, nonatomic) BOOL isFirstLoad;//判断是否是第一次加载VC

@end
