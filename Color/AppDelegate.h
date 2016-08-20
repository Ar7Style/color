//
//  AppDelegate.h
//  Color
//
//  Created by Tareyev Gregory on 11.06.16.
//  Copyright © 2016 Tareyev Gregory. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
#import <GoogleSignIn/GoogleSignIn.h>
#import "EventManager.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) EventManager *eventManager;


@end

