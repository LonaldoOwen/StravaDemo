//
//  RunCellTableViewCell.m
//  StravaDemo
//
//  Created by owen on 16/6/8.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "RunCellTableViewCell.h"
#import "Location.h"

#import <MapKit/MapKit.h>

@import MapboxStatic;

//
// 宏定义
// 宏定义
#define blackColor [UIColor colorWithRed:32.0/255 green:32.0/255 blue:32.0/255 alpha:1.0];
#define POLYLINE_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define POLYLINE_HEIGHT ((241.0 / 375) * POLYLINE_WIDTH) //(注意OC的类型自动转换，如果写成241，则求出的值为0)


@interface RunCellTableViewCell ()

@property (strong, nonatomic) NSMutableArray *coordinate2Ds;
@property (nonatomic) CLLocationCoordinate2D centerCoordinate;
@property (strong, nonatomic) NSArray *points;
@property (nonatomic) NSUInteger zoomLevel;

@property (strong, nonatomic) NSCache *imagesCashe;

@end

@implementation RunCellTableViewCell

// lazy initialization
- (NSCache *)imagesCashe{
    
    if (_imagesCashe == nil) {
        _imagesCashe = [[NSCache alloc] init];
    }
    return _imagesCashe;
}

//
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // 设置不起作用？？？（使用代码时可以在此处设置，storyboard在initWithCoder或awakeFromNib）
        //self.mapImageView.backgroundColor = [UIColor orangeColor];
        //self.backgroundColor = [UIColor lightGrayColor];
        
        //
        [self setUpCell];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //
    [self setUpCell];
    
}

- (void)setUpCell{
    
    //
    //
    //UIColor *blackColor = [UIColor colorWithRed:32.0/255 green:32.0/255 blue:32.0/255 alpha:1.0];
    //UIColor *grayColor = [UIColor colorWithRed:42.0/255 green:42.0/255 blue:42.0/255 alpha:1.0];
    
    //
    self.backgroundColor = blackColor;
    self.mapImageView.backgroundColor = [UIColor orangeColor];
    self.distanceLabel.textColor = [UIColor whiteColor];
    self.dateLabel.textColor = [UIColor whiteColor];
    
    //
    //self.polylineView.alpha = 0.0;
    
    // setup headerView
//    self.avatar.image = [UIImage imageNamed:@"z_tabbar_find_press"];
//    self.titleLabel.text = self.passRun.name;
//    
//    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
//    [formater setDateStyle:NSDateFormatterMediumStyle];
//    [formater setTimeStyle:NSDateFormatterMediumStyle];
//    NSString *timeString = [formater stringFromDate:self.passRun.timestamp];
//    self.dateLabel.text = timeString;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


//
- (void)setPassRun:(Run *)passRun{
    
    _passRun = passRun;
    
    // 配置headerView
    self.headerView.backgroundColor = blackColor;
    self.avatar.image = [UIImage imageNamed:@"clock_background"];
    self.titleLabel.text = self.passRun.name;
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateStyle:NSDateFormatterMediumStyle];
    [formater setTimeStyle:NSDateFormatterMediumStyle];
    NSString *timeString = [formater stringFromDate:self.passRun.timestamp];
    self.dateLabel.text = timeString;
    
    /* 
        1、绘制polyline
     
     */
    // 获取locations数据
    NSOrderedSet *locations = passRun.locations;
    self.coordinate2Ds = [NSMutableArray array];
    
    for (Location *location in locations) {
        
        CLLocationCoordinate2D coordinate2D;
        
        coordinate2D.latitude = location.latitude.doubleValue;
        coordinate2D.longitude = location.longitude.doubleValue;
        
        [self.coordinate2Ds addObject:[NSValue valueWithMKCoordinate:coordinate2D]];
    }
    
    // 转换为point
    [self layoutIfNeeded];
    //self.points = [self convertCoordinate2DToPoint:self.coordinate2Ds];
    self.points = [self convertCoordinate2DToPointUsingZooMLevel:self.coordinate2Ds];
    //[self printCoordintes];
    
    // 绘制bezier path
    UIBezierPath *polylinePath = [self createPolylinePathWithPoints:self.points];
    
    // 创建CAShapeLayer并添加到polylineView的layer上
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.polylineView.bounds;
    shapeLayer.path = polylinePath.CGPath;
    shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 2.0;
    shapeLayer.lineJoin = kCALineJoinRound;
    
    // addSublayer
    /**
     *  说明：polyline所在layer，1、可以添加到polylineView上（在imageView的前面的一个view），同时设置polylineView的背景色为无色；2、也可以直接添加到staticimageView上；二者效果无异
     */
    if (self.polylineView.layer.sublayers == 0) {
        [self.polylineView.layer addSublayer:shapeLayer];
    } else {
        CALayer *sublayer = [self.polylineView.layer.sublayers firstObject];
        [sublayer removeFromSuperlayer];
        [self.polylineView.layer addSublayer:shapeLayer];
    }
    self.polylineView.backgroundColor = [UIColor clearColor];
    
    //NSLog(@"staticImageView.layer.sublayers:%lu", self.staticImageView.layer.sublayers.count);
//    if (self.staticImageView.layer.sublayers == 0) {
//        [self.staticImageView.layer addSublayer:shapeLayer];
//    } else {
//        CALayer *sublayer = [self.staticImageView.layer.sublayers firstObject];
//        [sublayer removeFromSuperlayer];
//        [self.staticImageView.layer addSublayer:shapeLayer];
//    }
    //NSLog(@"after staticImageView.layer.sublayers:%lu", self.staticImageView.layer.sublayers.count);
    
    
    /*
        2、异步加载静态图片
     
     */
    
    NSData *imageData = [self.imagesCashe objectForKey:@(self.indexPath.row)];
    
    if (imageData != nil) {
        
        // 从缓存加载图片
        self.staticImageView.image = [UIImage imageWithData:imageData];
        
    } else {
    
        // 从网络加载图片，并存到缓存
        // 获取图片尺寸
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat height = 241.0 / 375.0 * width;
        
        // 计算中心点
        self.centerCoordinate = [self caculateCenterCoordinate2D:self.coordinate2Ds];
        
        //CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(40.0, 116.3);
        CLLocationCoordinate2D centerCoordinate = self.centerCoordinate;
        
        // 使用mapbox的MapboxStatic库来加载图片
        MBSnapshotOptions *options = [[MBSnapshotOptions alloc] initWithMapIdentifiers:@[@"mapbox.streets"] centerCoordinate:centerCoordinate zoomLevel:self.zoomLevel size:CGSizeMake(width, height)];
        
        MBSnapshot *snapshot = [[MBSnapshot alloc] initWithOptions:options accessToken:@"pk.eyJ1IjoibWlyYWdlb3dlbiIsImEiOiJjaXRucml6ZHgwMDF5MnluMXB0NWxid3FrIn0.cDEDq6JB0pwp4hSIiQV8gg"];
        
        [snapshot imageWithCompletionHandler:^(UIImage * _Nullable image, NSError * _Nullable error) {
            
            //
            //self.staticImageView.image = image;
            if (image != nil) {
                
                NSData *imageData = UIImagePNGRepresentation(image);
                [self.imagesCashe setObject:imageData forKey:@(self.indexPath.row)];
                NSLog(@"indexPath.row:%ld,image:%@", self.indexPath.row, image);
                
            }
            
        }];
        
    }
    
    
    //
//    NSURL *imageUrl = snapshot.URL; //MapboxStatic库提供获取图片url的方法
//    NSLog(@"iamgeUrl:%@", imageUrl);
}


// MARK:/*************   helper method *******************/

// 先计算zoom level，在合适的level上再进行坐标转换
- (NSArray *)convertCoordinate2DToPointUsingZooMLevel:(NSArray *)coordinate2Ds{
    
    // 创建可变数组用于存储转换后的point
    NSMutableArray *pointsArray = [NSMutableArray array];
    
    // 计算polyline rang
    CLLocationCoordinate2D firstCoordinate2D = [[coordinate2Ds firstObject] MKCoordinateValue];
    MKMapPoint firstMapPoint = MKMapPointForCoordinate(firstCoordinate2D);
    
    CGFloat minMapPointX = firstMapPoint.x;
    CGFloat maxMapPointX = firstMapPoint.x;
    CGFloat minMapPointY = firstMapPoint.y;
    CGFloat maxMapPointY = firstMapPoint.y;
    
    for (int i = 0; i < coordinate2Ds.count; i ++) {
        
        CLLocationCoordinate2D coordinate2D = [[coordinate2Ds objectAtIndex:i] MKCoordinateValue];
        MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate2D);
        
        if (mapPoint.x < minMapPointX) minMapPointX = mapPoint.x;
        if (mapPoint.y < minMapPointY) minMapPointY = mapPoint.y;
        if (mapPoint.x > maxMapPointX) maxMapPointX = mapPoint.x;
        if (mapPoint.y > maxMapPointY) maxMapPointY = mapPoint.y;
        
    }
    
    // rang(level=20)
    CGFloat xrang = ABS(maxMapPointX - minMapPointX);
    CGFloat yrang = ABS(maxMapPointY - minMapPointY);
    
    // 计算centerCoordinate
    MKMapPoint centerMapPoint = MKMapPointMake((maxMapPointX + minMapPointX)/2, (maxMapPointY + minMapPointY)/2);
    self.centerCoordinate = MKCoordinateForMapPoint(centerMapPoint);
    
    // 计算zoom level
    /**
     *  问题：double zoomScale = (yrang / POLYLINE_HEIGHT);求出的值不对？？？
        原因：定义的POLYLINE_HEIGHT使用的不是常量，而是表达式，参与除法运算时变成yrang / POLYLINE_HEIGHT＝yrang ／ (241.0 / 375) * POLYLINE_WIDTH
        解决：将表达式使用括号括起来((241.0 / 375) * POLYLINE_WIDTH)
     */
    double zoomScale = yrang / POLYLINE_HEIGHT;
    if (zoomScale > 0) {
        
        double exponent = log2(zoomScale);
        NSInteger zoomExponent = ceil(exponent);//向上取整
        //NSInteger zoomExponent = floor(exponent); //向下取整
        NSInteger zoomLevel = 20 - zoomExponent;
        self.zoomLevel = MIN(zoomLevel, 15);//
        
    }
    
    
    // 例缩放后的polyline区域
    NSInteger lowerExponent = 20 - self.zoomLevel;
    NSInteger lowerScale = pow(2, lowerExponent);
    CGFloat xrangScaled = xrang / lowerScale;
    CGFloat yrangScaled = yrang / lowerScale;
    
    // 调整zoomLevel
    // 当相应level的rang仍然比polyView的尺寸大时，降低一个level
    if (xrangScaled > POLYLINE_WIDTH || yrangScaled > POLYLINE_HEIGHT ) {
        
        self.zoomLevel -= 1;
        lowerScale *= 2;
        xrangScaled /= 2;
        yrangScaled /= 2;
    }
    
    // 缩放后的最小point
    minMapPointX /= lowerScale;
    minMapPointY /= lowerScale;
    
    // shift
    CGFloat shiftX = 0.5 * (POLYLINE_WIDTH - xrangScaled);
    CGFloat shiftY = 0.5 * (POLYLINE_HEIGHT - yrangScaled);
    
    // convert all
    for (int i = 0; i < coordinate2Ds.count; i++) {
        
        CLLocationCoordinate2D coordinate2D = [[coordinate2Ds objectAtIndex:i] MKCoordinateValue];
        MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate2D);
        
        // 转换到相应level
        CGFloat mapPointScaledX = mapPoint.x / lowerScale;
        CGFloat mapPointScaledY = mapPoint.y / lowerScale;
        
        // 转换mapPoint到UIView
        // 将polyline移动到iOS坐标原点
        CGFloat x = mapPointScaledX - minMapPointX;
        CGFloat y = mapPointScaledY - minMapPointY;
        
        x = x + shiftX;
        y = y + shiftY;
        
        CGPoint point = CGPointMake(x, y);
        [pointsArray addObject:[NSValue valueWithCGPoint:point]];
        
    }
    //NSLog(@"points:%@", pointsArray);
    
    return pointsArray;
}

// 都在level＝20上，进行坐标转换
- (NSArray *)convertCoordinate2DToPoint:(NSArray *)coordinate2Ds{
    
    //
//    CGFloat width = self.polylineView.frame.size.width;
//    CGFloat height = self.polylineView.frame.size.height;
//    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
//    CGFloat height = 241.0 / 375.0 * width;

    //
    CLLocationCoordinate2D coordinate2D = [[coordinate2Ds firstObject] MKCoordinateValue];
    MKMapPoint firstMapPoint = MKMapPointForCoordinate(coordinate2D);
    
    // 计算polyline矩形区域
    double minMapPointX = firstMapPoint.x;
    double maxMapPointX = firstMapPoint.x;
    double minMapPointY = firstMapPoint.y;
    double maxMapPointY = firstMapPoint.y;
    
    for (int i = 0; i < coordinate2Ds.count; i++) {
        
        CLLocationCoordinate2D coordinate2D = [[coordinate2Ds objectAtIndex:i] MKCoordinateValue];
        MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate2D);
        
        if (mapPoint.x < minMapPointX) minMapPointX = mapPoint.x;
        if (mapPoint.x > maxMapPointX) maxMapPointX = mapPoint.x;
        if (mapPoint.y < minMapPointY) minMapPointY = mapPoint.y;
        if (mapPoint.y > maxMapPointY) maxMapPointY = mapPoint.y;
    }
    
    // 计算宽、高(注意取绝对值)
    CGFloat xrang = ABS(maxMapPointX - minMapPointX);
    CGFloat yrang = ABS(maxMapPointY - minMapPointY);
    
    
    // 计算zoomLevel和centerCoordinate
    // zoomLevel
    double zoomScale = yrang / POLYLINE_HEIGHT;// yrang / 241;
    if (zoomScale > 0) {
        NSInteger zoomExponent = ceil(log2(zoomScale)) ;
        NSInteger zoomLevel = 20 - zoomExponent;
        // 限制最大level为；（mapBox最大支持20）;strava在静态地图上似乎设置了最大level为15
        self.zoomLevel = MIN(zoomLevel, 15);
        NSLog(@"zoomLevel:%lu", (unsigned long)self.zoomLevel);
    }
    
    
    
//    // centerCoordinate
//    MKMapPoint centerMapPoint = MKMapPointMake((maxMapPointX + minMapPointX)/2, (maxMapPointY + minMapPointY)/2);
//    self.centerCoordinate = MKCoordinateForMapPoint(centerMapPoint);

    if (self.zoomLevel == 15) {
        xrang = xrang / 32;
        yrang = yrang / 32;
        
        minMapPointX = minMapPointX / 32;
        minMapPointY = minMapPointY / 32;
        
    }
    
    
    // offset
    CGFloat offset = 1.2;
    
    // scale
    CGFloat scale;
    
    if (xrang > yrang) {
        
        scale = POLYLINE_WIDTH / (xrang * offset);
        
    } else {
        
        scale = POLYLINE_HEIGHT / (yrang * offset);
        
    }
    // 当level>＝15时，调整scale
    // 说明：因为level＝20时，地图宽度＝268435456point，level＝15时，地图宽度只需要8388608（即256X2的15次方），缩小32倍；因此宽度为375的view可以显示更多的地图内容，所以scale调整为scale／32；
    if (self.zoomLevel == 15) {
        
        if (xrang < POLYLINE_WIDTH && yrang < POLYLINE_HEIGHT) scale = 1.0;
    }
    
    // shift
    CGFloat shiftX;
    CGFloat shiftY;
    
    CGFloat xrangScaled = xrang * scale;
    CGFloat yrangScaled = yrang * scale;
    
    shiftX = 0.5 * (POLYLINE_WIDTH - xrangScaled);
    shiftY = 0.5 * (POLYLINE_HEIGHT - yrangScaled);
    
    // 转换
    NSMutableArray *points = [NSMutableArray array];
    for (int i = 0; i < coordinate2Ds.count; i++) {
        
        CLLocationCoordinate2D coordinate2D = [[coordinate2Ds objectAtIndex:i] MKCoordinateValue];
        MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate2D);
        if (self.zoomLevel == 15) {
            
            mapPoint.x = mapPoint.x / 32;
            mapPoint.y = mapPoint.y / 32;
        
        }
        
        //
        CGFloat xscaled = mapPoint.x * scale;
        CGFloat yscaled = mapPoint.y * scale;
        
        // 调整原点
        CGFloat x = xscaled - minMapPointX * scale;
        CGFloat y = yscaled - minMapPointY * scale;
        
        // 移动
        x = x + shiftX;
        y = y + shiftY;
        
        //
        CGPoint point = CGPointMake(x, y);
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    
    return points;
}


// 创建bezier path
- (UIBezierPath *)createPolylinePathWithPoints:(NSArray *)points{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (int i = 0; i < points.count; i++) {
        
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    
    return path;
}

// 计算poline区域中心点
- (CLLocationCoordinate2D)caculateCenterCoordinate2D:(NSArray *)coordinate2Ds{
    
    CLLocationCoordinate2D coordinate2D = [[coordinate2Ds firstObject] MKCoordinateValue];
    
    double minLatitude = coordinate2D.latitude;
    double maxLatitude = coordinate2D.latitude;
    double minLongitude = coordinate2D.longitude;
    double maxLongitude = coordinate2D.longitude;
    
    for (int i = 0; i < coordinate2Ds.count; i++) {
        
        CLLocationCoordinate2D coordinate2D = [[coordinate2Ds objectAtIndex:i] MKCoordinateValue];
        
        if (coordinate2D.latitude < minLatitude) minLatitude = coordinate2D.latitude;
        if (coordinate2D.latitude > maxLatitude) maxLatitude = coordinate2D.latitude;
        if (coordinate2D.longitude < minLongitude) minLongitude = coordinate2D.longitude;
        if (coordinate2D.longitude > maxLongitude) maxLongitude = coordinate2D.longitude;
        
    }
    
    double centerLatitude = (maxLatitude + minLatitude) / 2.0;
    double centerLongitude = (maxLongitude + minLongitude) / 2.0;
    
    return CLLocationCoordinate2DMake(centerLatitude, centerLongitude);
}


// print coordinates
- (void)printCoordintes{
    
    for (int i = 0; i < self.coordinate2Ds.count; i++) {
        
        CLLocationCoordinate2D coordinate = [[self.coordinate2Ds objectAtIndex:i] MKCoordinateValue];
        NSLog(@"coordinate %d {%f,%f}", i, coordinate.latitude, coordinate.longitude);
    }
}






@end
