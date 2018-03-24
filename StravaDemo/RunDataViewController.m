//
//  RunDataViewController.m
//  StravaDemo
//
//  Created by owen on 16/10/23.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "RunDataViewController.h"
#import <MapKit/MapKit.h>
#import "Location.h"
#import "Run.h"

@interface RunDataViewController ()<MKMapViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *distanceDscription;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *timeDescription;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *elevationDescription;
@property (weak, nonatomic) IBOutlet UILabel *elevation;
@property (weak, nonatomic) IBOutlet UILabel *calorieDescription;
@property (weak, nonatomic) IBOutlet UILabel *calorie;
@property (weak, nonatomic) IBOutlet UIView *kudosView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewWidth;

@property (nonatomic) CGFloat averageSpeed;
@property (nonatomic) CGFloat maxSpeed;

@end

//
//static CGFloat viewWidth = self.secondView.bounds.size.width;
//static CGFloat viewheight = self.secondView.bounds.size.height;
static CGFloat topMargin = 44.0;  // 上下边距（标题和距离值提示区域高度）
static CGFloat rightMargin = 16.0;// 坐标右侧边距
static CGFloat leftMargin = 44.0; // 左边距（速度值提示区域）
static CGFloat speedFeildHeight = 64.0;


@implementation RunDataViewController

//
- (void)setPassRun:(Run *)passRun{
    
    if (_passRun != passRun) {
        _passRun = passRun;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad");
    
    
    // 配置自动布局约束的宽高值
    CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    self.pageWidth.constant = SCREEN_WIDTH;
    self.pageHeight.constant = 1.1 * SCREEN_WIDTH;
    self.scrollViewHeight.constant = 1.1 * SCREEN_WIDTH;
    
    // 配置scrollView
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    // 配置pageControl
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
    
    //
    //[self createSpeedFeildUI];
    
    // 设置导航栏样式
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:32.0/255 green:32.0/255 blue:32.0/255 alpha:1.0];
    
    // 设置显示内容
    [self setUpDetailView];
    
    // 配置地图
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    
    // 此处加载地图会有点问题：地图level显示的不太合适
    //[self loadMap];
    NSLog(@"self.mapView:%@", self.mapView);
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"self.passRun:%@", self.passRun);

    // 加载地图
    [self loadMap];
    
    // 绘制图表
    [self drawChart];
    self.secondView.backgroundColor = [UIColor whiteColor];
    
    // 创建速度区域UI
    [self createSpeedFeildUI];
    [self.view layoutIfNeeded];
    
    
}


//
- (void)createSpeedFeildUI{
    
    UILabel *averageSpeedDescription = [[UILabel alloc] init];
    UILabel *averageSpeed = [[UILabel alloc] init];
    UIStackView *leftStackView = [[UIStackView alloc] initWithArrangedSubviews:@[averageSpeed, averageSpeedDescription]];
    leftStackView.alignment = UIStackViewAlignmentCenter;
    leftStackView.distribution = UIStackViewDistributionFillEqually;
    leftStackView.axis = UILayoutConstraintAxisVertical;
    
    UILabel *maxSpeedDescription = [[UILabel alloc] init];
    UILabel *maxSpeed = [[UILabel alloc] init];
    UIStackView *rightStackView = [[UIStackView alloc] initWithArrangedSubviews:@[maxSpeed, maxSpeedDescription]];
    rightStackView.alignment = UIStackViewAlignmentCenter;
    rightStackView.distribution = UIStackViewDistributionFillEqually;
    rightStackView.axis = UILayoutConstraintAxisVertical;
    
    UIStackView *outerStackView = [[UIStackView alloc] initWithArrangedSubviews:@[leftStackView, rightStackView]];
    outerStackView.axis = UILayoutConstraintAxisHorizontal;
    outerStackView.alignment = UIStackViewAlignmentCenter;
    outerStackView.distribution = UIStackViewDistributionFillEqually;
    
    [self.secondView addSubview:outerStackView];
    
    outerStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [outerStackView.leftAnchor constraintEqualToAnchor:self.secondView.leftAnchor].active = YES;
    [self.secondView.rightAnchor constraintEqualToAnchor:outerStackView.rightAnchor].active = YES;
    [self.secondView.bottomAnchor constraintEqualToAnchor:outerStackView.bottomAnchor].active = YES;
    [outerStackView.heightAnchor constraintEqualToConstant:speedFeildHeight].active = YES;
    
    averageSpeedDescription.text = @"averageSpeed";
    maxSpeedDescription.text = @"maxSpeed";
    averageSpeed.text = [NSString stringWithFormat:@"%0.1fkm/h", self.averageSpeed];
    maxSpeed.text = [NSString stringWithFormat:@"%0.1fkm/h", self.maxSpeed];
    
    
}


// #MARK: /***********  draw chart
- (void)drawChart{
    
    // 计算数据
    CGFloat viewWidth = self.secondView.bounds.size.width;
    CGFloat viewHeight = self.secondView.bounds.size.height;
    
    // 计算距离单位
    CGFloat maxDistance = ceil(self.passRun.distance.floatValue / 1000);
    CGFloat distanceUnit = [self caculateDistanceUnitWithMaxDistance:maxDistance]; //图表上的单位
    CGFloat minDistance = (viewWidth - leftMargin - rightMargin) / maxDistance *distanceUnit;
    // 计算速度单位
    CGFloat trueMaxSpeed = [self caculateMaxSpeed];// 真实最大速度
    CGFloat maxSpeed = ceil(trueMaxSpeed); // 向上取整最大速度
    self.maxSpeed = trueMaxSpeed;
    CGFloat speedUnit = [self caculateSpeedUnitWithMaxDistance:maxSpeed]; //图表上的单位
    CGFloat chartHeight = viewHeight - topMargin * 2 - speedFeildHeight;
    CGFloat chartWidth = viewWidth - leftMargin;
    CGFloat count = ceil(maxSpeed / speedUnit); // 速度分段数
    CGFloat minSpeed = chartHeight / (speedUnit * (count + 1)) * speedUnit;
    
    // add separator line
    UIView *separatorLineOne = [[UIView alloc] init];
    separatorLineOne.frame = CGRectMake(0, 0.5, viewWidth, 1.0);//需要调整，和导航栏颜色一样，会显示不清楚
    separatorLineOne.backgroundColor = [UIColor blackColor];
    [self.secondView addSubview:separatorLineOne];
    
    UIView *separatorLineTwo = [[UIView alloc] init];
    separatorLineTwo.frame = CGRectMake(0, topMargin, viewWidth, 1.0);
    separatorLineTwo.backgroundColor = [UIColor blackColor];
    [self.secondView addSubview:separatorLineTwo];
    
    UIView *separatorLineThree = [[UIView alloc] init];
    separatorLineThree.frame = CGRectMake(0, viewHeight - speedFeildHeight - topMargin, viewWidth, 1.0);
    separatorLineThree.backgroundColor = [UIColor blackColor];
    [self.secondView addSubview:separatorLineThree];
    
    UIView *separatorLineFour = [[UIView alloc] init];
    separatorLineFour.frame = CGRectMake(0, viewHeight - speedFeildHeight, viewWidth, 1.0);
    separatorLineFour.backgroundColor = [UIColor blackColor];
    [self.secondView addSubview:separatorLineFour];
    
    // 垂直方向，左侧黑色实线
    UIView *separatorLineFive = [[UIView alloc] init];
    separatorLineFive.frame = CGRectMake(leftMargin, topMargin, 1.0, viewHeight - topMargin * 2 - speedFeildHeight);
    separatorLineFive.backgroundColor = [UIColor blackColor];
    [self.secondView addSubview:separatorLineFive];
    
    // 创建垂直方向虚线
    [self createVerticalDsshedLineWithMaxSpeed:maxSpeed speedUnit:speedUnit];
    
    // 创建水平方向虚线
    [self createHorizontalDsshedLineWithMaxDistance:maxDistance distanceUnit:distanceUnit];
    
    // X轴描述
    CGFloat xAxisLabelCount = floor(maxDistance / distanceUnit);
    NSMutableArray *xAxisLabelArray = [NSMutableArray array];
    for (int i = 0; i < xAxisLabelCount; i++) {
        NSString *string = [NSString stringWithFormat:@"%d", (int)(distanceUnit + distanceUnit * i)];
        [xAxisLabelArray addObject:string];
    }
    [xAxisLabelArray insertObject:@"km" atIndex:0];
    [self createXAxisLabelWithArray:xAxisLabelArray minDistance:minDistance];
    
    // Y轴描述
    CGFloat yAxisLabelCount = ceil(maxSpeed / speedUnit);
    NSMutableArray *yAxisLabelArray = [NSMutableArray array];
    for (int i = 0; i < yAxisLabelCount; i++) {
        NSString *string = [NSString stringWithFormat:@"%0.1f", (speedUnit + speedUnit * i)];
        [yAxisLabelArray addObject:string];
    }
    [self createYAxisLabelWithArray:yAxisLabelArray minSpeed:minSpeed];
    
    
    // 计算统计坐标点（每10个数据求出一个平均速度）
    NSMutableArray *countTenSpeedArray = [NSMutableArray array];
    NSInteger totalSpeedDataCount = self.passRun.locations.count;
    NSInteger speedDataCountModTen = totalSpeedDataCount % 10;
    NSInteger totalSubtractMod = totalSpeedDataCount - speedDataCountModTen;
    
    // 计算每10个整点平均速度
    for (int i = 0; i < totalSubtractMod; (i += 10)) {
        CGFloat sum = 0;
        for (int j = 0; j < 10; j++) {
            Location *location = [self.passRun.locations objectAtIndex:(i + j)];
            CGFloat speed = location.speed.floatValue;
            if (speed == trueMaxSpeed) {
                // 当最大速度在当前区段时，使用最大速度作为坐标点
                sum = trueMaxSpeed * 10;
                break;
            }
            sum += speed;
            
        }
        CGFloat averageSpeed = sum / 10;
        [countTenSpeedArray addObject:@(averageSpeed)];
    }
    // 计算余数平均速度
    if (speedDataCountModTen != 0) {
        CGFloat lastSum = 0;
        for (int i = 0; i < speedDataCountModTen; i++) {
            Location *location = [self.passRun.locations objectAtIndex:(i + totalSubtractMod)];
            CGFloat speed = location.speed.floatValue;
            lastSum += speed;
        }
        CGFloat lastAverageSpeed = (CGFloat)lastSum / speedDataCountModTen;
        [countTenSpeedArray addObject:@(lastAverageSpeed)];
    }
    
    // 计算所有平均速度
    CGFloat sum = 0;
    for (int i = 0; i < countTenSpeedArray.count; i++) {
        sum += [[countTenSpeedArray objectAtIndex:i] floatValue];
    }
    CGFloat averageSpeed = sum / countTenSpeedArray.count;
    self.averageSpeed = averageSpeed;
    
    // 计算iOS坐标系内坐标点
    NSMutableArray *speedPointsArray = [NSMutableArray array];
    CGFloat xUnit = (chartWidth - rightMargin) / countTenSpeedArray.count;
    CGFloat yUnit = minSpeed / speedUnit;
    for (int i = 0; i < countTenSpeedArray.count; i++) {
        CGPoint point;
        point.y = chartHeight - ([[countTenSpeedArray objectAtIndex:i] floatValue]) * yUnit;//反转y坐标
        point.x = xUnit + xUnit * i;
        [speedPointsArray addObject:[NSValue valueWithCGPoint:point]];
    }
    CGPoint zeroPoint = CGPointMake(0, chartHeight - 0);
    [speedPointsArray insertObject:[NSValue valueWithCGPoint:zeroPoint] atIndex:0];//插入原点坐标
    
    // 绘制线段
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    for (id point in speedPointsArray) {
        if ([point isEqualToValue:[speedPointsArray firstObject]]) {
            [linePath moveToPoint:[[speedPointsArray firstObject] CGPointValue]];
        } else {
            [linePath addLineToPoint:[point CGPointValue]];
        }
    }
    
    // 创建速度曲线 shapeLayer
    UIColor *lineBlueColor = [UIColor colorWithRed:57.0/255 green:189.0/255 blue:212.0/255 alpha:1.0];
    CAShapeLayer *shapeLayerLine = [CAShapeLayer layer];
    shapeLayerLine.frame = CGRectMake(leftMargin, topMargin, chartWidth, chartHeight);
    shapeLayerLine.path = linePath.CGPath;
    shapeLayerLine.lineWidth = 2.0;
    shapeLayerLine.strokeColor = lineBlueColor.CGColor;
    shapeLayerLine.fillColor = nil;
    [self.secondView.layer addSublayer:shapeLayerLine];
    
    
    // 绘制起点和终点
    CGFloat radius = 4.0;
    CGPoint beginPoint = [[speedPointsArray firstObject] CGPointValue];
    CGPoint endPoint = [[speedPointsArray lastObject] CGPointValue];
    UIBezierPath *beginCirclePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius * 2, radius * 2)];
    // 起点
    CAShapeLayer *beginPointShapeLayer = [CAShapeLayer layer];
    beginPointShapeLayer.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    beginPointShapeLayer.position = beginPoint;
    [shapeLayerLine addSublayer:beginPointShapeLayer];
    beginPointShapeLayer.path = beginCirclePath.CGPath;
    beginPointShapeLayer.strokeColor = [UIColor orangeColor].CGColor;
    beginPointShapeLayer.fillColor = [UIColor blackColor].CGColor;
    beginPointShapeLayer.lineWidth = 2.0;
    // 终点
    CAShapeLayer *endPointShapeLayer = [CAShapeLayer layer];
    endPointShapeLayer.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    endPointShapeLayer.position = endPoint;
    [shapeLayerLine addSublayer:endPointShapeLayer];
    endPointShapeLayer.path = beginCirclePath.CGPath;
    endPointShapeLayer.strokeColor = [UIColor orangeColor].CGColor;
    endPointShapeLayer.fillColor = [UIColor orangeColor].CGColor;
    endPointShapeLayer.lineWidth = 2.0;
    
    
    // 绘制平均速度线段
    CGPoint averageLineStart = CGPointMake(beginPoint.x, 1.0);
    CGPoint averageLineEnd = CGPointMake(endPoint.x, 1.0);
    
    UIBezierPath *averageLinePath = [UIBezierPath bezierPath];
    [averageLinePath moveToPoint:averageLineStart];
    [averageLinePath addLineToPoint:averageLineEnd];
    
    CAShapeLayer *averageLineShapeLayer = [CAShapeLayer layer];
    averageLineShapeLayer.frame = CGRectMake(leftMargin, viewHeight - speedFeildHeight - topMargin -averageSpeed * yUnit, chartWidth - rightMargin, 2.0);
    averageLineShapeLayer.path = averageLinePath.CGPath;
    averageLineShapeLayer.lineWidth = 1.0;
    averageLineShapeLayer.strokeColor = lineBlueColor.CGColor;
    averageLineShapeLayer.fillColor = nil;
    averageLineShapeLayer.lineDashPattern = @[@8, @4];
    averageLineShapeLayer.lineDashPhase = 0;
    [self.secondView.layer addSublayer:averageLineShapeLayer];
    
    
}

// 创建X轴文字描述
- (void)createXAxisLabelWithArray:(NSArray *)array minDistance:(CGFloat)minDistance{
    CGFloat viewHeight = self.secondView.bounds.size.height;
    CGRect bounds = CGRectMake(0, 0, 40, 21);
    CGFloat centerX = leftMargin;
    CGFloat centerY = viewHeight - speedFeildHeight - topMargin / 2;
    for (int i = 0; i < array.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.bounds = bounds;
        label.center = CGPointMake(centerX + minDistance * i, centerY);
        [self.secondView addSubview:label];
        label.text = [array objectAtIndex:i];
        label.textAlignment = NSTextAlignmentCenter;
    }
}

// 创建Y轴文字描述
- (void)createYAxisLabelWithArray:(NSArray *)array minSpeed:(CGFloat)minSpeed{
    CGFloat viewHeight = self.secondView.bounds.size.height;
    CGRect bounds = CGRectMake(0, 0, 40, 21);
    CGFloat centerX = leftMargin / 2;
    CGFloat centerY = viewHeight - speedFeildHeight - topMargin;
    for (int i = 0; i < array.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.bounds = bounds;
        label.center = CGPointMake(centerX, centerY - minSpeed - minSpeed * i);
        [self.secondView addSubview:label];
        label.text = [array objectAtIndex:i];
        label.textAlignment = NSTextAlignmentCenter;
    }
}

// 创建水平方向上的虚线
- (void)createHorizontalDsshedLineWithMaxDistance:(CGFloat)maxDistance distanceUnit:(CGFloat)distanceUnit{
    CGFloat viewHeight = self.secondView.bounds.size.height;
    CGFloat viewWidth = self.secondView.bounds.size.width;
    CGFloat dashedLineHeight = viewHeight - topMargin * 2 - speedFeildHeight;
    CGFloat minDistance = (viewWidth - leftMargin - rightMargin) / maxDistance *distanceUnit;
    CGFloat count = floor(maxDistance / distanceUnit);
    
    for (int i = 1; i <= count; i ++) {
        CGRect frame = CGRectMake(leftMargin + minDistance * i, topMargin, 1.0, dashedLineHeight);
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        //shapeLayer.backgroundColor = [UIColor greenColor].CGColor;
        shapeLayer.frame = frame;
        shapeLayer.path = [self createBezierPathOfDashedLineWithRect:CGRectMake(0, 0, 0, dashedLineHeight)].CGPath;
        shapeLayer.strokeColor = [UIColor darkGrayColor].CGColor;
        shapeLayer.lineWidth = 1.0;
        shapeLayer.lineDashPattern = @[@2, @4];
        [self.secondView.layer addSublayer:shapeLayer];
    }
    
    
}

// 创建垂直方向上虚线
- (void)createVerticalDsshedLineWithMaxSpeed:(CGFloat)maxSpeed speedUnit:(CGFloat)speedUnit{
    CGFloat viewHeight = self.secondView.bounds.size.height;
    CGFloat viewWidth = self.secondView.bounds.size.width;
    CGFloat chartHeight = viewHeight - topMargin * 2 - speedFeildHeight;
    CGFloat dashedLineWidth = viewWidth - leftMargin - rightMargin;
    CGFloat count = ceil(maxSpeed / speedUnit); // 速度分段数
    CGFloat minSpeed = chartHeight / (speedUnit * (count + 1)) * speedUnit;
    
    for (int i = 1; i <= count + 1; i ++) {
        CGRect frame = CGRectMake(leftMargin, topMargin + minSpeed * i, dashedLineWidth, 1.0);
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        //shapeLayer.backgroundColor = [UIColor greenColor].CGColor;
        shapeLayer.frame = frame;
        shapeLayer.path = [self createBezierPathOfDashedLineWithRect:CGRectMake(0, 0, dashedLineWidth, 1.0)].CGPath;
        shapeLayer.strokeColor = [UIColor darkGrayColor].CGColor;
        shapeLayer.lineWidth = 1.0;
        shapeLayer.lineDashPattern = @[@2, @4];
        [self.secondView.layer addSublayer:shapeLayer];
    }
}

// 使用bezierPath创建虚线
- (UIBezierPath *)createBezierPathOfDashedLineWithRect:(CGRect)rect{
    UIBezierPath *dashedLinePath = [UIBezierPath bezierPath];
    [dashedLinePath moveToPoint:CGPointMake(0, 0)];
    if (rect.size.height != 1.0) {
        [dashedLinePath addLineToPoint:CGPointMake(0, rect.size.height)];
    } else {
         [dashedLinePath addLineToPoint:CGPointMake(rect.size.width, 0)];
    }

    return dashedLinePath;
}

// 计算最大速度（瞬时速度）
- (CGFloat)caculateMaxSpeed{
    
    Location *location = [self.passRun.locations firstObject];
    CGFloat maxSpeed = location.speed.floatValue;
    
    for (int i = 0; i < self.passRun.locations.count; i++) {
        Location *location = [self.passRun.locations objectAtIndex:i];
        if (location.speed.floatValue > maxSpeed) {
            maxSpeed = location.speed.floatValue;
        }
    }
    
    //return ceil(maxSpeed);
    return maxSpeed;
}

// 计算速度单位
- (CGFloat)caculateSpeedUnitWithMaxDistance:(CGFloat)maxSpeed{
    
    CGFloat speedUnit = 0.0;
    if (maxSpeed > 90.0) {
        speedUnit = 25.0;
    }
    if (maxSpeed > 40.0 && maxSpeed <= 90.0) {
        speedUnit = 10.0;
    }
    if (maxSpeed > 10.0 && maxSpeed <= 40.0) {
        speedUnit = 5.0;
    }
    if (maxSpeed > 1.0 && maxSpeed <= 10.0 ) {
        speedUnit = 1.0;
    }
    if (maxSpeed <= 1.0) {
        speedUnit = 0.5;
    }
    return speedUnit;
}

// 计算距离单位
- (CGFloat)caculateDistanceUnitWithMaxDistance:(CGFloat)maxDistance{
//    CGFloat viewWidth = self.secondView.bounds.size.width;
    CGFloat distanceUnit = 0.0;
    
    if (maxDistance > 300.0) {
        distanceUnit = 50.0;
    }
    if (maxDistance > 100.0 && maxDistance <= 200) {
        distanceUnit = 25.0;
    }
    if (maxDistance > 50.0 && maxDistance <= 100.0) {
        distanceUnit = 10.0;
    }
    if (maxDistance > 10.0 && maxDistance <= 50.0) {
        distanceUnit = 5.0;
    }
    if (maxDistance > 3.0 && maxDistance <= 10.0 ) {
        distanceUnit = 1.0;
    }
    if (maxDistance <= 3.0) {
        distanceUnit = 0.5;
    }
    
    //distanceUnit = (viewWidth - leftMargin) / maxDistance * distanceUnit;
    
    return distanceUnit;
}


// #MARK: /***********   helper method    ***************/


// 设置显示内容
- (void)setUpDetailView{
    
    //
    self.title = @"Run Detail";
    
    // 距离
    self.distanceDscription.text = @"Distance";
    self.distance.text = [NSString stringWithFormat:@"%0.1f KM", self.passRun.distance.floatValue/1000];
    // 用时
    self.timeDescription.text = @"Time";
    self.time.text = [NSString stringWithFormat:@"%d S", self.passRun.duration.integerValue];

    // 爬升高度
    self.elevationDescription.text = @"Elevation";
    self.elevation.text = @"150";
    
    // 卡路里
    self.calorieDescription.text = @"Calorie";
    self.calorie.text = @"3200";
    
    
}

// 加载map
- (void)loadMap{
    
    if (self.passRun.locations.count > 0) {
        
        // 基本配置
        self.mapView.hidden = NO;
        
        // 设置显示区域
        /**
         *  问题：如果此段代码在viewDidLoad、viewWillappear中实现，则mapView显示的地图level和实际设置的不一致，比实际的大？？？
         原因：有可能因为mapView此时的frame还是（0，0，1000，1000），非真实值造成的（？？？具体？？）
         解决：1、调用[self.view layoutIfNeeded]强制布局；2、设置在viewDidAppear中实现
         */
        //[self.view layoutIfNeeded];
        [self.mapView setRegion:[self caculateMapRegionUsingMKMapPoint] animated:NO];
        
        // 地图添加覆盖物（本例是运动路线轨迹）
        [self.mapView addOverlay:[self polyLine]];
        
    } else {
        
        self.mapView.hidden = YES;
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Error" message:@"Sorry! this run has no locations saved." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

// 计算显示区域
// 方法二：先计算zoom level，再设置span
- (MKCoordinateRegion)caculateMapRegionUsingMKMapPoint{
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = (0.75) * width;
    
    // 计算polyline rang
    Location *firstLocation = self.passRun.locations.firstObject;
    CLLocationCoordinate2D firstCoordinate = CLLocationCoordinate2DMake(firstLocation.latitude.floatValue, firstLocation.longitude.floatValue);
    MKMapPoint firstMapPoint = MKMapPointForCoordinate(firstCoordinate);
    
    
    CGFloat minMapPointX = firstMapPoint.x;
    CGFloat maxMapPointX = firstMapPoint.x;
    CGFloat minMapPointY = firstMapPoint.y;
    CGFloat maxMapPointY = firstMapPoint.y;
    
    for (int i = 0; i < self.passRun.locations.count; i ++) {
        
        Location *location = [self.passRun.locations objectAtIndex:i];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude.floatValue, location.longitude.floatValue);
        MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
        
        if (mapPoint.x < minMapPointX) minMapPointX = mapPoint.x;
        if (mapPoint.y < minMapPointY) minMapPointY = mapPoint.y;
        if (mapPoint.x > maxMapPointX) maxMapPointX = mapPoint.x;
        if (mapPoint.y > maxMapPointY) maxMapPointY = mapPoint.y;
        
    }
    
    // 计算centerCoordinate
    MKMapPoint centerMapPoint = MKMapPointMake((maxMapPointX + minMapPointX)/2, (maxMapPointY + minMapPointY)/2);
    CLLocationCoordinate2D centerCoordinate = MKCoordinateForMapPoint(centerMapPoint);
    
    // 计算level＝20 的 rang
    CGFloat xrang = ABS(maxMapPointX - minMapPointX);
    CGFloat yrang = ABS(maxMapPointY - minMapPointY);
    
    // 计算zoomScale zoomLevel
    double zoomScale = yrang / height;
    NSInteger zoomLevel;
    NSInteger zoomExponent;
    if (zoomScale > 0) {
        
        double exponent = log2(zoomScale);
        zoomExponent = ceil(exponent);
        zoomLevel = 20 - zoomExponent;
        zoomLevel = MIN(zoomLevel, 17);
    }
    
    // 例缩放后的polyline区域（即：在缩放后的level里，表示的rang）
    NSInteger lowerExponent = 20 - zoomLevel;
    NSInteger lowerScale = pow(2, lowerExponent);
    CGFloat xrangScaled = xrang / lowerScale;
    CGFloat yrangScaled = yrang / lowerScale;
    
    // 调整：当缩放后的rang仍比view尺寸大时，继续缩放
    // 调整（使用if，只能调整一次）
    //    if (xrangScaled > width || yrangScaled > height) {
    //
    //        zoomLevel -= 1;
    //        lowerScale *= 2;
    //        xrangScaled /= 2;
    //        yrangScaled /= 2;
    //
    //    }
    // 调整（使用while，直到满足条件）
    while (xrangScaled > width || yrangScaled > height) {
        zoomLevel -= 1;
        lowerScale *= 2;
        xrangScaled /= 2;
        yrangScaled /= 2;
    }
    NSLog(@"zoomLevel:%ld", (long)zoomLevel);
    
    // 计算view所在尺寸宽高包含的points（以level＝20）
    CGFloat widthPoints = width * lowerScale;
    CGFloat heightPoints = height * lowerScale;
    
    // top-left MKMapPoint（level＝20）
    CGFloat topLeftPointX = centerMapPoint.x - (widthPoints / 2);
    CGFloat topLeftPointY = centerMapPoint.y - (heightPoints / 2);
    CLLocationCoordinate2D topLeftCoordinate = MKCoordinateForMapPoint(MKMapPointMake(topLeftPointX, topLeftPointY));
    
    // top-right MKMapPoint（level＝20）
    CGFloat topRightPointX = topLeftPointX + widthPoints;
    CGFloat topRightPointY = topLeftPointY ;
    CLLocationCoordinate2D topRightCoordinate = MKCoordinateForMapPoint(MKMapPointMake(topRightPointX, topRightPointY));
    
    // bottom-left MKMapPoint（level＝20）
    CGFloat bottomLeftX = topLeftPointX;
    CGFloat bottomLeftY = topLeftPointY + heightPoints;
    CLLocationCoordinate2D bottomLeftCoordinate = MKCoordinateForMapPoint(MKMapPointMake(bottomLeftX, bottomLeftY));
    
    // bottom-right
    //CGFloat bottomRightX = topLeftPointX + widthPoints;
    //CGFloat bottomRightY = topLeftPointY + widthPoints;;
    //CLLocationCoordinate2D bottomRightCoordinate = MKCoordinateForMapPoint(MKMapPointMake(bottomRightX, bottomRightY));
    
    // longitude delta（mapView所在尺寸包含的delta）
    // 注意CLLocationCoordinate2D坐标系和iOS的坐标系y轴正好相反，因此要转换坐标系
    CLLocationDegrees longitudeDelta = topRightCoordinate.longitude - topLeftCoordinate.longitude;
    CLLocationDegrees latitudeDelta = -1 * (bottomLeftCoordinate.latitude - topLeftCoordinate.latitude);
    
    // create  the lat/lon span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    
    // create and return the region
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    return region;
}

// 创建线段数据点
- (MKPolyline *)polyLine{
    
    CLLocationCoordinate2D coordinates[self.passRun.locations.count];
    
    for (int i = 0; i < self.passRun.locations.count; i++) {
        
        Location *location = [self.passRun.locations objectAtIndex:i];
        coordinates[i] = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
        //NSLog(@"coordinates[1]:%f", coordinates[1].latitude);
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:self.passRun.locations.count];
    
    return polyLine;
}


//#MARK:/************       MKMapViewDelegate    ***********/

//
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    //
    NSLog(@"rendererForOverlay:detail");
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        //MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *lineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
        lineRenderer.strokeColor = [UIColor redColor];
        lineRenderer.lineWidth = 3;
        
        return lineRenderer;
    }
    
    return nil;
}


// #MARK: /********       UIScrollViewDelegate     ************/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat width = self.secondView.bounds.size.width;
    NSInteger page = (NSInteger)round(scrollView.contentOffset.x / width);
    self.pageControl.currentPage = page;
}



@end
