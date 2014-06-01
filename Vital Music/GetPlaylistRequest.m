//
//  GetPlaylistRequest.m
//  Vital Music
//
//  Created by George Purusniuc on 01/06/14.
//  Copyright (c) 2014 George Purusniuc. All rights reserved.
//

#import "GetPlaylistRequest.h"

@implementation GetPlaylistRequest

+ (instancetype)requestWithMood:(NSString *)mood {
    GetPlaylistRequest *instance = [self new];
    instance.mood = mood;
    
    return instance;
}

- (NSString *)requestURL {
    return [NSString stringWithFormat:@"music/%@", self.mood];
}

- (id)successData:(NSArray *)data {
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *dict in data) {
        Song *song = [Song new];
        song.artworkUrl = dict[@"artwork_url"];
        song.streamUrl = dict[@"stream_url"];
        song.title = dict[@"title"];
        [result addObject:song];
    }
    return result;
}

@end
