//
//  SavingTableViewCell.h
//  StravaDemo
//
//  Created by owen on 16/9/5.
//  Copyright © 2016年 owen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (strong, nonatomic) NSArray *dataArray;

@end
