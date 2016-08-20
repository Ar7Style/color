//
//  AddAppsViewController.m
//  Color
//
//  Created by Tareyev Gregory on 12.06.16.
//  Copyright © 2016 Tareyev Gregory. All rights reserved.
//

#import "AddAppsViewController.h"
#import "TasksViewController.h"
#import <HealthKit/HealthKit.h>
#import <AFNetworking/AFNetworking.h>
#import "EventManager.h"



#define USER_CACHE [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.color.ru"]

@import Firebase;
@import FirebaseAuthUI;

@implementation AddAppsViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    [_gmailButton setTitle:[[USER_CACHE valueForKey:@"isAuthGmail"] isEqualToString:@"1"] ? @"Wait a sec..." : @"+Gmail" forState:UIControlStateNormal];
    [_healthKitButton setTitle:[[USER_CACHE valueForKey:@"isAuthHealthkit"] isEqualToString:@"1"] ? @"Wait a sec..." : @"+HealthKit" forState:UIControlStateNormal];
    [_remindersButton setTitle:[[USER_CACHE valueForKey:@"isAuthReminders"] isEqualToString:@"1"] ? @"Wait a sec..." : @"+Reminders" forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated {
    
}

-(void)viewWillAppear:(BOOL)animated {
//    if ([[USER_CACHE valueForKey:@"isAuthRocketlist"] isEqualToString:@"1"]) {
//        _rocketListButton.enabled = NO;
//        [_rocketListButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//    }
//    if ([[USER_CACHE valueForKey:@"isAuthGmail"] isEqualToString:@"1"]) {
//        _gmailButton.enabled = NO;
//    }
//    if ([[USER_CACHE valueForKey:@"isAuthHealthkit"] isEqualToString:@"1"]) {
//        _healthKitButton.enabled = NO;
//    }
  //  if ([[USER_CACHE valueForKey:@"isAuthGmail"] isEqualToString:@"1"])
        
    if ([[USER_CACHE valueForKey:@"isAuthReminders"] isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self makeRemindersLabelVisible];
        });
    }
    if ([[USER_CACHE valueForKey:@"isAuthGmail"] isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self makeGmailLabelVisible];
        });
    }
    if ([[USER_CACHE valueForKey:@"isAuthHealthkit"] isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self makeHealthkitLabelVisible];
        });
    }
    
}

-(void) makeGmailLabelVisible {
    [_gmailButton setEnabled:NO];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/me/labels/UNREAD?access_token=%@", [USER_CACHE valueForKey:@"googleAccessToken"]]];
    NSLog(@"Access token: %@", [USER_CACHE valueForKey:@"googleAccessToken"]);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON from Google: %@", responseObject);
        NSLog(@"keyNumber: %@", responseObject[@"messagesUnread"]);
        [USER_CACHE setValue:responseObject[@"messagesUnread"] forKey:@"numberOfUnreadMessages"];
        [_gmailButton setTitle:[NSString stringWithFormat:@"Read %@ messages", [USER_CACHE valueForKey:@"numberOfUnreadMessages"]] forState:UIControlStateNormal];
        [_gmailButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)makeHealthkitLabelVisible {
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable])
    {
        // Add your HealthKit code here
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        
        // Share body mass, height and body mass index
        NSSet *shareObjectTypes = [NSSet setWithObjects:
                           //        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                             //      [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                               //    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                                   nil];
        
        // Read date of birth, biological sex and step count
        NSSet *readObjectTypes  = [NSSet setWithObjects:
                                  // [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                                   //[HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                                   [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                                   nil];
        
        // Request access
        [healthStore requestAuthorizationToShareTypes:nil
                                            readTypes:readObjectTypes
                                           completion:^(BOOL success, NSError *error) {
                                               
                                               if(success == YES)
                                               {
                                                   // Set your start and end date for your query of interest

//                                                   NSDate *startDate; //= [[NSDate date] descriptionWithLocale:currentLocale];
//                                                   NSDate *endDate;
                                                   
                                                   // Use the sample type for step count
                                                   HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                                                   
                                                   
                                                   
                                                   // Create a predicate to set start/end date bounds of the query
                                                   
                                                   // Create a sort descriptor for sorting by start date
                                                   NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:YES];
                                                   
                                                   //////////////
                                                   NSCalendar *calendar = [NSCalendar currentCalendar];
                                                   NSDateComponents *interval = [[NSDateComponents alloc] init];
                                                   interval.day = 1;
                                                   NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                                                                    fromDate:[NSDate date]];
                                                   anchorComponents.hour = 0;
                                                   NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
                                                   HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                                                   
                                                   // Create the query
                                                   HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                                                                          quantitySamplePredicate:nil
                                                                                                                                          options:HKStatisticsOptionCumulativeSum
                                                                                                                                       anchorDate:anchorDate
                                                                                                                               intervalComponents:interval];
                                                   
                                                   // Set the results handler
                                                   
                                                       NSDate *endDate = [NSDate date];
                                                       NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                                value:-1
                                                                                               toDate:endDate
                                                                                              options:0];

                                                   
                                                   NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:[NSDate dateWithTimeIntervalSinceNow:0] options:HKQueryOptionStrictStartDate];

                                                   //////////////
                                                   __block int dailyAVG = 0;

                                                   HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType
                                                                                                                predicate:predicate
                                                                                                                    limit:HKObjectQueryNoLimit
                                                                                                          sortDescriptors:@[sortDescriptor]
                                                                                                           resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                                                                               if(!error && results)
                                                                                                               {
                                                                                                                   for(HKQuantitySample *samples in results)
                                                                                                                   {
                                                                                                               // NSLog(@"Result: %@", samples);
                                                                                                                       dailyAVG += [[samples quantity] doubleValueForUnit:[HKUnit countUnit]];
                                                                                                                   }
                                                                                                                   NSLog(@"daily: %d", dailyAVG);
                                                                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                       
                                                                                                                       [_healthKitButton setEnabled:NO];
                                                                                                                       
                                                                                                                       [_healthKitButton setTitle:[NSString stringWithFormat:@"%d steps left", 10000-dailyAVG] forState:UIControlStateNormal];
                                                                                                                       [_healthKitButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
                                                                                                                       [USER_CACHE setValue:@"1" forKey:@"isAuthHealthkit"];
                                                                                                                       [USER_CACHE setValue:[NSString stringWithFormat:@"%d", 10000-dailyAVG] forKey:@"HealthkitStepsCount"];
                                                                                                                       [USER_CACHE synchronize];
                                                                                                                   });
                                                                                                                   
                                                                                                               }
                                                                                                               
                                                                                                           }];
                                                   
                                                   // Execute the query
                                                   [healthStore executeQuery:sampleQuery];
                                                   
                                               }
                                               else
                                               {
                                                   // Determine if it was an error or if the
                                                   // user just canceld the authorization request
                                               }
                                               
                                           }];
    }
    
    
    
}

//-(void)makeRocketlistLabelVisible {
//    [_rocketListButton setEnabled:NO];
//
//    __block NSInteger taskCount;
//    NSString* userEmail = [USER_CACHE valueForKey:@"userEmail"];
//    NSString *tempEmail = [userEmail stringByReplacingOccurrencesOfString:@"@" withString:@""];
//    NSString *temp = [tempEmail stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    
//    NSString *filteredUserEmail = [temp stringByReplacingOccurrencesOfString:@"." withString:@""];
//    if (filteredUserEmail.length == 0) return;
//    
//    //   Get a reference to our posts
//    FIRDatabaseReference *rootRef = [[FIRDatabase database] reference];
//    FIRDatabaseReference* ref = [rootRef child:[NSString stringWithFormat:@"notes/%@", filteredUserEmail]];
//    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
//        NSArray* snapshotValue = snapshot.value;
//        
//        NSLog(@"snapshotValue count: %lu", (unsigned long)snapshotValue.count);
//        taskCount =  snapshotValue.count;
//        [_rocketListButton setTitle:[NSString stringWithFormat:@"finish %ld tasks", taskCount] forState:UIControlStateNormal];
//        [_rocketListButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//        [USER_CACHE setValue:[NSString stringWithFormat:@"%ld",(long)taskCount] forKey:@"rocketlistTasksCount"];
//        [USER_CACHE synchronize];
//        
//        NSLog(@"Tasks count from HS: %@",[USER_CACHE valueForKey:@"rocketlistTasksCount"] );
//        
//    }];
//    
//}

-(void)makeRemindersLabelVisible {
   EKEventStore *eventStore = [[EKEventStore alloc] init];
    EKCalendar *defaultReminderList = [eventStore defaultCalendarForNewReminders];
    NSArray *reminderLists = [eventStore calendarsForEntityType:EKEntityTypeReminder];


    NSPredicate *predicate = [eventStore predicateForIncompleteRemindersWithDueDateStarting:nil ending:nil calendars:[eventStore calendarsForEntityType:EKEntityTypeReminder]];
    BOOL needsToRequestAccessToEventStore = NO; // iOS 5 behavior
    EKAuthorizationStatus authorizationStatus = EKAuthorizationStatusAuthorized; // iOS 5 behavior
    if ([[EKEventStore class] respondsToSelector:@selector(authorizationStatusForEntityType:)]) {
        authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        needsToRequestAccessToEventStore = (authorizationStatus == EKAuthorizationStatusNotDetermined);
    }
    
    if (needsToRequestAccessToEventStore) {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // You can use the event store now
                    [_remindersButton setEnabled:NO];
                    
                    [_remindersButton setTitle:[NSString stringWithFormat:@"finish %ld %@", reminders.count, (reminders.count == 1) ? @"task" : @"tasks"] forState:UIControlStateNormal];
                    [_remindersButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                    [USER_CACHE setValue:@"1" forKey:@"isAuthReminders"];
                    [USER_CACHE setValue:[NSString stringWithFormat:@"%ld", reminders.count] forKey:@"rocketlistTasksCount"];
                    [USER_CACHE synchronize];
                    
                });
            }];
                 
                    
            }
        
    }];
} else if (authorizationStatus == EKAuthorizationStatusAuthorized) {
        // You can use the event store now
      [eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
          dispatch_async(dispatch_get_main_queue(), ^{
    [_remindersButton setEnabled:NO];
    
    [_remindersButton setTitle:[NSString stringWithFormat:@"finish %ld %@", reminders.count, (reminders.count == 1) ? @"task" : @"tasks"] forState:UIControlStateNormal];
    [_remindersButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    // [USER_CACHE setValue:@"1" forKey:@"isAuthReminders"];
    [USER_CACHE setValue:[NSString stringWithFormat:@"%ld", reminders.count] forKey:@"rocketlistTasksCount"];
    [USER_CACHE synchronize];
          });
      }];
    } else {
        // Access denied
        NSLog(@"access denied");
    }
    
    
    /* EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        NSLog(@"permission");
    }];
    
    NSPredicate *predicate = [store predicateForRemindersInCalendars:nil];
    
    [store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_remindersButton setEnabled:NO];
            
            [_remindersButton setTitle:[NSString stringWithFormat:@"finish %ld tasks", reminders.count] forState:UIControlStateNormal];
            [_remindersButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [USER_CACHE setValue:@"1" forKey:@"isAuthReminders"];
            [USER_CACHE setValue:[NSString stringWithFormat:@"%ld", reminders.count] forKey:@"rocketlistTasksCount"];
            [USER_CACHE synchronize];
        });
        
    
     
     }]; */
    
}

//- (void)authUI:(FIRAuthUI *)authUI
//didSignInWithUser:(nullable FIRUser *)user
//         error:(nullable NSError *)error {
//    if (!error) {
//        [USER_CACHE setValue:@"1" forKey:@"isAuthRocketlist"];
//        [USER_CACHE setValue:user.email forKey:@"userEmail"];
//        [USER_CACHE synchronize];
//        NSLog(@"isAuth after auth: %@", [USER_CACHE valueForKey:@"isAuth"]);
//        NSLog(@"Email after auth: %@", [USER_CACHE valueForKey:@"userEmail"]);
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self makeRocketListLabelVisible];
//        });
//    }
//    else {
//        NSLog(@"error in auth");
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//
//    // Implement this method to handle signed in user or error if any.
//}
//
//
//- (IBAction)rocketListChoosed:(id)sender {
//    FIRAuthUI *authUI = [FIRAuthUI authUI];
//    authUI.delegate = self;
//
//    UIViewController *authViewController = [authUI authViewController];
//    if (![[USER_CACHE valueForKey:@"isAuthFirebase"] isEqualToString:@"1"]) {
//        [self presentViewController:authViewController animated:NO completion:nil];
//        [USER_CACHE setValue:@"1" forKey:@"isAuth"];
//    }
//}

- (IBAction)remindersChoosed:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self makeRemindersLabelVisible];
    });
}

- (IBAction)healthKitChoosed:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self makeHealthkitLabelVisible];
    });
}

@end
