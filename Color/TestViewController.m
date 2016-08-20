//
//  ViewController.m
//  Color
//
//  Created by Tareyev Gregory on 11.06.16.
//  Copyright © 2016 Tareyev Gregory. All rights reserved.
//

#import "TestViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <AFNetworking/AFNetworking.h>
#import "AFOAuth2Manager.h"
#import "AppDelegate.h"
#import "EventManager.h"


@import Firebase;
@import GoogleSignIn;


@interface TestViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSArray *arrEvents;


@end
#define USER_CACHE [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.color.ru"]


static NSString *const kKeychainItemName = @"Gmail API";
static NSString *const kClientID = @"1041817891083-3c1238ola1dv1qj11b4eg1v1aqefa9qr.apps.googleusercontent.com";


@implementation TestViewController

@synthesize service = _service;
@synthesize output = _output;

// When the view loads, create necessary subviews, and initialize the Gmail API service.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    

    
    
    // NSString* accessToken = [GIDSignIn sharedInstance].currentUser.authentication.accessToken; = @"";
    // [[GIDSignIn sharedInstance].scopes ]
    // Create a UITextView to display output.
    
    
    
    self.output = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.output.editable = false;
    self.output.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
    self.output.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.output];
    
    // Initialize the Gmail API service & load existing credentials from the keychain if available.
    self.service = [[GTLServiceGmail alloc] init];
    self.service.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:nil];
    
   // [GIDSignIn sharedInstance].delegate = self;
    [[GIDSignIn sharedInstance] setScopes:[NSArray arrayWithObject: @"https://www.googleapis.com/auth/plus.me"]];
    [GIDSignIn sharedInstance].clientID = kClientID;
    
    NSLog(@"AT from UserDefaults: %@", [USER_CACHE valueForKey:@"googleAccessToken"]);
    
    
    
   // [[GIDSignIn sharedInstance] signInSilently];
   // NSLog(@"token: %@ ID: %@",  authResult.accessToken, authResult.userID); //[GIDSignIn sharedInstance].currentUser.authentication.accessToken);
}



// When the view appears, ensure that the Gmail API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    if (!self.service.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
        
    } else {
        [self fetchNumberOfUnreadMessages];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *HomeScreenViewController = (UIViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"homeScreen"];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController pushViewController:HomeScreenViewController animated:YES];

    }
    
   
}

// Construct a query and get a list of labels from the user's gmail. Display the
// label name in the UITextView
- (void)fetchNumberOfUnreadMessages {
//    self.output.text = @"Getting labels...";
//    GTLQueryGmail *query = [GTLQueryGmail queryForUsersLabelsList];
//    [self.service executeQuery:query
//                      delegate:self
//             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
//                                          //secret:@"AIzaSyCKhjdexJyKPBF34tC20XblaRcuw_PH1K0"];

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

- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLGmailListLabelsResponse *)labelsResponse
                          error:(NSError *)error {
    if (error == nil) {
        NSMutableString *labelString = [[NSMutableString alloc] init];
        if (labelsResponse.labels.count > 0) {
            [labelString appendString:@"Labels:\n"];
            for (GTLGmailLabel *label in labelsResponse.labels) {
                [labelString appendFormat:@"%@\n", label.name];
            }
        } else {
            [labelString appendString:@"No labels found."];
        }
        self.output.text = labelString;
    } else {
        [self showAlert:@"Error" message:error.localizedDescription];
    }
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
        //[authResult ref]
        NSLog(@"Token: %@ id: %@", authResult.accessToken, authResult.userID);
        [USER_CACHE setValue:authResult.accessToken forKey:@"googleAccessToken"];
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

@end