//
//  SavingTableViewController.m
//  StravaDemo
//
//  Created by owen on 16/9/6.
//  Copyright © 2016年 owen. All rights reserved.
//
/**
 *  功能：test：练习使用
    1、
    2、
 */

#import "SavingTableViewController.h"
#import "SavingTableViewCell.h"

@import Photos;
@import PhotosUI;



#define kPickerViewTag              99  // view tag identifiying the picker view

#define kTitleKey       @"title"        // key for obtaining the data source item's title
#define kTypeKey        @"type"    // key for obtaining the data source item's type value

// keep track of which rows have date cells
#define kHasPickerRow0     0
#define kHasPickerRow1     1



static NSString *kNameCellID = @"nameCell";
static NSString *kRunCellID = @"runCell";
static NSString *kDescriptionCellID = @"descriptionCell";
static NSString *kPickerCellID = @"pickerCell";
//static NSString *kRightDetailCellID = @"rightDetailCell";

@interface SavingTableViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *section0FooterView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;



@property (strong, nonatomic) NSArray *runDataArray;
@property (strong, nonatomic) NSArray *markDataArray;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSArray *pickerDataArray;
@property (strong, nonatomic) NSMutableArray *imagesArray;

@property (strong, nonatomic) NSIndexPath *pickerViewIndexPath;
@property (nonatomic) int itemCount;

@property (strong, nonatomic) PHImageManager *imageManager;

@end



@implementation SavingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // create data for picker view
    self.runDataArray = @[@"骑行", @"跑步", @"游泳", @"马拉松", @"登山", @"皮划艇", @"远足"];
    self.markDataArray = @[@"无", @"运动", @"健身"];
    
    // create data for model
    NSMutableDictionary *itemOne = [@{ kTitleKey : @"午后骑行"} mutableCopy];
    NSMutableDictionary *itemTwo = [@{ kTitleKey : @"跑步"} mutableCopy];
    NSMutableDictionary *itemThree = [@{ kTitleKey : @"选择标签"} mutableCopy];
    NSMutableDictionary *itemFour = [@{ kTitleKey : @"说明："} mutableCopy];
    
    NSArray *section0 = @[itemOne];
    NSArray *section1 = @[itemTwo, itemThree, itemFour];
    self.dataArray = @[section0, section1];
    
    //
    //self.tableView.rowHeight = 180;
    
    
    // 配置collection view
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    //self.collectionView.clipsToBounds = NO;//允许subviews超出边界，会导致collectionView滚动时滚出边界
    //self.collectionView.allowsMultipleSelection = YES;//允许多选
    self.itemCount = 0;
    self.imagesArray = [NSMutableArray array];
    
    //
    self.imageManager = [[PHImageManager alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // 收起键盘
    [self.tableView endEditing:YES];
}


// MARK: action

// 选择照片
static __weak UITableViewController  *weakSelf ;
- (IBAction)clickPhotoButtonAction:(id)sender {
    
    // 从相册选择照片
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        // 实例化UIImagePickerController
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // 设置
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        //
        //imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];???
        //imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        
        // 设置代理
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    } else {
        
        NSLog(@"相册不可用");
        
    }

    
    // test:验证给collectionView插入item
    //++self.itemCount;
    //[self.imagesArray insertObject:@(self.itemCount) atIndex:0];
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    //NSArray *indexPaths =  @[indexPath];
    //[self.collectionView insertItemsAtIndexPaths:indexPaths];
}





// MARK:helper method

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
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);//点击的indexPath之前面有pickerView，先删除pickerView，所以rowToReveal＝indexPath.row - 1；否则rowToReveal＝indexPath.row ；
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:1];
        
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.pickerViewIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:1];//pickerViewIndexPath要比点击的cell大1
        
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our picker view of the current value to match the current cell
    

}




//MARK:     /********     UITextFieldDelegate     *******/
// 
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    
    [textField resignFirstResponder];
    
    return YES;
}


// MARK:/******      UIPickerViewDataSource     ******/
//
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{

    return self.pickerDataArray.count;
}


// MARK:/******        UIPickerViewDelegate     *******/
//
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
    [itemData setValue:typeValue forKey:kTitleKey];
    
    
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
        nameText.text = [itemData objectForKey:kTitleKey];
        
    } else if ([cellID isEqualToString:kRunCellID]) {
        
        UILabel *runLabel = [cell viewWithTag:21];
        runLabel.text = [itemData objectForKey:kTitleKey];
        
    } else if ([cellID isEqualToString:kDescriptionCellID]) {
        
        UITextView *descriptionTextView = [cell viewWithTag:41];
        descriptionTextView.text = [itemData objectForKey:kTitleKey];
    }
    
    return cell;
}


// MARK:/******     UITableViewDelegate      ******/
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    // 此处返回的高度决定了footer的高度，与返回的footer view尺寸无关
    return 80;
}

//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return ([self indexPathHasPicker:indexPath] ? 180 : self.tableView.rowHeight);
}

//
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    // section0 创建自定义footer
    if (section == 0) {
        
        return self.section0FooterView;
        
    }
    
    return nil;
}


// MARK:/******      UICollectionViewDataSource     ******/
//
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //return self.itemCount;
    return self.imagesArray.count;
}

//
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 获取复用item
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    
    // 设置item数据
    //cell.backgroundColor = [UIColor orangeColor];
//    NSData *imageData = [self.imagesArray objectAtIndex:indexPath.row];
    
    NSURL *assetUrl = [self.imagesArray objectAtIndex:indexPath.row];
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[assetUrl] options:nil];
    PHAsset *asset = [fetchResult firstObject];
    
    //
    /**
     * 说明：deliveryMode默认是PHImageRequestOptionsDeliveryModeOpportunistic，异步时asynchronous会加载多张不同质量的图片；同步时synchronous只加载一张图片
     * 问题：加载多张图片，导致collectionView插入item时crash（）
     */
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    //options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    //options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    [imageManager requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        //
        NSLog(@"result:%@", result);
        if (result) {
            
            UIImageView *imageView = [cell viewWithTag:11];
            imageView.image = result;
        }
        
    }];
    
    
//    UIImage *image = [UIImage imageWithData:imageData];
//    UIImageView *imageView = [cell viewWithTag:11];
//    imageView.image = image;
    
    return cell;
}


// MARK:/******     UICollectionViewDelegate     ******/
//
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //
    NSLog(@"item:%ld", (long)indexPath.row);
    
    // 点击item，给item添加一个subview（带border的view），表示其被选中
    //
    UICollectionViewCell *item = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIView *maskView = [[UIView alloc] init];
    maskView.frame = CGRectMake(-2.5, -2.5, item.frame.size.width + 5, item.frame.size.height + 5);
    maskView.layer.borderColor = [UIColor orangeColor].CGColor;
    maskView.layer.borderWidth = 1.0;
    
    [item addSubview:maskView];
    item.clipsToBounds = NO;
    
    
    // 点击item，弹出action sheet
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // 删除item
        NSLog(@"delete photo");
        // 移除overlay
        [maskView removeFromSuperview];//否则插入item时直接带overlay
        // 更新model
        [self.imagesArray removeObjectAtIndex:indexPath.row];
        // 删除item
        NSArray *indexPaths = @[indexPath];
        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
        //
        
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        // 移除overlay
        /**
         * 说明：此处需要优化
         * 问题：此处移除maskView，是先移除action sheet，再一次maskView（strava是同步进行）？？？
         */
        NSLog(@"cancel");
        [maskView removeFromSuperview];
        //[collectionView deselectItemAtIndexPath:indexPath animated:YES];
        //[self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
        //NSLog(@"selected state:%d", item.selected);

        
    }];
    
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    // text
    NSLog(@"selected state:%d", item.selected);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"didDeselectItemAtIndexPath");
    NSLog(@"section:%lu, item:%lu", (long)indexPath.section, (long)indexPath.item);
    
}


// MARK:/******    UIImagePickerControllerDelegate     *******/

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"didFinishPickingMediaWithInfo");
    
    // 选择照片完成,存储图片
    NSLog(@"info:%@", info);
    
    
    // 获取图像的 Assets Library URL
    NSURL *assetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    [self.imagesArray insertObject:assetUrl atIndex:0];
    
//    // collectionView 插入item
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
//    NSArray *indexPaths = @[indexPath];
//    [self.collectionView insertItemsAtIndexPaths:indexPaths];

    
    
    
//    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[imageUrl] options:nil];
//    PHAsset *asset = [fetchResult firstObject];
//    
//    PHImageManager *imageManager = [PHImageManager defaultManager];
//    
//    //
//    /**
//     * 说明：deliveryMode默认是PHImageRequestOptionsDeliveryModeOpportunistic，异步时asynchronous会加载多张不同质量的图片；同步时synchronous只加载一张图片
//     * 问题：加载多张图片，导致collectionView插入item时crash（）
//     */
//    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//    options.version = PHImageRequestOptionsVersionCurrent;
//    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;//
//    //options.synchronous = YES;
//    
//    [imageManager requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        
//        //
//        if (result) {
//            NSLog(@"get image");
//            NSLog(@"info:%@", info);
//            
//            //
//            BOOL isDegradedImage = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
//            if (isDegradedImage) {
//                NSLog(@"PHImageResultIsDegradedKey:%d", isDegradedImage);//result 中是否包含第质量的图像
//            }
//            
//            // 将图像保存到图像数组
//            NSData *imageData = UIImagePNGRepresentation(result);
//            [self.imagesArray insertObject:imageData atIndex:0];
//            
//            // collectionView 插入item
//            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
//            NSArray *indexPaths = @[indexPath];
//            [self.collectionView insertItemsAtIndexPaths:indexPaths];
//
//        
//        }
//        
//        
//    }];
    
    
    
    /**
     * 问题：图片究竟要存在哪里呢？？Core Data？沙盒？还是？？？
     */
    
//    NSData *imageData = UIImagePNGRepresentation(image);
//    [self.imagesArray insertObject:imageData atIndex:0];
    
    
    // 照片选择完毕，关闭imagePicker
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissViewControllerAnimated");
        
        // collectionView 插入item
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        NSArray *indexPaths = @[indexPath];
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
        
    }];
    
    
    
    
}



@end
