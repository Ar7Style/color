//
//  TasksViewController.h
//  Color
//
//  Created by Tareyev Gregory on 12.06.16.
//  Copyright © 2016 Tareyev Gregory. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TasksViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *gmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *rocketListLabel;
@property (weak, nonatomic) IBOutlet UILabel *healthKitLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property NSInteger taskCount;

@end
