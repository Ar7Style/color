//
//  TasksViewController.m
//  Color
//
//  Created by Tareyev Gregory on 12.06.16.
//  Copyright © 2016 Tareyev Gregory. All rights reserved.
//

#import "TasksViewController.h"
#import "AddAppsViewController.h"
@import Firebase;

#define USER_CACHE [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.color.ru"]


@implementation TasksViewController


-(void) viewDidLoad {
    [super viewDidLoad];
    
    _gmailLabel.text = [[USER_CACHE valueForKey:@"isAuthGmail"] isEqualToString:@"1"] ? @"Wait a sec..." : @"Gmail";
    _healthKitLabel.text =[[USER_CACHE valueForKey:@"isAuthHealthkit"] isEqualToString:@"1"] ? @"Wait a sec..." : @"HealthKit";
    _rocketListLabel.text = [[USER_CACHE valueForKey:@"isAuthRocketlist"] isEqualToString:@"1"] ? @"Wait a sec..." : @"RocketList";
   
}

-(void)viewDidAppear:(BOOL)animated {
     if (![[USER_CACHE valueForKey:@"isAuthGmail"] isEqualToString:@"1"] && ![[USER_CACHE valueForKey:@"isAuthHealthkit"] isEqualToString:@"1"] && ![[USER_CACHE valueForKey:@"isAuthRocketlist"] isEqualToString:@"1"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    AddAppsViewController *addAppsVC = (AddAppsViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"addAppsViewController"];
    [self presentViewController:addAppsVC animated:NO completion:nil];
     }

}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getNumberOfRocketlistTasks];
    });
}

-(void)getNumberOfRocketlistTasks {
    
    NSString* userEmail = [USER_CACHE valueForKey:@"userEmail"];
    NSString *tempEmail = [userEmail stringByReplacingOccurrencesOfString:@"@" withString:@""];
    NSString *temp = [tempEmail stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *filteredUserEmail = [temp stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (filteredUserEmail.length == 0) return;
    //   Get a reference to our posts
    FIRDatabaseReference *rootRef = [[FIRDatabase database] reference];
    FIRDatabaseReference* ref = [rootRef child:[NSString stringWithFormat:@"notes/%@", filteredUserEmail]];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSArray* snapshotValue = snapshot.value;
        
        NSLog(@"snapshotValue count: %lu", (unsigned long)snapshotValue.count);
         _taskCount =  snapshotValue.count;
        _rocketListLabel.text = [NSString stringWithFormat:@"finish %ld tasks", _taskCount];
        [USER_CACHE setValue:[NSString stringWithFormat:@"%ld",(long)_taskCount] forKey:@"rocketlistTasksCount"];
        [USER_CACHE synchronize];
        
        NSLog(@"From today: %@",[USER_CACHE valueForKey:@"rocketlistTasksCount"] );

        
        
    }];
    NSLog(@"getData");

}



- (IBAction)backButtonPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    AddAppsViewController *addAppsVC = (AddAppsViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"addAppsViewController"];
    [self presentViewController:addAppsVC animated:NO completion:nil];
}

@end
