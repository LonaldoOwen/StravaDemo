//
//  Day.h
//  StravaDemo
//
//  Created by owen on 16/5/25.
//  Copyright © 2016年 owen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Day : NSObject

@property (assign, nonatomic) NSInteger distance;//距离
@property (assign, nonatomic) NSInteger elapsedTime;//流逝时间（总时间）
@property (assign, nonatomic) NSInteger elevationGain;//爬升
@property (assign, nonatomic) NSInteger movingTime;//移动时间（实际移动时间，不含休息）

@end
