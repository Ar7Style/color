//
//  WelcomeViewController.m
//  Color
//
//  Created by Tareyev Gregory on 29.08.16.
//  Copyright © 2016 Tareyev Gregory. All rights reserved.
//

#import "WelcomeViewController.h"
@import Firebase;

#define USER_CACHE [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.color.ru"]

@interface WelcomeViewController () 
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.emailTextField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; // Dismiss the keyboard.
    // Execute any additional code
    [self goButtonPressed];
    
    return YES;
}

-(void)goButtonPressed {
    if (![_emailTextField.text containsString:@"@"] || ![_emailTextField.text containsString:@"."]) {
        [self showErrorWithMessage:@"Incorrect email"];
    }
    else {
        FIRApp* color = [FIRApp appNamed:@"color"];
        
        FIRDatabaseReference *rootRef = [[FIRDatabase databaseForApp:color]referenceFromURL:@"https://color-21c74.firebaseio.com"];
        NSString* filteredEmail0 = [_emailTextField.text stringByReplacingOccurrencesOfString:@"@" withString:@"000"];
        NSString* filteredEmail = [filteredEmail0 stringByReplacingOccurrencesOfString:@"." withString:@"999"];
        FIRDatabaseReference* emailRef = [rootRef child:filteredEmail];
        
        [emailRef setValue:@" "];
        [USER_CACHE setValue:@"1" forKey:@"isAuth"];
        [USER_CACHE synchronize];
        
        [self performSegueWithIdentifier:@"toMainScreen" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)goButtonPressed:(id)sender {
    [self goButtonPressed];
    
}

-(void)dismissKeyboard {
    [_emailTextField resignFirstResponder];
}

-(void) showErrorWithMessage:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Try again"
                                
                                                                   message:message
                                
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                 
                                                       handler:^(UIAlertAction * action) {}];
    
    [alert addAction:okayAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
