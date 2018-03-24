//
//  SavingDateViewController.m
//  StravaDemo
//
//  Created by owen on 16/9/2.
//  Copyright © 2016年 owen. All rights reserved.
//

/**
 * 功能：运动结束，保存运动数据
   1、设置运动信息(包含上传图片、运动标题、类型、描述等)
   2、保存运动数据
 */

#import "SavingDataViewController.h"
#import "Run.h"
#import "Location.h"
#import "SavingTableViewCell.h"

#import <CoreLocation/CoreLocation.h>

@import Photos;


#define kPickerViewTag              99  // view tag identifiying the picker view

#define kTitleKey       @"title"        // key for obtaining the data source item's title
#define kTypeKey        @"type"         // key for obtaining the data source item's type value

// keep track of which rows have date cells
#define kHasPickerRow0     0
#define kHasPickerRow1     1




static NSString *kNameCellID = @"nameCell";
static NSString *kRunCellID = @"runCell";
static NSString *kDescriptionCellID = @"descriptionCell";
static NSString *kPickerCellID = @"pickerCell";



@interface SavingDataViewController ()<UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *section0FooterView;


@property (strong, nonatomic) NSArray *runDataArray;
@property (strong, nonatomic) NSArray *markDataArray;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSArray *pickerDataArray;
@property (strong, nonatomic) NSMutableArray *imageUrlsArray;



@property (strong, nonatomic) NSIndexPath *pickerViewIndexPath;
@property (strong, nonatomic) UITextView *textView;
//@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGRect keyboardRect;




@end

@implementation SavingDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    
    // create data for picker view
    self.runDataArray = @[@"骑行", @"跑步", @"游泳", @"马拉松", @"登山", @"皮划艇", @"远足"];
    self.markDataArray = @[@"无", @"运动", @"健身"];
    
    // create data for model
    NSMutableDictionary *itemOne = [@{ kTitleKey : @"名称：", kTypeKey : @"午后骑行"} mutableCopy];
    NSMutableDictionary *itemTwo = [@{ kTitleKey : @"运动：", kTypeKey : @"跑步"} mutableCopy];
    NSMutableDictionary *itemThree = [@{ kTitleKey : @"标签：", kTypeKey : @"选择标签"} mutableCopy];
    NSMutableDictionary *itemFour = [@{ kTypeKey : @"说明："} mutableCopy];
    
    NSArray *section0 = @[itemOne];
    NSArray *section1 = @[itemTwo, itemThree, itemFour];
    self.dataArray = @[section0, section1];
    
    
    // 点击空白区域收回键盘
    [self setUpForDismissKeyboard];
    
    // 配置collectionView
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.imageUrlsArray = [NSMutableArray array];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
- (void)viewWillAppear:(BOOL)animated{
    
    //
    NSLog(@"self.distance:%f", self.distance);
    NSLog(@"self.seconds:%d", self.seconds);
}

- (void)viewDidDisappear:(BOOL)animated{
    NSLog(@"viewDidDisappear: in savingDataVC");
}



// 继续button：
- (IBAction)clickContinueButtonAction:(id)sender {
    
    //
    //[self notificationToMapVCWithInfo:@"resumeRun"];
    [self dismissViewControllerAnimated:YES completion:^{
        //
        [self notificationToMapVCWithInfo:@"resumeRun"];
    }];
    
}

// 存储button：
- (IBAction)clickSaveButtonAction:(id)sender {
    
    // 存储数据
    [self saveData];
    // 发送通知（让mapVC关闭计时页面）
    /**
     * 问题：在此处发送通知，再关闭当前页面，导致回到mapVC时，mapVC无法关闭
       解决：先关闭当前VC，在completion blcok中发送通知（顺序影响结果，但是为什么呢）
     */
    //[self notificationToMapVCWithInfo:@"dismissMapVC"];
    // 
    [self dismissViewControllerAnimated:YES completion:^{
        // 发送通知（让mapVC关闭计时页面）
        [self notificationToMapVCWithInfo:@"dismissMapVC"];
    }];
    
    //
    
}

//
- (IBAction)clickImagePikcerButtonAction:(id)sender {
    
    // 从系统相册选择照片
    // 判断设备支持数据类型
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        // 实例化对象imagePicker
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // 配置imagePicker
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        
        // 呈现imagePicker
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    } else {
        
        NSLog(@"相册不可用");
        
    }
}



// MARK:helper method
//
- (void)saveData{
    NSLog(@"saving...");
    
    // 获取managedObjectContext
    id appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];

    
    // 创建Run实体
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];//
    // 增加实体属性
    NSMutableDictionary *itemOne = [[self.dataArray objectAtIndex:0] lastObject];
    newRun.name = [itemOne objectForKey:kTypeKey];
    NSMutableDictionary *itemTwo = [[self.dataArray objectAtIndex:1] objectAtIndex:0];
    newRun.type = [itemTwo objectForKey:kTypeKey];
    NSMutableDictionary *itemThree = [[self.dataArray objectAtIndex:1] objectAtIndex:1];
    newRun.tag = [itemThree objectForKey:kTypeKey];
    NSMutableDictionary *itemFour = [[self.dataArray objectAtIndex:1] objectAtIndex:2];
    newRun.runDescription = [itemFour objectForKey:kTypeKey];
    
    NSMutableArray *locationsArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        
        // 创建Location实体
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = @(location.coordinate.latitude);
        locationObject.longitude = @(location.coordinate.longitude);
        locationObject.speed = @(location.speed);
        locationObject.course = @(location.course);
        locationObject.horizontalAccuracy = @(location.horizontalAccuracy);
        locationObject.verticalAccuracy = @(location.verticalAccuracy);
        
        [locationsArray addObject:locationObject];
        
    }
    
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationsArray];
    
    // 保存context
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

// 发送通知到mapView
- (void)notificationToMapVCWithInfo:(NSString *)string{
    NSLog(@"post notification");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationToMapVC" object:self userInfo:@{@"value": string}];
}


// 点击空白区域收回键盘
- (void) setUpForDismissKeyboard{
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnywhereToDismissKeyboard:)];
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    // 监听键盘弹起
    [notificationCenter addObserverForName:UIKeyboardWillShowNotification object:nil queue:mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        //
        [self.tableView addGestureRecognizer:singleTap];
        
        // 获取键盘高度
        NSDictionary *userInfo = [note userInfo];
        NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        //CGFloat keyboardHeight = keyboardRect.size.height;
        //self.keyboardHeight = keyboardHeight;//存储获取的键盘高度，用于计算
        self.keyboardRect = keyboardRect;
        
    }];
    
    // 监听键盘收起
    [notificationCenter addObserverForName:UIKeyboardWillHideNotification object:nil queue:mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        //
        [self.tableView removeGestureRecognizer:singleTap];
    }];
}

// handle tap action
- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)recognizer{
    
    // 收回self.tableView所有subview的firstResponder
    [self.tableView endEditing:YES];
}




// MARK:

/*! Determines if the given indexPath has a cell below it with a UIDatePicker.
 
 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkPickerViewCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:1]];
    UIPickerView *checkPickerView = (UIPickerView *)[checkPickerViewCell viewWithTag:kPickerViewTag];
    
    hasDatePicker = (checkPickerView != nil);
    return hasDatePicker;
}


/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlinePickerView
{
    return (self.pickerViewIndexPath != nil);
}


/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
 
 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlinePickerView] && self.pickerViewIndexPath.row == indexPath.row);
}


/*! Determines if the given indexPath points to a cell that contains the start/end dates.
 
 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasValue:(NSIndexPath *)indexPath
{
    BOOL hasValue = NO;
    
    if ((indexPath.row == kHasPickerRow0) ||
        (indexPath.row == kHasPickerRow1 || ([self hasInlinePickerView] && (indexPath.row == kHasPickerRow1 + 1))))
    {
        hasValue = YES;
    }
    
    return hasValue;
}



/*! Adds or removes a UIDatePicker cell below the given indexPath.
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:1]];
    
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath]) {
        
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        NSLog(@"insert...");
    }
    
    [self.tableView endUpdates];
}


/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath.section:%ld, indexPath.row:%ld", (long)indexPath.section, (long)indexPath.row);
    
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    BOOL before = NO;   // indicates if the  picker view is below "indexPath", help us determine which row to reveal
    
    if ([self hasInlinePickerView]) {
        
        before = self.pickerViewIndexPath.row < indexPath.row;//???
    }
    
    BOOL sameCellClicked = (self.pickerViewIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlinePickerView]) {
        
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pickerViewIndexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        self.pickerViewIndexPath = nil;
    }
    
    if (!sameCellClicked) {
        
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);//点击的indexPath前面有pickerView，先删除pickerView，所以rowToReveal＝indexPath.row - 1；否则rowToReveal＝indexPath.row ；
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:1];
        
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.pickerViewIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:1];//pickerViewIndexPath要比点击的cell大1
        
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our picker view of the current value to match the current cell
    
    
}



// MARK:UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"textViewDidBeginEditing");
    
    // 获取临时textView
    self.textView = textView;
    
    // 获取textView所在cell
    // 可以通过获取的被遮挡的cell的farme，来计算tableView应该移动的距离
    UITableViewCell *cell = (UITableViewCell *)[[self.textView superview] superview];
    NSLog(@"cell:%@", cell);
    
    CGFloat distanceY = self.keyboardRect.origin.y - cell.frame.origin.y;
    if (distanceY < (44 + 80)) {
        
        // 如果y距离小于cell高度和footer高度只和，即认为遮挡了
        CGRect toFrame = self.tableView.frame;
        toFrame.origin.y = -((44 + 80) - distanceY);
        
        [UIView animateWithDuration:0.3 animations:^{
            //
            self.tableView.frame = toFrame;
        }];

    
    }
    
    // 动画调整tableView的offset
    //[self.tableView setContentOffset:CGPointMake(0, 100) animated:YES];
    
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    NSLog(@"textViewShouldEndEditing");
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"textViewDidEndEditing");
    
    // 更新textView 对应的model数据
    NSArray *section1 = [self.dataArray objectAtIndex:1];
    NSMutableDictionary *itemFour = [section1 objectAtIndex:2];
    [itemFour setValue:textView.text forKey:kTypeKey];
    
    // 动画调整tableView的offset
    //[self.tableView setContentOffset:CGPointMake(0, 100) animated:YES];
    CGRect frame = self.tableView.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:0.3 animations:^{
        //
        self.tableView.frame = frame;
    }];
    
    // 取消第一响应（收起键盘）
    [textView resignFirstResponder];
    
}




//MARK:UITextFieldDelegate

//
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
    
    // 更新textField对应的model数据
    NSArray *section0 = [self.dataArray objectAtIndex:0];
    NSMutableDictionary *itemOne = [section0 lastObject];
    [itemOne setValue:textField.text forKey:kTypeKey];

    
}

//
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    
    [textField resignFirstResponder];
    
    return YES;
}






// MARK:UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return self.pickerDataArray.count;
}


// MARK:UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    //NSLog(@"titleForRow: in cell");
    
    NSString *name = [self.pickerDataArray objectAtIndex:row];
    return name;
}

//
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    /**
     * 说明：pickerView选择内容后，更新cell的对应数据
     */
    
    // 获取需要更新内容的cell的indexPath
    NSIndexPath *targetedCellIndexpath = nil;
    
    if ([self hasInlinePickerView]) {
        
        targetedCellIndexpath = [NSIndexPath indexPathForRow:self.pickerViewIndexPath.row - 1 inSection:1];
    }
    
    
    // 更新data model
    NSString *typeValue = [self.pickerDataArray objectAtIndex:row];
    
    NSArray *section1 = [self.dataArray objectAtIndex:1];
    NSMutableDictionary *itemData = [section1 objectAtIndex:targetedCellIndexpath.row];
    [itemData setValue:typeValue forKey:kTypeKey];
    
    
    // 更新cell
    // 根据indexapath，获取cell
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexpath];
    
    // 更新cell的data string
    UITextField *typeText = [cell viewWithTag:21];
    typeText.text = typeValue;
    
}







#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    NSLog(@"numberOfSectionsInTableView:");
    //return 2;
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    NSLog(@"numberOfRowsInSection:");
    
    if (section == 1) {
        
        if ([self hasInlinePickerView]) {
            
            NSInteger numRows = [[self.dataArray objectAtIndex:section] count];
            return ++numRows;
        }
        
    }
    
    NSArray *sectionArray = [self.dataArray objectAtIndex:section];
    
    return sectionArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    NSLog(@"section:%ld, row:%ld", (long)indexPath.section, (long)indexPath.row);
    
    UITableViewCell *cell = nil;
    
    NSString *cellID = kDescriptionCellID;
    
    if (indexPath.section == 0) {
        
        // 名称cell
        cellID = kNameCellID;
        
    } else {
        
        // 点击可显示pickerView cell
        if ([self indexPathHasPicker:indexPath]) {
            
            cellID = kPickerCellID;
            
            // 当显示pickerCell时，需要单独获取pickerCell，并配置pickerView
            SavingTableViewCell *pickerCell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
            
            pickerCell.pickerView.dataSource = self;
            pickerCell.pickerView.delegate = self;
            self.pickerDataArray = indexPath.row == 1 ? self.runDataArray : self.markDataArray;//row＝1显示运动类型picker；其他的显示标签picker
            
            return pickerCell;
            
        } else if ([self indexPathHasValue:indexPath]) {
            
            cellID = kRunCellID;
            
        }
        
    }
    
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if ([cellID isEqualToString:kRunCellID]) {
        
    }
    
    // 收起键盘方法1:textField自身代理方法
    //UITextField *textField = [cell viewWithTag:11];
    //textField.delegate = self;
    
    
    // 设置数据
    NSArray *sectionArray = [self.dataArray objectAtIndex:indexPath.section];
    NSDictionary *itemData = [sectionArray objectAtIndex:indexPath.row];
    
    
    if ([cellID isEqualToString:kNameCellID]) {
        
        UITextField *nameText = [cell viewWithTag:11];
        nameText.text = [itemData objectForKey:kTypeKey];
        nameText.delegate = self;
        
    } else if ([cellID isEqualToString:kRunCellID]) {
        
        UILabel *runLabel = [cell viewWithTag:20];
        runLabel.text = [itemData objectForKey:kTitleKey];
        UILabel *runTypeLabel = [cell viewWithTag:21];
        runTypeLabel.text = [itemData objectForKey:kTypeKey];
        
    } else if ([cellID isEqualToString:kDescriptionCellID]) {
        
        UITextView *descriptionTextView = [cell viewWithTag:41];
        descriptionTextView.text = [itemData objectForKey:kTypeKey];
        descriptionTextView.delegate = self;
    }
    
    return cell;
}


// MARK:/*****      UITableViewDelegate    ******/
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 收起textField键盘方法2:tableView收回first responder
    [tableView endEditing:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.reuseIdentifier == kRunCellID) {
        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
    }
}

//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20;
}

//
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 90;
}

//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return ([self indexPathHasPicker:indexPath] ? 180 : self.tableView.rowHeight);
}

//
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        
        return self.section0FooterView;
        
    }
    
    return nil;
}



// MARK:UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //return 5;
    return self.imageUrlsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    
    // 通过asset url 从相册获取图像
    // 获取保存的asset url
    NSURL *assetUrl = [self.imageUrlsArray objectAtIndex:indexPath.row];
    
    // 根据asset rul 获取assets
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[assetUrl] options:nil];
    PHAsset *asset = [fetchResult firstObject];
    
    // 实例化对象imageManager
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    // 创建并配置影响传送选项
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    //options.synchronous = YES;
    
    // 请求图片
    [imageManager requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 获取图像并设置cell item
        if (result) {
            
            UIImageView *imageView = [cell viewWithTag:11];
            imageView.image = result;
            
        }
        
    }];
    
    
    return cell;
}



// MARK:UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 添加overlay view
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIView *overlayView = [[UIView alloc] init];
    CGRect frame = CGRectMake(-5, -5, cell.frame.size.width + 10, cell.frame.size.height + 10);
    overlayView.frame = frame;
    
    overlayView.layer.borderColor = [[UIColor orangeColor] CGColor];
    overlayView.layer.borderWidth = 2.0;
    
    [cell addSubview:overlayView];
    cell.clipsToBounds = NO;

    
    // 显示action sheet
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // 处理删除collectionView cell item
        // 取消cell item的选中状态（移除overlay）
        [overlayView removeFromSuperview];
        
        // 删除cell item
        // 更新model data
        [self.imageUrlsArray removeObjectAtIndex:indexPath.row];
        // 删除cell item
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        // 取消cell item的选中状态（移除overlay）
        /**
         * 问题：action sheet消失后，overlay才消失；理想情况时它们同时进行？？？
         */
        [overlayView removeFromSuperview];
    }];
    
    [alertVC addAction:deleteAction];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}


// MARK:UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    // 获取asset url，存储到imageUrlsArray，供collectionView使用
    NSURL *assetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    [self.imageUrlsArray insertObject:assetUrl atIndex:0];
    
    // 收起imagePicker
    [self dismissViewControllerAnimated:YES completion:^{
        
        // collectionView插入cell item
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        NSArray *indexPaths = @[indexPath];
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
        
    }];
}



@end
