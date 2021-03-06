//
//  TodayViewController.m
//  TodoExtenstion
//
//  Created by Tareyev Gregory on 16-4-20.
//  Copyright (c) 2016 Tareyev Gregory. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>


#define CELL_HEIGHT 30
#define SECTION_HEIGHT 25
#define USER_CACHE [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.color.ru"]

@interface TodayViewController () <NCWidgetProviding,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableDictionary* data;
@property (nonatomic,strong) NSMutableArray* todoList;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource =self;
    self.tableView.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

-(void) viewWillAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
    });
    self.preferredContentSize = self.tableView.contentSize;

}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsMake(defaultMarginInsets.top, defaultMarginInsets.left-30, defaultMarginInsets.bottom, defaultMarginInsets.right);
    
}

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (_todoList.count == 0) {
//        return 0;
//    }else{
        return SECTION_HEIGHT;
    //}
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    _todoList = [NSMutableArray arrayWithArray:[USER_CACHE valueForKey:@"todoListFromServer"]];
//    if (_todoList.count == 0 ) {
//        return nil;
//    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    label.textColor = [UIColor orangeColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"Your tasks";
    [view addSubview:label];
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    _todoList = [NSMutableArray arrayWithArray:[[USER_CACHE valueForKey:@"todoListFromServer"] mutableCopy]];
//
//    if(_todoList.count == 0){
//        cell.textLabel.text = @"empty";
//    }else{
//            cell.textLabel.text = [_todoList objectAtIndex:indexPath.row];
//   }
   // NSLog(@"From today: %@",[USER_CACHE valueForKey:@"rocketlistTasksCount"] );
    
 //   cell.textLabel.text = [NSString stringWithFormat:@"finish %@ tasks", [USER_CACHE valueForKey:@"rocketlistTasksCount"]];
    if (indexPath.row == 0 ) {
        if( ![[USER_CACHE valueForKey:@"isAuthGmail"] isEqualToString:@"1"] )
            cell.textLabel.text = [NSString stringWithFormat:@"Connect Gmail"];
        else {
            cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.text = [NSString stringWithFormat:@"read %@ messages", [USER_CACHE valueForKey:@"numberOfUnreadMessages"]];
        }
    }
    if (indexPath.row == 1 ) {
        if( [[USER_CACHE valueForKey:@"remindersTasksCount"] length] ==0)
             cell.textLabel.text = [NSString stringWithFormat:@"Connect reminders"];
        else {
            cell.textLabel.text = [NSString stringWithFormat:@"finish %@ tasks", [USER_CACHE valueForKey:@"remindersTasksCount"]];
            cell.textLabel.textColor = [UIColor orangeColor];
        }
    }
    if (indexPath.row == 2 ) {
        if ( [[USER_CACHE valueForKey:@"HealthkitStepsCount"] length] ==0)
              cell.textLabel.text = [NSString stringWithFormat:@"Connect HealthKit"];
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ steps left", [USER_CACHE valueForKey:@"HealthkitStepsCount"]];
            cell.textLabel.textColor = [UIColor colorWithRed:27.0/100.0 green:86.0/100.0 blue:37.0/100.0 alpha:1.0];
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.extensionContext openURL:[NSURL URLWithString:@"rocketlist://"] completionHandler:^(BOOL success) {
//        
//    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}


- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

@end