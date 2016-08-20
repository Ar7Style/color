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

@interface AddAppsViewController : UIViewController <GIDSignInUIDelegate>

@property (weak, nonatomic) IBOutlet UIButton *gmailButton;
@property (weak, nonatomic) IBOutlet UIButton *remindersButton;
@property (weak, nonatomic) IBOutlet UIButton *healthKitButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end
