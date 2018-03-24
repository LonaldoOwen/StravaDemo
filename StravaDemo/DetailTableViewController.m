//
//  DetailTableViewController.m
//  StravaDemo
//
//  Created by owen on 16/10/23.
//  Copyright © 2016年 owen. All rights reserved.
//
/**
 *  功能：新UI显示完成的运动数据详情
    1、
    2、
 */

#import "DetailTableViewController.h"
#import "RunDataViewController.h"
#import "Run.h"

@interface DetailTableViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;



@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置约束的必要宽高设置
    CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    CGFloat width = SCREEN_WIDTH;
    CGFloat height = SCREEN_WIDTH * 1.1 + 44;
    CGRect frame = CGRectMake(0, 0, width, height);
    self.containerView.frame = frame;
    
    //


}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
        
}

//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"ShowContainerRunData"]) {
        // 将run数据传递給RunDataViewController
        RunDataViewController *runDataVC = (RunDataViewController *)segue.destinationViewController;
        runDataVC.passRun = self.run;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SectionOneCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//无选中状态
        //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //cell.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
        
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.run.runDescription];
        } else if (indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"z_tabbar_me_normal"];
            cell.textLabel.text = @"I have not a geer";
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"未发现路段";
        cell.detailTextLabel.text = @"了解路段和成就";
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    
    UIView *headerView = [[UIView alloc] init];
    
    if (section == 1) {
        headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 30.0);
        UILabel *label = [[UILabel alloc] init];
        label.frame = headerView.bounds;
        [headerView addSubview:label];
        label.text = @"  路段";
        [label setFont:[UIFont systemFontOfSize:14.0]];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section != 0) {
         return 30.0;
    }
    
    return 0;
}




@end
