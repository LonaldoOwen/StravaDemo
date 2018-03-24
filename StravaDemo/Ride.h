//
//  Ride.h
//  StravaDemo
//
//  Created by owen on 16/5/25.
//  Copyright © 2016年 owen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Goal;

@interface Ride : NSObject

@property (strong, nonatomic) NSArray *days;
@property (assign, nonatomic) NSInteger distance;
@property (assign, nonatomic) NSInteger elapsedTime;
@property (assign, nonatomic) NSInteger elevationGain;
@property (assign, nonatomic) NSInteger movingTime;
@property (strong, nonatomic) Goal *goal;

@end
