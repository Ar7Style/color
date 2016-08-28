//
//  AddAppsViewController.h
//  Color
//
//  Created by Tareyev Gregory on 12.06.16.
//  Copyright © 2016 Tareyev Gregory. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLGmail.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface AddAppsViewController : UIViewController <GIDSignInUIDelegate, GIDSignInDelegate>

@property (nonatomic, strong) GTLServiceGmail *service;
@property (nonatomic, strong) UITextView *output;

@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@property (weak, nonatomic) IBOutlet UIButton *gmailButton;
@property (weak, nonatomic) IBOutlet UIButton *remindersButton;
@property (weak, nonatomic) IBOutlet UIButton *healthKitButton;

@end
