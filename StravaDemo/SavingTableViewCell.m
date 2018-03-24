//
//  SavingTableViewCell.m
//  StravaDemo
//
//  Created by owen on 16/9/5.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "SavingTableViewCell.h"


@interface SavingTableViewCell ()<UIPickerViewDataSource, UIPickerViewDelegate>




@end

@implementation SavingTableViewCell


- (void)setUp{
    NSLog(@"setUp in cell");
    
    //self.pickerView.dataSource = self;
    //self.pickerView.delegate = self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


// MARK:UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 5;
}


// MARK:UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSLog(@"titleForRow: in cell");
    
    return @"picker";
}

@end
