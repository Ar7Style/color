//
//  ViewController.h
//  Color
//
//  Created by Tareyev Gregory on 11.06.16.
//  Copyright © 2016 Tareyev Gregory. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLGmail.h"
#import <GoogleSignIn/GoogleSignIn.h>


@interface TestViewController : UIViewController <GIDSignInUIDelegate>

@property (nonatomic, strong) GTLServiceGmail *service;
@property (nonatomic, strong) UITextView *output;

@property (weak, nonatomic) IBOutlet UIButton *showLogsButton;
@property (weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
@end

