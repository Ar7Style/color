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
#import "WelcomeViewController.h"

#import <GoogleSignIn/GoogleSignIn.h>
#import "AFOAuth2Manager.h"



#define USER_CACHE [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.color.ru"]

static NSString *const kKeychainItemName = @"Gmail API";
static NSString *const kClientID = @"1041817891083-3c1238ola1dv1qj11b4eg1v1aqefa9qr.apps.googleusercontent.com";

@import Firebase;
@import FirebaseAuthUI;



@implementation AddAppsViewController 


@synthesize service = _service;
@synthesize output = _output;

-(void) viewDidLoad {
    [super viewDidLoad];
    [_activityView stopAnimating];
    
//    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
//                                                                                          clientID:kClientID
//                                                                                      clientSecret:nil];
//    
//    NSLog(@"accessToken: %@", auth.accessToken); //If the token is expired, this will be nil
//    
//    
//    // authorizeRequest will refresh the token, even though the NSURLRequest passed is nil
//    [auth authorizeRequest:nil
//         completionHandler:^(NSError *error) {
//             if (error) {
//                 NSLog(@"error: %@", error);
//                 NSLog(@"test 1");
//             }
//             else {
//                 NSLog(@"accessToken from handler: %@", auth.accessToken); //it shouldn´t be nil
//                 [USER_CACHE setValue:auth.accessToken forKey:@"googleAccessToken"];
//                 [USER_CACHE synchronize];
//                 NSLog(@"test 2");
//                 
//             }
//         }];
    
    
    /* for Gmail auth */
    self.service = [[GTLServiceGmail alloc] init];
    self.service.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:nil];
    
    [[GIDSignIn sharedInstance] setScopes:[NSArray arrayWithObject: @"https://www.googleapis.com/auth/plus.me"]];
    [GIDSignIn sharedInstance].clientID = kClientID;
    
   

    [_gmailButton setTitle:[[USER_CACHE valueForKey:@"isAuthGmail"] isEqualToString:@"1"] ? @"Wait a sec..." : @"+Gmail" forState:UIControlStateNormal];
    [_healthKitButton setTitle:[[USER_CACHE valueForKey:@"isAuthHealthkit"] isEqualToString:@"1"] ? @"Wait a sec..." : @"+HealthKit" forState:UIControlStateNormal];
    [_remindersButton setTitle:[[USER_CACHE valueForKey:@"isAuthReminders"] isEqualToString:@"1"] ? @"Wait a sec..." : @"+Reminders" forState:UIControlStateNormal];
    
    
    
    NSLog(@"AT from UserDefaults on HS: %@", [USER_CACHE valueForKey:@"googleAccessToken"]);
}

-(void)viewDidAppear:(BOOL)animated {
    if ([[USER_CACHE valueForKey:@"isAuth"] length] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        WelcomeViewController *welcomeVC = (WelcomeViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
        [self presentViewController:welcomeVC animated:NO completion:nil];
    }
 
}

-(void) getNewTokenForGoogle {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://securetoken.googleapis.com/v1/token?key=AIzaSyCKhjdexJyKPBF34tC20XblaRcuw_PH1K0"]];
   // NSLog(@"Access token: %@", [USER_CACHE valueForKey:@"googleAccessToken"]);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *parameters = @{@"grant_type": @"refresh_token", @"refresh_token": [USER_CACHE valueForKey:@"googleAccessToken"]};//grant_type=refresh_token&refresh_token=REFRESH_TOKEN
    [manager POST:URL.absoluteString parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
       // [USER_CACHE setValue:responseObject[@"messagesUnread"] forKey:@"numberOfUnreadMessages"];
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

-(void)viewWillAppear:(BOOL)animated {
    
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                          clientID:kClientID
                                                                                      clientSecret:nil];
    
    NSLog(@"accessToken: %@", auth.accessToken); //If the token is expired, this will be nil
    
    
    // authorizeRequest will refresh the token, even though the NSURLRequest passed is nil
    [auth authorizeRequest:nil
         completionHandler:^(NSError *error) {
             if (error) {
                 NSLog(@"error: %@", error);
             }
             else {
                 NSLog(@"accessToken from handler: %@", auth.accessToken); //it shouldn´t be nil
                 [USER_CACHE setValue:auth.accessToken forKey:@"googleAccessToken"];
             }
         }];
    
    if ( [[USER_CACHE valueForKey:@"isAuthGmail"] isEqualToString:@"1"] || [[USER_CACHE valueForKey:@"isAuthHealthkit"] isEqualToString:@"1"] || [[USER_CACHE valueForKey:@"isAuthReminders"] isEqualToString:@"1"]) {
        [_topLabel setHidden:YES];
    }
    
        if ([[USER_CACHE valueForKey:@"isAuthReminders"] isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self makeRemindersLabelVisible];
        });
    }

    if ([[USER_CACHE valueForKey:@"isAuthGmail"] isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self makeGmailLabelVisibleWithToken:[USER_CACHE valueForKey:@"googleAccessToken"]];
        });
    }
    if ([[USER_CACHE valueForKey:@"isAuthHealthkit"] isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self makeHealthkitLabelVisible];
        });
    }
    
}


/// not used
- (void)fetchNumberOfUnreadMessages {
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/me/labels/UNREAD?access_token=%@", [USER_CACHE valueForKey:@"googleAccessToken"]]];
    NSLog(@"Access token: %@", [USER_CACHE valueForKey:@"googleAccessToken"]);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSLog(@"keyNumber: %@", responseObject[@"messagesUnread"]);
        [USER_CACHE setValue:responseObject[@"messagesUnread"] forKey:@"numberOfUnreadMessages"];
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
}



// Creates the auth controller for authorizing access to Gmail API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeGmailReadonly, nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}



// Handle completion of the authorization process, and update the Gmail API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        NSLog(@"Token: %@ id: %@ refreshed: %@", authResult.accessToken, authResult.userID, authResult.refreshToken);
        [self makeGmailLabelVisibleWithToken:authResult.accessToken]; [authResult refreshToken];
        [USER_CACHE setValue:authResult.accessToken forKey:@"googleAccessToken"];
        [USER_CACHE setValue:authResult.refreshToken forKey:@"googleRefreshToken"];
        [USER_CACHE setValue:@"1" forKey:@"isAuthGmail"];
        [USER_CACHE synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}



// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void) makeGmailLabelVisibleWithToken:(NSString*)accessToken {
    [_gmailButton setEnabled:NO];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/me/labels/UNREAD?access_token=%@", accessToken]]; //[USER_CACHE valueForKey:@"googleAccessToken"]]];
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
       NSDate* newDate = [calendar startOfDayForDate:endDate];
       
       
       NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:newDate endDate:[NSDate date] options:HKQueryOptionStrictStartDate];

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
                           dailyAVG += [[samples quantity] doubleValueForUnit:[HKUnit countUnit]];
                       }
                       NSLog(@"daily: %d", dailyAVG);
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           [_healthKitButton setEnabled:NO];
                           
            if (dailyAVG > 10000)
                    dailyAVG = 10000;
                [_healthKitButton setTitle:[NSString stringWithFormat:@"%d steps left", 10000-dailyAVG] forState:UIControlStateNormal];
               [_healthKitButton setTitleColor:[UIColor colorWithRed:27.0/100.0 green:86.0/100.0 blue:37.0/100.0 alpha:1.0] forState:UIControlStateNormal];
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

-(void)makeRocketlistLabelVisible {

    __block NSInteger taskCount;
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
        taskCount =  snapshotValue.count;
      //  [_rocketListButton setTitle:[NSString stringWithFormat:@"finish %ld tasks", taskCount] forState:UIControlStateNormal];
      //  [_rocketListButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        
    }];
    
}

-(void)makeRemindersLabelVisible {
   EKEventStore *eventStore = [[EKEventStore alloc] init];

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
                    
                    [_remindersButton setTitle:[NSString stringWithFormat:@"finish %ld %@", (unsigned long)reminders.count, (reminders.count == 1) ? @"task" : @"tasks"] forState:UIControlStateNormal];
                    [_remindersButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                    [USER_CACHE setValue:@"1" forKey:@"isAuthReminders"];
                    [USER_CACHE setValue:[NSString stringWithFormat:@"%ld", (unsigned long)reminders.count] forKey:@"remindersTasksCount"];
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
    
    [_remindersButton setTitle:[NSString stringWithFormat:@"finish %ld %@", (unsigned long)reminders.count, (reminders.count == 1) ? @"task" : @"tasks"] forState:UIControlStateNormal];
    [_remindersButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
     [USER_CACHE setValue:@"1" forKey:@"isAuthReminders"];
    [USER_CACHE setValue:[NSString stringWithFormat:@"%ld", (unsigned long)reminders.count] forKey:@"remindersTasksCount"];
    [USER_CACHE synchronize];
          });
      }];
    } else {
        // Access denied
        NSLog(@"access denied");
    }
    
}



- (IBAction)gmailChoosed:(id)sender {
    if (!self.service.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
      //  [self presentViewController:[self createAuthController] animated:YES completion:nil];
        GIDSignIn *signin = [GIDSignIn sharedInstance];
        signin.shouldFetchBasicProfile = true;
        signin.delegate = self;
        signin.uiDelegate = self;
        [signin hasAuthInKeychain];
        [signin signIn];
   
    } else {
        [self makeGmailLabelVisibleWithToken:[USER_CACHE valueForKey:@"googleAccessToken"]];
    }
    [USER_CACHE setValue:@"1" forKey:@"isAuthGmail"];
    [USER_CACHE synchronize];

}


// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    //present view controller
    [self presentViewController:[self createAuthController] animated:YES completion:nil];

}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    //dismiss view controller
    [self dismissViewControllerAnimated:NO completion:nil];
}

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


- (IBAction)update:(id)sender {
    [_activityView startAnimating];
    [_updateButton setHidden:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([USER_CACHE valueForKey:@"isAuthGmail"])
            [self makeGmailLabelVisibleWithToken:[USER_CACHE valueForKey:@"googleAccessToken"]];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([USER_CACHE valueForKey:@"isAuthHealthkit"])
            [self makeHealthkitLabelVisible];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([USER_CACHE valueForKey:@"isAuthReminders"])
            [self makeRemindersLabelVisible];
    });
    [_activityView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1];
    
    [_updateButton performSelector:@selector(setHidden:) withObject:nil afterDelay:1];

}


@end
