//
//  UpdateUniqueTickersNSOperation.h
//  TickerTweet
//
//  Created by Dan Sullivan on 7/13/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TickerTweetAppDelegate.h"



@interface UpdateUniqueTickersNSOperation : NSOperation

@property (nonatomic, strong) NSMutableArray *twitterSearchResults;
@property (nonatomic, strong) NSMutableArray *uniqueQueue;

@property (nonatomic, strong) TickerTweetAppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;



@end
