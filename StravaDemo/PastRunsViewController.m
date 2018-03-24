//
//  PastRunsViewController.m
//  StravaDemo
//
//  Created by owen on 16/6/8.
//  Copyright © 2016年 owen. All rights reserved.
//

/**
 * 功能：显示已完成的run记录（table view），数据从数据库加载
   1、显示运动纪录
   2、下拉刷新
   3、读数据库
 */

#import "PastRunsViewController.h"
#import "DetailViewController.h"
#import "RunCellTableViewCell.h"
#import "Run.h"
#import "DetailTableViewController.h"

@interface PastRunsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *pastRuns;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIRefreshControl *refreshControl;


@end

@implementation PastRunsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置table view
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 362;
    
    // 设置导航栏样式
    [self setUpNavigationBar];
    
    // loadData
    [self loadData];
    
    // 配置下拉刷新
    [self setUpRefreshControl];
}

- (void)viewWillAppear:(BOOL)animated{
    
    // loadData
    //[self loadData];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 刷新整个列表
    [self.tableView reloadData];
}

// 设置导航栏样式
- (void)setUpNavigationBar{
    
    UIColor *blackColor = [UIColor colorWithRed:32.0/255 green:32.0/255 blue:32.0/255 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = blackColor;
    self.title = @"Past Run";
    self.view.backgroundColor = blackColor;
}

// 从数据库中加载数据
- (void)loadData{
    //
    NSLog(@"PastRuns:loadData");
    
    // 获取managedObjectContext
    id appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    // 获取数据
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *run = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:run];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];//排序方式，以时间戳排序
    
    self.pastRuns = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    // 取到数据后，停止菊花、更新table view
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];//更新table view
    
}

// 配置下拉刷新
- (void)setUpRefreshControl{
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

// 下拉刷新处理方法
- (void)handleRefresh{
    
    //
    [self loadData];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //
    //NSLog(@"sender:%@", sender);
    
    //NSString *identifier = @"ShowDetail";
    NSString *identifier = @"ShowNewDetail";
    
    // 根据点击的cell获取当前cell的indexPath
    UITableViewCell *cell = (UITableViewCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // 转场传值（将对应cell的run数据传给detailVC）
    if ([segue.identifier isEqualToString:identifier]) {
        
        //
//        DetailViewController *detailVC = (DetailViewController *)segue.destinationViewController;
//        // 传值
//        detailVC.run = [self.pastRuns objectAtIndex:indexPath.row];
        
        // 传值給新的VC
        DetailTableViewController *detailTVC = (DetailTableViewController *)segue.destinationViewController;
        detailTVC.run = [self.pastRuns objectAtIndex:indexPath.row];
    }
    
    
}


#pragma mark - DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.pastRuns count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //RunCellTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RunCell"];
    RunCellTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RunCellWithPolyline"];
    
    //
    //cell.mapImageView.backgroundColor = [UIColor orangeColor];
    
    Run *run = [self.pastRuns objectAtIndex:indexPath.row];
    
//    cell.distanceLabel.text = [NSString stringWithFormat:@"Dis:%0.2fKm", run.distance.floatValue / 1000];
//    
//    // 将UTC时间戳转换为系统时间字符串
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterMediumStyle];
//    cell.dateLabel.text = [formatter stringFromDate:run.timestamp];
    
    cell.passRun = run;
    cell.indexPath = indexPath;
    
    
    return cell;
}

#pragma mark - delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 点击cell后取消cell的选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    
////    RunCellTableViewCell *cell = (RunCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RunCellWithPolyline"];
////    
////    [cell layoutIfNeeded];
////    CGFloat headerHeight = cell.headerView.frame.size.height;
////    CGFloat polylineViewHeight = cell.polylineView.frame.size.height;
////    return headerHeight + polylineViewHeight;
//    
//    CGFloat polylineViewHeight = (241.0 / 375) * [UIScreen mainScreen].bounds.size.width;
//    return 120.5 + polylineViewHeight;
//}




@end
