//
//  SavingDateViewController.h
//  StravaDemo
//
//  Created by owen on 16/9/2.
//  Copyright © 2016年 owen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavingDataViewController : UIViewController

@property int seconds;
@property CGFloat distance;
@property NSArray *locations;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
