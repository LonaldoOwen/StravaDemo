//
//  DetailViewController.m
//  StravaDemo
//
//  Created by owen on 16/6/6.
//  Copyright © 2016年 owen. All rights reserved.
//

/**
 * 功能：显示运动数据历史详情
    1、运动结束、数据保存后，进入此页面，查看此次详情（准备废弃，重新设计保存运动数据页面）
    2、在历史运动列表页面，点击记录，进入运动详情页，查看该条记录详情
   主要技术：
    1、mapView：显示运动路线轨迹
    2、
 */

#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "Run.h"
#import "Location.h"

@interface DetailViewController ()<MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *runDescriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;


@end

@implementation DetailViewController

- (void)setRun:(Run *)run{
    
    if (_run != run) {
        _run = run;
        [self setUpDetailView];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    // 设置导航栏样式
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:32.0/255 green:32.0/255 blue:32.0/255 alpha:1.0];
    
    // 设置显示内容
    [self setUpDetailView];
    
    // 配置地图
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    //
    //[self loadMap];
    NSLog(@"self.mapView:%@", self.mapView);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"viewWillAppear:");
    
    // 接收数据
    Run *run = self.run;
    NSLog(@"run distance:%@", run.distance);
    
    //
    //[self loadMap];
    //[self.mapView updateConstraintsIfNeeded];
    NSLog(@"self.mapView:%@", self.mapView);
}

- (void)viewWillLayoutSubviews{
    NSLog(@"viewWillLayoutSubviews");
    NSLog(@"self.mapView:%@", self.mapView);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSLog(@"viewDidAppear");
    //
    [self loadMap];
    NSLog(@"self.mapView:%@", self.mapView);
}

//
- (void)updateViewConstraints{
    
    [super updateViewConstraints];
    NSLog(@"updateViewConstraints");
    
    // 修改height和width的比例为3:4
    CGFloat width = self.view.frame.size.width;
    CGFloat constant = 3.0 / 4 * width;
    self.heightConstraint.constant = constant;
    NSLog(@"self.mapView:%@", self.mapView);
}

// 设置显示内容
- (void)setUpDetailView{
    
    //
    self.title = @"Run Detail";
    
    // 距离
    self.distanceLabel.text = [NSString stringWithFormat:@"Distance:%0.2f KM", self.run.distance.floatValue/1000];
    
    // 日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *dateString = [formatter stringFromDate:self.run.timestamp];
    self.dateLabel.text = [NSString stringWithFormat:@"Date:%@", dateString];
    /**
     * 问题：使用[NSDate date]再使用setDateStyle、setTimeStyle得到的时间就是当前时区时间？？对的，使用NSDateFormatter转换的时间就是以本地时区和本地化为参考的
     */
    //NSLog(@"date string:%@", [formatter stringFromDate:self.run.timestamp]);
    //NSLog(@"detail:date:%@", self.run.timestamp);
    
    // 用时
    self.timeLabel.text = [NSString stringWithFormat:@"Time:%ld S", self.run.duration.integerValue];
    
    // 速度
    CGFloat pace = (self.run.distance.floatValue / 1000) / (self.run.duration.floatValue / 3600);
    self.paceLabel.text = [NSString stringWithFormat:@"Pace:%f KM/H", pace];
    
    // name
    self.nameLabel.text = [NSString stringWithFormat:@"Name:%@", self.run.name];
    
    // tag
    self.tagLabel.text = [NSString stringWithFormat:@"Tag:%@", self.run.tag];
    
    // type
    self.typeLabel.text = [NSString stringWithFormat:@"Type:%@", self.run.type];
    
    // runDescription
    self.runDescriptionLabel.text = [NSString stringWithFormat:@"RunDescription:%@", self.run.runDescription];
    
    
    //[self loadMap];
    
}





// 加载map
- (void)loadMap{
    
    if (self.run.locations.count > 0) {
        
        // 基本配置
        self.mapView.hidden = NO;
        //[self.mapView updateConstraintsIfNeeded];
        
        // 设置显示区域
        /**
         *  问题：如果此段代码在viewDidLoad、viewWillappear中实现，则mapView显示的地图level和实际设置的不一致，比实际的大？？？
            原因：有可能因为mapView此时的frame还是（0，0，1000，1000），非真实值造成的（？？？具体？？）
            解决：1、调用[self.view layoutIfNeeded]强制布局；2、设置在viewDidAppear中实现
         */
        //[self.view layoutIfNeeded];
        //[self.mapView setRegion:[self mapRegion]];
        [self.mapView setRegion:[self caculateMapRegionUsingMKMapPoint] animated:NO];
        
        // 地图添加覆盖物（本例是运动路线轨迹）
        [self.mapView addOverlay:[self polyLine]];
        
        
//        // 线型overlay
//        CLLocationCoordinate2D points[2];
//        
//        points[0] = CLLocationCoordinate2DMake(39.915352,116.397105);
//        points[1] = CLLocationCoordinate2DMake(39.13, 117.20);
//        
//        MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:points count:2];
//        polyLine.title = @"Line";
        
//        [self.mapView addOverlay:polyLine];
        
    } else {
        
        self.mapView.hidden = YES;
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Error" message:@"Sorry! this run has no locations saved." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

// 计算显示区域

// 方法一：
- (MKCoordinateRegion)mapRegion{
    
    /**
     * 说明：通过设置span的值来调整地图显示的区域大小
     * 问题：不显示线段？
     * 原因：center和span计算的变量设置有误（对应后，问题解决）
     *
     */
    
    MKCoordinateRegion region;
    
    Location *initialLocation = self.run.locations.firstObject;
    
    CGFloat minLatitude = initialLocation.latitude.floatValue;
    CGFloat minLongitude = initialLocation.longitude.floatValue;
    CGFloat maxLatitude = initialLocation.latitude.floatValue;
    CGFloat maxLongitude = initialLocation.longitude.floatValue;
    
    for (Location *location in self.run.locations) {
        
        if (location.latitude.floatValue < minLatitude) {
            minLatitude = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLongitude) {
            minLongitude = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLatitude) {
            maxLatitude = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLongitude) {
            maxLongitude = location.longitude.floatValue;
        }
    }
    
    
//    // 计算polyline所在区域
//    double centerLatitude =(minLatitude + maxLatitude) / 2.0f;
//    double centerLongitude = (minLongitude + maxLongitude) / 2.0f;
//    
//    double latitudeRang = (maxLatitude - minLatitude);
//    double longitudeRang = (maxLongitude - minLongitude);
//    
//    double delta = (latitudeRang - longitudeRang) ? latitudeRang : longitudeRang;
//    
//    region.center.latitude = centerLatitude;
//    region.center.longitude = centerLongitude;
//    region.span.latitudeDelta = 10;
//    region.span.longitudeDelta = 10;
    
    /**
     * 说明：regon是设定当前地图显示范围的；给span添加乘数为了留出边界
     */
    region.center.latitude = (minLatitude + maxLatitude) / 2.0f;
    region.center.longitude = (minLongitude + maxLongitude) / 2.0f;
    
    region.span.latitudeDelta = (maxLatitude - minLatitude) * 2.2f;//纬度度数（对应南北距离）
    region.span.longitudeDelta = (maxLongitude - minLongitude) * 4.5f;//精度度数（对应东西距离）
    
    return region;
}

// 方法二：先计算zoom level，再设置span
- (MKCoordinateRegion)caculateMapRegionUsingMKMapPoint{
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = (0.75) * width;
    
    // 计算polyline rang
    Location *firstLocation = self.run.locations.firstObject;
    CLLocationCoordinate2D firstCoordinate = CLLocationCoordinate2DMake(firstLocation.latitude.floatValue, firstLocation.longitude.floatValue);
    MKMapPoint firstMapPoint = MKMapPointForCoordinate(firstCoordinate);
    
    
    CGFloat minMapPointX = firstMapPoint.x;
    CGFloat maxMapPointX = firstMapPoint.x;
    CGFloat minMapPointY = firstMapPoint.y;
    CGFloat maxMapPointY = firstMapPoint.y;
    
    for (int i = 0; i < self.run.locations.count; i ++) {
        
        Location *location = [self.run.locations objectAtIndex:i];
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
    
    // test
    //zoomLevel = 14;
    
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
    
    // 再次调整（iOS地图zoom level和google maps对不上，好像差一个level）
//    zoomLevel  -= 1;
//    lowerScale *= 2;
//    xrangScaled /= 2;
//    yrangScaled /= 2;
//    NSLog(@"again zoomLevel:%ld", (long)zoomLevel);
    
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
    
    CLLocationCoordinate2D coordinates[self.run.locations.count];
    
    for (int i = 0; i < self.run.locations.count; i++) {
        
        Location *location = [self.run.locations objectAtIndex:i];
        coordinates[i] = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
        //NSLog(@"coordinates[1]:%f", coordinates[1].latitude);
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:self.run.locations.count];
    
    return polyLine;
}


//#MARK:MKMapViewDelegate

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



@end
