// RootViewController.h
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import <Social/SLRequest.h>
#import <Twitter/TWRequest.h>
#import <Accounts/Accounts.h>
#import "TickerTweetAppDelegate.h"

@interface RootViewController : UITableViewController <TTTAttributedLabelDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate> {
    
    //NSArray *_espressos;
    
    NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *context;
}

//@property (nonatomic) NSArray *espressos;


@property (nonatomic, strong) NSMutableArray *twitterSearchResults;
@property (nonatomic, strong) NSURLConnection *twitterConnection;
@property (nonatomic, strong) NSMutableData *myData;
@property int processedTweetCount;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *context;

//@property (nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;
@property (nonatomic, strong) NSString *searchQuery;

//Whether or not we are generating a query string  (i.e. should we search on a single tweet).
@property (nonatomic, assign) BOOL single_tweet;
@property (nonatomic, assign) BOOL favorites;


@property (nonatomic, strong) NSString *searchType;

@property (nonatomic, assign) long long earliest_id;

//@property (nonatomic, strong) NSMutableArray *uniqueQueue;

@property (nonatomic, strong) NSOperationQueue *myUpdateQueue;

@property (nonatomic, strong) TickerTweetAppDelegate *appDelegate;
//@property (nonatomic, strong) NSManagedObjectContext *context;

@end
