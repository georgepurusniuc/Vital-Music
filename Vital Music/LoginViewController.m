//
//  LoginViewController.m
//  Vital Music
//
//  Created by George Purusniuc on 01/06/14.
//  Copyright (c) 2014 George Purusniuc. All rights reserved.
//

#import "LoginViewController.h"
#import <UPPlatformSDK/UPPlatformSDK.h>

// OAuth keys.
NSString *const kAPIExplorerID = @"3ZYR1YjGd3Q";
NSString *const kAPIExplorerSecret = @"4dd5b10b3a3a16dbf3082c86d5faff09e11a682b";


@interface LoginViewController ()

@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Give us a detailed network activity overview.
    [UPPlatform sharedPlatform].enableNetworkLogging = YES;
    
    // Check if we have an outstanding session.
    [[UPPlatform sharedPlatform] validateSessionWithCompletion:^(UPSession *session, NSError *error) {
		if (session != nil) {
            [self.navigationController pushViewController:[PlaylistViewController new] animated:YES];
		}
	}];
}

- (IBAction)didTapLogin:(UIButton *)sender {
    
    sender.enabled = NO;
	
	// Present login screen in a UIWebView.
	[[UPPlatform sharedPlatform] startSessionWithClientID:kAPIExplorerID
                                             clientSecret:kAPIExplorerSecret
                                                authScope:UPPlatformAuthScopeAll
                                               completion:^(UPSession *session, NSError *error) {
                                                   
                                                   sender.enabled = YES;
                                                   
                                                   if (session != nil) {
                                                       [self.navigationController pushViewController:[PlaylistViewController new] animated:YES];
                                                   } else {
                                                       [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                                   message:error.localizedDescription
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil] show];
                                                   }
                                               }];
}

@end
