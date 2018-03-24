//
//  SDTabBarController.m
//  StravaDemo
//
//  Created by owen on 16/8/1.
//  Copyright © 2016年 owen. All rights reserved.
//

#import "SDTabBarController.h"
#import "MapViewController.h"
#import "TempViewController.h"

@interface SDTabBarController ()<UITabBarControllerDelegate>

@end

@implementation SDTabBarController


- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"tab bar:viewDidLoad");
    
    //中间tabBarItem插入背景view
    [self addBackgroundViewToCenterTabBarItem];
    
    //
    self.delegate = self;
}



//中间tabBarItem插入背景view
- (void)addBackgroundViewToCenterTabBarItem{
    
    CGFloat ITEM_WIDTH = self.tabBar.frame.size.width/5;
    CGFloat ITEM_HEIGHT = self.tabBar.frame.size.height;
    
    UIColor *orangeNormal = [UIColor colorWithRed:239/255.0 green:52/255.0 blue:9/255.0 alpha:1.0];
    UIColor *orangeDimed = [UIColor colorWithRed:180/255.0 green:52/255.0 blue:9/255.0 alpha:1.0];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.frame = CGRectMake(ITEM_WIDTH*2, 0, ITEM_WIDTH, ITEM_HEIGHT);
    backgroundView.backgroundColor = orangeNormal;
    
    [self.tabBar insertSubview:backgroundView atIndex:1];
}


//#MARK:UITabBarControllerDelegate
//
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    NSLog(@"shouldSelectViewController");
    
    if (viewController.tabBarItem.tag == 2) {
        
        //MapViewController *MapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
        //[self presentViewController:MapVC animated:YES completion:nil];
        
        // 使用storyboard reference
        //TempViewController *tempVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TempViewController"];
        //[self presentViewController:tempVC animated:YES completion:nil];
        
        UIStoryboard *runStoryboard = [UIStoryboard storyboardWithName:@"Run" bundle:nil];
        TempViewController *tempVC = [runStoryboard instantiateViewControllerWithIdentifier:@"TempViewController"];//Run.Storyboard中的initialVC
        [self presentViewController:tempVC animated:YES completion:nil];

        
        return NO;
    }
    
    return YES;
}


@end
