//
//  PopViewController.h
//  StravaDemo
//
//  Created by owen on 16/6/14.
//  Copyright © 2016年 owen. All rights reserved.
//

#import <UIKit/UIKit.h>

// 1、block 传值
// 1.1 定义block
typedef void (^PassValueBlock) (BOOL typeFlag);

@interface PopViewController : UIViewController

@property (nonatomic) BOOL rideType;

// 1.2 实例化block
/**
 * 注意：blcok使用copy？？？
 */
@property (copy, nonatomic) PassValueBlock passValueBlock;

@end
