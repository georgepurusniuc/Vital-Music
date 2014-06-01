//
//  LoginViewController.h
//  Vital Music
//
//  Created by George Purusniuc on 31/05/14.
//  Copyright (c) 2014 George Purusniuc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetPlaylistRequest.h"

@interface PlaylistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *togglePlayPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *durationOutlet;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)didTapTogglePlayPauseButton:(id)sender;
- (IBAction)switchValueChanged:(id)sender;


@end
