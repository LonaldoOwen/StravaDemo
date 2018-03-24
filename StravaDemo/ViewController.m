//
//  ViewController.m
//  StravaDemo
//
//  Created by owen on 16/5/22.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "ViewController.h"

@import CoreText;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *dataView;

@property (nonatomic) BOOL isFlag;
@property (strong, nonatomic) NSMutableArray *barArray;
@property (strong, nonatomic) NSArray *toValueArray;
@property (strong, nonatomic) NSArray *fromValueArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add button
    UIButton *animationBtn = [[UIButton alloc] init];
    animationBtn.bounds = CGRectMake(0, 0, 100, 50);
    animationBtn.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame) + 200);
    [animationBtn setTitle:@"animate" forState:UIControlStateNormal];
    [animationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:animationBtn];
    
    animationBtn.layer.cornerRadius = 10;
    animationBtn.layer.borderWidth = 2;
    animationBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    
    [animationBtn addTarget:self action:@selector(handleTapAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //
    self.isFlag = YES;
    NSLog(@"view1 background color:%@", self.view1.backgroundColor);
    NSLog(@"view2 background color:%@", self.view2.backgroundColor);
    NSLog(@"view3 background color:%@", self.view3.backgroundColor);
    
    
    //
    [self addLayer1];
    //
    UILabel *weakLabel = [[UILabel alloc]init];
    weakLabel.frame = CGRectMake(20, 10, 150, 30);
    weakLabel.text = @"本周";
    weakLabel.textAlignment = NSTextAlignmentLeft;
    weakLabel.textColor = [UIColor lightGrayColor];
    weakLabel.font = [UIFont systemFontOfSize:14.0];
    //weakLabel.backgroundColor = [UIColor greenColor];
    [self.dataView addSubview:weakLabel];
    
    //
    UILabel *mileLabel = [[UILabel alloc] init];
    mileLabel.frame = CGRectMake(20, 40, 150, 40);
    mileLabel.text = @"375.7km";
    mileLabel.textAlignment = NSTextAlignmentLeft;
    mileLabel.textColor = [UIColor whiteColor];
    mileLabel.font = [UIFont systemFontOfSize:32];
    //mileLabel.backgroundColor = [UIColor lightGrayColor];
    [self.dataView addSubview:mileLabel];
    
    //
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.frame = CGRectMake(20, 80, 110, 30);
    timeLabel.text = @"24小时17分钟";
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont systemFontOfSize:14.0];
    //timeLabel.backgroundColor = [UIColor blueColor];
    [self.dataView addSubview:timeLabel];
    
    //
    UILabel *heightLabel = [[UILabel alloc] init];
    heightLabel.frame = CGRectMake(20 + 110, 80, 50, 30);
    heightLabel.text = @"329m";
    heightLabel.textAlignment = NSTextAlignmentLeft;
    heightLabel.textColor = [UIColor whiteColor];
    heightLabel.font = [UIFont systemFontOfSize:14.0];
    //heightLabel.backgroundColor = [UIColor lightGrayColor];
    [self.dataView addSubview:heightLabel];
    
    
}


- (void)addLayer1{
    
    // layer1:backround layer
//    CALayer *layer1 = [[CALayer alloc] init];
//    layer1.bounds = CGRectMake(0, 0, 300, 200);
//    layer1.position = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
//    layer1.backgroundColor = [self.view3.backgroundColor CGColor];
//    layer1.masksToBounds = YES;
//    [self.view.layer addSublayer:layer1];
    
    CALayer *layer1 = [[CALayer alloc] init];
    layer1.bounds = self.dataView.bounds;
    layer1.position = CGPointMake(CGRectGetMidX(self.dataView.bounds), CGRectGetMidY(self.dataView.bounds));
    //layer1.frame = self.dataView.frame;
    //layer1.backgroundColor = [UIColor orangeColor].CGColor;
    [self.dataView.layer addSublayer:layer1];
    
    // bar layer
    CALayer *barLayer = [CALayer layer];
    barLayer.bounds = CGRectMake(0, 0, 150, 50);
    barLayer.position = CGPointMake(150/2 + 20, 150 - 10);
    //barLayer.backgroundColor = [UIColor whiteColor].CGColor;
    barLayer.masksToBounds = YES;
    [layer1 addSublayer:barLayer];
    
    //
    self.barArray = [NSMutableArray array];
    //self.toValueArray = [NSMutableArray array];
    //self.fromValueArray = [NSMutableArray array];
    
    static const float positionY = 63;
    
    for (int i = 0; i < 7; i++) {
        
        UIColor *barColor = self.view1.backgroundColor;
        CALayer *bar = [CALayer layer];
        bar.bounds = CGRectMake(0, 0, 5, 30);
        bar.position = CGPointMake((5 + 20 * i), positionY);
        bar.backgroundColor = barColor.CGColor;
        [barLayer addSublayer:bar];
        [self.barArray addObject:bar];
    }

    
    self.toValueArray = @[@(positionY-27), @(positionY-0), @(positionY-10), @(positionY-20), @(positionY-27), @(positionY-0), @(positionY-27)];
    self.fromValueArray = @[@(positionY-27), @(positionY-27), @(positionY-0), @(positionY-27), @(positionY-10), @(positionY-0), @(positionY-2)];
    
    
    // text layer
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.bounds = CGRectMake(0, 0, 150, 20);
    textLayer.position = CGPointMake(150/2 + 20, 200 -20);
    //textLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
    //textLayer.opacity = 0.8;
    [layer1 addSublayer:textLayer];
    
    NSString *string = @"一 二 三 四 五 六 日";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.view1.backgroundColor range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSKernAttributeName value:@(2.2) range:NSMakeRange(0, attributedString.length)];
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineSpacing = 5.0;
//    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    
    textLayer.string = attributedString;
    //textLayer.foregroundColor = self.view1.backgroundColor.CGColor;
    //textLayer.fontSize = 14.0;
    //CFStringRef fontName = CFSTR("Helvetica");
    CGFloat fontSize = 14.0;
    textLayer.font = CTFontCreateWithName(NULL, fontSize, NULL);
    textLayer.alignmentMode = kCAAlignmentLeft;
    textLayer.wrapped = YES;
    //textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    // circle layer
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 120, 120)];
    
    CAShapeLayer *backCircle = [CAShapeLayer layer];
    backCircle.bounds = CGRectMake(0, 0, 120, 120);
    backCircle.position = CGPointMake(CGRectGetMidX(layer1.bounds), 100);
    backCircle.path = path.CGPath;
    backCircle.lineWidth = 4.0;
    [backCircle setStrokeColor:[[UIColor blackColor] CGColor]];
    [backCircle setFillColor:[UIColor clearColor].CGColor];
    [layer1 addSublayer:backCircle];
    
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.bounds = CGRectMake(0, 0, 120, 120);
    circleLayer.position = CGPointMake(CGRectGetMidX(self.dataView.bounds), 100);
    circleLayer.path = path.CGPath;
    circleLayer.lineWidth = 4.0;
    [circleLayer setStrokeColor:self.view1.backgroundColor.CGColor];
    [circleLayer setFillColor:[UIColor clearColor].CGColor];
    circleLayer.backgroundColor = [UIColor clearColor].CGColor;
    circleLayer.strokeStart = 0.0;
    circleLayer.strokeEnd = 0.8;
    [layer1 addSublayer:circleLayer];
    [self.barArray addObject:circleLayer];
    
    
    
}


// handle button tap action
- (void)handleTapAction:(id)sender{
    //
    NSLog(@"Tap");
    
    //
    // animation
    if (self.isFlag) {
        //
        for (int i = 0; i < 7; i++) {
            CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.y"];
            move.fromValue = [self.fromValueArray objectAtIndex:i];
            move.toValue = [self.toValueArray objectAtIndex:i];
            move.duration = 1.0;
            //
            CALayer *layer = [self.barArray objectAtIndex:i];
            
            layer.position = CGPointMake(layer.position.x, [[self.toValueArray objectAtIndex:i] floatValue]);
            [layer addAnimation:move forKey:nil];
            
        }
        
        //
        CAShapeLayer *circleLayer = (CAShapeLayer *)[self.barArray objectAtIndex:7];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 1.0;
        animation.fromValue = @(0.0);
        animation.toValue = @(0.8);
        circleLayer.strokeEnd = 0.8;
        [circleLayer addAnimation:animation forKey:nil];
        
    } else {
        //
        for (int i = 0; i < 7; i++) {
            CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.y"];
            move.fromValue = [self.toValueArray objectAtIndex:i];
            move.toValue = [self.fromValueArray objectAtIndex:i];
            move.duration = 1.0;
            //
            CALayer *layer = [self.barArray objectAtIndex:i];
            
            layer.position = CGPointMake(layer.position.x, [[self.fromValueArray objectAtIndex:i] floatValue]);
            [layer addAnimation:move forKey:nil];
        }
        
        //
        CAShapeLayer *circleLayer = (CAShapeLayer *)[self.barArray objectAtIndex:7];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 1.0;
        animation.fromValue = @(0.8);
        animation.toValue = @(0.0);
        circleLayer.strokeEnd = 0.0;
        [circleLayer addAnimation:animation forKey:nil];
    }
    
    
    self.isFlag = self.isFlag ? NO :YES;
    NSLog(@"isFlag:%d", self.isFlag);
}



@end
