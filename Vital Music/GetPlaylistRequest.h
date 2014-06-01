//
//  GetPlaylistRequest.h
//  Vital Music
//
//  Created by George Purusniuc on 01/06/14.
//  Copyright (c) 2014 George Purusniuc. All rights reserved.
//

#import "BaseRequest.h"
#import "Song.h"

@interface GetPlaylistRequest : BaseRequest

@property (strong, nonatomic) NSString *mood;

+ (instancetype)requestWithMood:(NSString *)mood;

@end
