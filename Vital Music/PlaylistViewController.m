//
//  LoginViewController.m
//  Vital Music
//
//  Created by George Purusniuc on 31/05/14.
//  Copyright (c) 2014 George Purusniuc. All rights reserved.
//

#import "PlaylistViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Song.h"
#import "CustomCell.h"
#import "CheckRequest.h"

@interface PlaylistViewController ()

@property (strong, nonatomic) NSMutableArray *songsList;
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property int moodNumber;
@property int currentSongIndex;
@property int checkIndex;

@end

@implementation PlaylistViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.moodNumber = -1;
    self.checkIndex = -1;
    UINib *nib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cellIdentifier"];
    
    self.songsList = [NSMutableArray new];
    self.audioPlayer = [[AVPlayer alloc] init];
    
    [self configurePlayer];
    
    [self checkForPlaylistChange];
}

- (void)getPlaylistForMood:(NSString *)mood autoplay:(BOOL)autoplay {
    self.moodNumber = [mood intValue];
    GetPlaylistRequest *request = [GetPlaylistRequest requestWithMood:mood];
    [request runRequest];
    
    [request setSuccess:^(id request, id response) {
        self.songsList = response;
        [self.tableView reloadData];
        if (autoplay) {
            [self playSongForIndex:0];
        }
        
    }];
}

- (IBAction)didTapTogglePlayPauseButton:(id)sender {
    if(self.togglePlayPauseButton.selected) {
        [self.audioPlayer pause];
        [self.togglePlayPauseButton setSelected:NO];
    } else {
        [self.audioPlayer play];
        [self.togglePlayPauseButton setSelected:YES];
    }
}

- (IBAction)switchValueChanged:(UISegmentedControl *)sender {
    [self getPlaylistForMood:[NSString stringWithFormat:@"%ld", (long)sender.selectedSegmentIndex + 1] autoplay:NO];
}

-(void) configurePlayer {

    __block PlaylistViewController * weakSelf = self;

    [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                   queue:NULL
                                              usingBlock:^(CMTime time) {
                                                  if(!time.value) {
                                                      return;
                                                  }
                                                  
                                                  int currentTime = (int)CMTimeGetSeconds(weakSelf.audioPlayer.currentItem.currentTime);
                                                  int currentMins = (int)(currentTime/60);
                                                  int currentSec  = (int)(currentTime%60);
                                                  
                                                  float duration = CMTimeGetSeconds(weakSelf.audioPlayer.currentItem.duration);
                                                  int totalMins = (int)((int)duration/60);
                                                  int totalSec  = (int)((int)duration%60);
                                                  
                                                  NSString *durationText = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d",
                                                                            currentMins,
                                                                            currentSec,
                                                                            totalMins,
                                                                            totalSec
                                                                            ];
                                                  weakSelf.durationOutlet.text = durationText;
                                                  weakSelf.progressView.progress = currentTime/duration;
                                              }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.songsList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    
    Song *song = self.songsList[indexPath.row];
    [cell populateWithSong:song];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)playSongForIndex:(int)index {
    Song *song = [self.songsList objectAtIndex:index];
    self.songName.text = song.title;
    NSURL* urlStream = [NSURL URLWithString:song.streamUrl];
    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:urlStream];
    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItem];
    
    
    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    [self.audioPlayer play];
    self.currentSongIndex = index;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.audioPlayer pause];
    [self.togglePlayPauseButton setSelected:YES];

    [self playSongForIndex:(int)indexPath.row];
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    if (self.currentSongIndex + 1 >= [self.songsList count]) {
        [self playSongForIndex:0];
    } else {
        [self playSongForIndex:self.currentSongIndex + 1];
    }
}


- (void)checkForPlaylistChange {
    CheckRequest *request = [CheckRequest request];
    request.showsProgressIndicator = NO;
    [request runRequest];
    
    [request setSuccess:^(id request, NSArray *response) {
        NSDictionary *dict = response[0];
        int playlistId = [dict[@"playlist_id"] intValue];
        
        if (self.checkIndex == -1) {
            self.checkIndex = playlistId;
            self.segmentControl.selectedSegmentIndex = playlistId - 1;
            [self getPlaylistForMood:[NSString stringWithFormat:@"%d", playlistId] autoplay:NO];
            [self performSelector:@selector(checkForPlaylistChange)
                       withObject:nil
                       afterDelay:10];
            return;
        } else {
            if (playlistId == self.moodNumber) {
                self.checkIndex = playlistId;
            } else {
                if (playlistId != self.checkIndex) {
                    self.checkIndex = playlistId;
                    self.segmentControl.selectedSegmentIndex = playlistId - 1;
                    [self getPlaylistForMood:[NSString stringWithFormat:@"%d", playlistId] autoplay:YES];
                    [self performSelector:@selector(checkForPlaylistChange)
                               withObject:nil
                               afterDelay:10];
                }
            }
        }
        
        [self performSelector:@selector(checkForPlaylistChange)
                   withObject:nil
                   afterDelay:10];
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
//        
//        
//        NSLog(@"%d", playlistId);
//        if (self.checkIndex == -1) {
//            NSLog(@"A");
//            self.checkIndex = playlistId;
//        } else {
//            if (self.checkIndex == playlistId) {
//                NSLog(@"B");
//                [self performSelector:@selector(checkForPlaylistChange)
//                           withObject:nil
//                           afterDelay:10];
//                return;
//            }
//        }
//        self.segmentControl.selectedSegmentIndex = playlistId - 1;
//        NSLog(@"C");
//        if (self.moodNumber == -1) {
//            NSLog(@"E");
//            [self getPlaylistForMood:[NSString stringWithFormat:@"%d", playlistId] autoplay:NO];
//            self.moodNumber = playlistId;
//        } else if (playlistId != self.moodNumber) {
//            NSLog(@"D");
//            [self getPlaylistForMood:[NSString stringWithFormat:@"%d", playlistId] autoplay:YES];
//            self.moodNumber = playlistId;
//        }
//        
//        NSLog(@"%d %d %d", playlistId, self.checkIndex, self.moodNumber);
//        
//        [self performSelector:@selector(checkForPlaylistChange)
//                   withObject:nil
//                   afterDelay:10];
    }];
}

@end
