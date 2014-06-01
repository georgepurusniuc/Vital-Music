//
//  CustomCell.m
//  Vital Music
//
//  Created by George Purusniuc on 01/06/14.
//  Copyright (c) 2014 George Purusniuc. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (void)populateWithSong:(Song *)song {
    if (song.artworkUrl && ![song.artworkUrl isKindOfClass:[NSNull class]]) {
        [self.artworkImageView setImageWithURL:[NSURL URLWithString:song.artworkUrl]];
    }
    
    self.titleLabel.text = song.title;
}


@end
