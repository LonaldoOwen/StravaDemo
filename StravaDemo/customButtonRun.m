//
//  customButtonRun.m
//  StravaDemo
//
//  Created by owen on 16/8/30.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "customButtonRun.h"

@implementation customButtonRun

- (void)setUp{

    self.layer.cornerRadius = 40.0;
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    UIColor *orange = [UIColor colorWithRed:239.0/255 green:52.0/255 blue:9.0/255 alpha:1.0];
    self.layer.backgroundColor = orange.CGColor;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        //[self setUp];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        //[self setUp];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
