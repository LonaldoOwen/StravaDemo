//
//  RunCellTableViewCell.h
//  StravaDemo
//
//  Created by owen on 16/6/8.
//  Copyright © 2016年 owen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Run.h"

@interface RunCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *staticImageView;
@property (weak, nonatomic) IBOutlet UIView *polylineView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *creationLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) Run *passRun;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
