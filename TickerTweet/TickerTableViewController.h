//
//  TickerTableViewController.h
//  TickerTweet
//
//  Created by Dan Sullivan on 4/6/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIScrollView.h>
#import <TickerTweetAppDelegate.h>
#import "Ticker.h"

@interface TickerTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    NSFetchedResultsController *searchFetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, assign) int deleteCounter;
@property (nonatomic, retain) UISearchDisplayController *mySearchDisplayController;


@property (nonatomic, strong) TickerTweetAppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) NSNotificationCenter *nc;

@property (nonatomic, retain) Ticker* managedTicker;


@end
