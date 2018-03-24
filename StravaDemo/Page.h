//
//  Page.h
//  StravaDemo
//
//  Created by owen on 16/5/25.
//  Copyright © 2016年 owen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ride.h"
//#import "Run.h"


@interface Page : NSObject

@property (assign, nonatomic) NSInteger resourceState;
@property (copy, nonatomic) NSString *type;
@property (assign, nonatomic) NSInteger week;
@property (assign, nonatomic) NSInteger year;
@property (strong, nonatomic) Ride *ride;
@property (strong, nonatomic) Ride *run;
//@property (strong, nonatomic) Run *run;

@end
