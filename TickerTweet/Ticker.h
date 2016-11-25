//
//  Ticker.h
//  TickerTweet
//
//  Created by Dan Sullivan on 7/15/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Ticker : NSManagedObject

@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSNumber * ignore;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * symbol;

@end
