//
//  AppDelegate.h
//  Vital Music
//
//  Created by George Purusniuc on 31/05/14.
//  Copyright (c) 2014 George Purusniuc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) LoginViewController *loginViewController;

@end
