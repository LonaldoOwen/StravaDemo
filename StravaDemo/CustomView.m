//
//  CustomView.m
//  StravaDemo
//
//  Created by owen on 16/5/22.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "CustomView.h"

@interface CustomView ()



@end

@implementation CustomView

//
// 代码加载
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

// IB加载
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setUpView];
    }
    
    return self;
}

- (void)setUpView{
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CustomView" owner:self options:nil];
    self.contentView = [array firstObject];
    [self addSubview:self.contentView];
    
}

//- (void)awakeFromNib{
//    
//    NSLog(@"awakeFromNib");
//    
//    [[NSBundle mainBundle] loadNibNamed:@"CustomView" owner:self options:nil];
//    
//    [self addSubview:self.contentView];
//    
//    
//}






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
