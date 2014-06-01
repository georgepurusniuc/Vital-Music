//
//  Song.h
//  Vital Music
//
//  Created by George Purusniuc on 01/06/14.
//  Copyright (c) 2014 George Purusniuc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject

@property (strong, nonatomic) NSString *artworkUrl;
@property (strong, nonatomic) NSString *streamUrl;
@property (strong, nonatomic) NSString *title;

@end
