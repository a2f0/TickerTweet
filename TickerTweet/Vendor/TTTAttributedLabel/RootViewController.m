// RootViewController.m
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

#import "RootViewController.h"
#import "AttributedTableViewCell.h"
#import "Ticker.h"
#import "TickerTweetAppDelegate.h"
#import "TickerDetailViewController.h"
#import "AppInfoViewController.h"
#import "UpdateUniqueTickersNSOperation.h"

@implementation RootViewController
@synthesize context;

//@synthesize espressos = _espressos;

@synthesize fetchedResultsController;
//@synthesize managedObjectContext;
@synthesize searchQuery;

/*
- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (!self) {
        return nil;
    }
    
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"espressos" ofType:@"txt"];
    //self.espressos = [[NSString stringWithContentsOfFile:filePath usedEncoding:nil error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    return self;
}
*/



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.earliest_id = LLONG_MAX;
    self.processedTweetCount = 0;
    
    //self.title = NSLocalizedString(@"Tweets", nil);
    
    [self.navigationController.navigationBar setTintColor:[UIColor grayColor]];
    //[self.navigation.tintColor = [UIColor grayColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"TweetCell"];
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    //self.context = [self.appDelegate managedObjectContext];
    self.context = [[NSManagedObjectContext alloc] init];
    [self.context setPersistentStoreCoordinator: [self.appDelegate persistentStoreCoordinator]];
    //Here it is.
    
    //self.addingManagedObjectContext = [[NSManagedObjectContext alloc] init];
    //[self.addingManagedObjectContext setPersistentStoreCoordinator: [self.appDelegate persistentStoreCoordinator]];
    
    [self setRandomQueryString];
    [self customSearch];
    [self initButton];
    [self.navigationController setNavigationBarHidden:NO];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self
                action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    //self.uniqueQueue = [[ NSMutableArray alloc ] init];
    
    //UpdateUniqueTickersNSOperation *updateUniqueTickers = [[UpdateUniqueTickersNSOperation alloc] init];
    //[updateUniqueTickers start];
    
    self.myUpdateQueue = [[NSOperationQueue alloc] init];
    self.myUpdateQueue.name = @"Unique ticker update queue.";
    self.myUpdateQueue.MaxConcurrentOperationCount = 1;
    NSLog(@"updateQueue: %@", self.myUpdateQueue);
    //[self.myUpdateQueue start];
    
    //Ok, this actually works.
    NSLog(@"**********");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(otherContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)otherContextDidSave:(NSNotification *)didSaveNotification {
    NSLog(@"***didSaveNotification sent to RootViewControlle***");
    //NSLog(@"notifiction: %@", didSaveNotification);
    [self.context mergeChangesFromContextDidSaveNotification:didSaveNotification];
    //NSManagedObjectContext *context = (NSManagedObjectContext *)didSaveNotification.object;
    /*
    if( context.persistentStoreCoordinator == globalContext.persistentStoreCoordinator )
        [globalContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                        withObject:didSaveNotification waitUntilDone:NO];
    */
}


-(void)initButton
{
    if ([self.searchType isEqual: @"Favorites"]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [btn addTarget:self
                action:@selector(infoPressed:)
      forControlEvents:UIControlEventTouchDown];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}

-(IBAction)infoPressed:(id)sender
{
 //NSLog(@"Whatever.");
    
    //[self.navigationController setNavigationBarHidden:YES];
    //self.tabBarController.tabBar.hidden = YES;
    
    AppInfoViewController *aivc = [AppInfoViewController alloc];
    
    //Mass
    //[UIView beginAnimations:@"animation" context:nil];
    
    
    //[self.navigationController pushViewController: aivc animated:NO];
    //[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    //[UIView commitAnimations];
    //[self presentViewController:aivc animated:NO completion: nil];
    [self.tabBarController presentViewController:aivc animated:NO completion:nil];
    
    
}

-(void)viewWillAppear:(BOOL)animated  {
    NSLog(@"RootviewController will appear...");
    if ([self.searchType isEqual: @"Single"]) {
        self.title = nil;
         [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"walltweetfeed_banner320x44.png"] forBarMetrics:UIBarMetricsDefault];
    }else if ([self.searchType isEqual: @"Feed"]) {
        self.title = nil;
        //[self.navigationController.tabBarItem setTitle:@"Feed"];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"walltweetfeed_banner320x44.png"] forBarMetrics:UIBarMetricsDefault];
    }else if ([self.searchType isEqual: @"Favorites"]) {
        self.title = nil;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"walltweetfavorites_banner320x44.png"] forBarMetrics:UIBarMetricsDefault];
        //[self.navigationController.tabBarItem setTitle:@"Favorites"];
    } else  {
        self.title = self.searchType;
    }
    [self.tableView reloadData];
    
    NSLog(@"height: %f", self.navigationController.navigationBar.frame.size.height);
    NSLog(@"width: %f", self.navigationController.navigationBar.frame.size.width);
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return 3;
    return self.twitterSearchResults.count;
    //return [self.espressos count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //return [AttributedTableViewCell heightForCellWithText:[self.espressos objectAtIndex:indexPath.row]];
    
    NSDictionary *tweet = [self.twitterSearchResults objectAtIndex:indexPath.row];
    
    return [AttributedTableViewCell heightForCellWithText:[tweet objectForKey:@"text"]];
    
    //NSLog(@"Configuring a cell: %@", [tweet objectForKey:@"text"]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
    static NSString *CellIdentifier = @"Cell";
    AttributedTableViewCell *cell = (AttributedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AttributedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //NSString *description = [self.espressos objectAtIndex:indexPath.row];
    NSString *description = @"This is $APP hi $SEC";
    cell.summaryText = description;
    cell.summaryLabel.delegate = self;
    cell.summaryLabel.userInteractionEnabled = YES;
    return cell;
     */
    
    static NSString *CellIdentifier = @"Cell";
    AttributedTableViewCell *cell = (AttributedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AttributedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    NSDictionary *tweet = [self.twitterSearchResults objectAtIndex:indexPath.row];
    
    //NSLog(@"Tweet: %@", tweet);
    
    NSString *tweetID = [tweet objectForKey:@"id"];
    //NSLog(@"tweetID: %@", tweetID);
    
    long long lv = [tweetID longLongValue];
    
    //unsigned long long ullvalue = strtoull([tweetID UTF8String], NULL, 0);
    //NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    //NSNumber * myNumber = [f numberFromString:tweetID];
    
    //NSLog(@"longlong: %llu", lv);
    
    if (lv < self.earliest_id) {
        //NSLog(@"to: %lld", lv);
        //NSLog(@"fr: %lld", self.earliest_id);
        self.earliest_id = lv;
    } else {
        //NSLog(@"It wasn't greater");
    }
    
    //NSLog(@"earliest is now: %lld", lv);
    // NSLog(@"LLONG_MIN:  %lli", LLONG_MIN);   // signed long long int
    //NSLog(@"LLONG_MAX:  %lli", LLONG_MAX);
    
    //NSLog(@"ULLONG_MAX: %llu", ULLONG_MAX);
    
    //NSLog(@"EarliestID, %d", self.earliest_id);
    
    //NSLog(@"Configuring a cell: %@", [tweet objectForKey:@"text"]);
    cell.summaryText = [tweet objectForKey:@"text"];
    cell.summaryLabel.delegate = self;
    cell.summaryLabel.userInteractionEnabled = YES;
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *description = [self.espressos objectAtIndex:indexPath.row];
    //DetailViewController *viewController = [[DetailViewController alloc] initWithEspressoDescription:description];
    //[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil] showInView:self.view];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents; {
    NSLog(@"dictionary: %@", addressComponents);
    
    NSString *tickerToken = [addressComponents valueForKey:@"tickerName"];
    
    NSString *tickerOnly = [tickerToken substringFromIndex:1];

    NSLog(@"Ticker only: %@", tickerOnly);
    
    //NSLog(@"ticker: %@", tickerArray);
    //UIStoryboard *board = [UIStoryboard storyboardWithName:@"TickerTweet" bundle:nil];
    //NSLog(@"Here you go: %@", board);
    
    //TickerDetailViewController *tdvc = [board instantiateViewControllerWithIdentifier:@"TickerDetail"];
    TickerDetailViewController *tdvc = [TickerDetailViewController alloc];
    
    tdvc.tickerSymbol = tickerOnly;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.navigationController pushViewController:tdvc animated:YES];
    


}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
}

-(void)setRandomQueryString{
    
    if (self.single_tweet == TRUE) {
        return;
    }
    
    //[[[managedObjectsContext registeredObjects] allObjects] objectsAtIndex:r]
    
    NSLog(@"Regenerating query string...");
    
    /*
    TickerTweetAppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    */
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Ticker"
                inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    
    [request setEntity:entityDesc];
    
    if ([self.searchType isEqual: @"Favorites"]) {
        //[newTicker setValue:FALSE forKey:@"isFavorite"];
        NSLog(@"Adding search predicate for favorites");
        NSPredicate *favoritesFilter = [NSPredicate predicateWithFormat:@"isFavorite == TRUE"];
        [request setPredicate:favoritesFilter];
    }
    
    /*
     NSPredicate *pred =
     [NSPredicate predicateWithFormat:@"(name = %@)",
     _name.text];
     [request setPredicate:pred];
     */
    
    //NSManagedObject *matches = nil;
    
    NSError *error;
    NSArray *objects = [self.context executeFetchRequest:request
                                              error:&error];
    if ([objects count] == 0) {
        self.searchQuery=@"$AAPL";
    } else {
        //matches = objects[0];
        //_address.text = [matches valueForKey:@"address"];
        //_phone.text = [matches valueForKey:@"phone"];
        //_status.text = [NSString stringWithFormat:
        //                @"%d matches found", [objects count]];
        //self.searchQuery=@"";
        
        //NSLog(@"Object count: %d", [objects count]);
        //Generate 15 different tickers to query
        int randNum = rand() % ([objects count] - 0) + 0;
        //NSLog(@"Random index: %d", randNum);
        Ticker *ticker = [objects objectAtIndex: randNum];
        self.searchQuery = ticker.symbol;
        //NSLog(@"Going into loop with searchQuery as: %@",  self.searchQuery);
        for (int i = 1; i <= 10; i++)
        {
            //NSLog(@"%d", i);
            int randNum = rand() % ([objects count] - 0) + 0;
            //NSLog(@"Random index: %d", randNum);
            Ticker *ticker = [objects objectAtIndex: randNum];
            //NSLog(@"adding: %@", ticker.symbol);
            
            NSString *appendMe = [NSString stringWithFormat:@" OR %@", ticker.symbol];
            
            //NSLog(@"appending: %@", appendMe);
            
            self.searchQuery = [self.searchQuery stringByAppendingString:appendMe];
            
            
            //NSLog(@"after append: %@", self.searchQuery);
        }
        NSLog(@"self.searchQuery: %@", self.searchQuery);
    }
}

- (void)customSearch {
    NSLog(@"Launching custom search...");
    NSLog(@"Query string is: %@", self.searchQuery);
    
    NSString * mySearchQueryCopy = [self.searchQuery copy];
    
    
    
    //Reachability* reachability = [Reachability reachabilityWithHostName:@"api.twitter.com"];
    //NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    //if(remoteHostStatus == NotReachable) { NSLog(@"not reachable");}
    //else if (remoteHostStatus == ReachableViaWWAN) { NSLog(@"reachable via wwan");}
    //else if (remoteHostStatus == ReachableViaWiFi) { NSLog(@"reachable via wifi");}
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    NSDate *start = [NSDate date];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSLog(@"Starting this block");
    [account requestAccessToAccountsWithType:accountType
                                     options:nil completion:^(BOOL granted, NSError *error)
     {
         NSLog(@"Starting this block");
         if (granted == NO) {
             NSLog(@"Access was denied");
         }
         
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account
                                         accountsWithAccountType:accountType];
            
             if ([arrayOfAccounts count] == 0)
             {
                 NSLog(@"Access was denied");
             }
             
             
             if ([arrayOfAccounts count] > 0)
             {
                 ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                 
                 //NSLog(@"twitterAccount: %@", twitterAccount);
                 
                 /*
                  NSURL *requestURL = [NSURL URLWithString:@"http://api.twitter.com/1.1/statuses/home_timeline.json"];
                  NSMutableDictionary *parameters =
                  [[NSMutableDictionary alloc] init];
                  [parameters setObject:@"20" forKey:@"count"];
                  [parameters setObject:@"1" forKey:@"include_entities"];
                  */
                 
                 NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                 
                 NSMutableDictionary *parameters =
                 [[NSMutableDictionary alloc] init];
                 //[parameters setObject:@"$FB,$GOOG,$APPL,$AMZN,$FB" forKey:@"q"];
                 
                 //[parameters setObject:@"$FB OR $GOOG OR $MSFT OR $AMZN" forKey:@"q"];
                 
                 [parameters setObject:mySearchQueryCopy forKey:@"q"];
                 
                 if (self.single_tweet == TRUE || self.favorites == TRUE) {
                     NSString *myID = [NSString stringWithFormat:@"%lld", self.earliest_id];
                     [parameters setObject:myID forKey:@"max_id"];
                 }
                 
                 //http://stackoverflow.com/questions/11621211/twitter-ios-streaming-api-no-data-being-received
                 
                 
                 SLRequest *postRequest = [SLRequest
                                           requestForServiceType:SLServiceTypeTwitter
                                           requestMethod:SLRequestMethodGET
                                           URL:requestURL parameters:parameters];
                 
                 postRequest.account = twitterAccount;
                 NSLog(@"Posting HTTP request...");
                 [postRequest performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse
                    *urlResponse, NSError *error)
                  {
                      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                      NSLog(@"%@",[error localizedDescription]);
                      if (error) {
                          //[self presentError:error];
                          //return;
                      } else {
                          NSDictionary *results  = [NSJSONSerialization
                                                    JSONObjectWithData:responseData
                                                    options:NSJSONReadingMutableLeaves
                                                    error:&error];
                          //for(id key in results) {
                          //   NSLog(@"key=%@", key);
                          //   NSLog(@"key=%@ value=%@", key, [results objectForKey:key]);
                          //   NSLog(@"hi");
                          //}
                          
                          //NSLog(@"results: %@", results);
                          
                          //NSMutableArray *errors = [NSMutableArray arrayWithArray:[results objectForKey:@"errors"]];
                          
                          NSDictionary *errors = [NSMutableArray arrayWithArray:[results objectForKey:@"errors"]];
                          NSLog(@"errors: %@", errors);
                          NSLog(@"errors count: %lu", (unsigned long)[errors count]);
                          
                          //Process the errors if one was found.
                          if ([errors count] > 0)
                          {
                              NSLog(@"An error was found.");
                              for(NSDictionary *subArray in errors) {
                                  NSNumber *code = [subArray objectForKey:@"code"];
                                  NSString *message = [subArray objectForKey:@"message"];
                                  NSLog(@"Code: %@", code);
                                  NSLog(@"Message: %@", message);
                                  if ([code isEqualToNumber:[NSNumber numberWithInt:89]]) {
                                      NSLog(@"Check your authentication settings and try again");
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Credentials" message: @"Go into Setup and verify your Twitter account information" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                      [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                                      
                                  }
                              }
                          }
                          
                          //This code block works 100%
                          /*
                           NSArray *keys = [results allKeys];
                           for(id key in keys)                       {
                           NSLog(@"iterating %@", key);
                           id aValue = [results objectForKey: key];
                           if([aValue isKindOfClass:[NSDictionary class]]) {
                           NSLog(@"printed");
                           } else {
                           //NSLog(@"aValue %@", aValue);
                           for(NSDictionary *subArray in aValue) {
                           NSLog(@"Array in myArray: %@",subArray);
                           NSString *code = [subArray objectForKey:@"code"];
                           NSString *message = [subArray objectForKey:@"message"];
                           NSLog(@"Code: %@", code);
                           NSLog(@"Message: %@", message);
                           }
                           }
                           }
                           */
                          
                          //NSLog(@"Size of errors: %lu",(unsigned long)[errors count]);
                          
                          //NSString *errorString = [results objectForKey:@"errors"];
                          
                          //NSLog(@"errorString: %@", errorString);
                          
                          //NSLog(@"Errors: %@", errors);
                          
                          //NSMutableArray *myError = [[errors objectAtIndex:0] objectAtIndex:0];=
                          
                          self.twitterSearchResults = [NSMutableArray arrayWithArray:[results objectForKey:@"statuses"]];
                          
                          NSLog(@"Found %d tweets ", self.twitterSearchResults.count);
                          
                          //NSTimeInterval timeInterval = [start timeIntervalSinceNow];
                          
                          NSTimeInterval secondsElapsed = [[NSDate date] timeIntervalSinceDate:start];
                          
                          NSLog(@"Query execution: %f", secondsElapsed);
                          
                          //NSLog(@"%@", self.twitterFeed );
                          
                          //for(id status in self.twitterSearchResults) {
                          //NSLog(@"key: %@", key);
                          //NSLog(@"tweet: %@", [status objectForKey:@"text"]);
                          //NSLog(@"image_url: %@", [key objectForKey:@"profile_image_url"]);
                          //}
                          
                          
                          if (self.twitterSearchResults.count != 0) {
                              NSLog(@"dispatching reloadData...");
                              dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                              });
                              NSLog(@"dispatching updateUniqueTickers...");
                              
                              UpdateUniqueTickersNSOperation *updateTickersOperation = [[UpdateUniqueTickersNSOperation alloc] init];
                              updateTickersOperation.twitterSearchResults = self.twitterSearchResults;
                              [self.myUpdateQueue addOperation:updateTickersOperation];
                              
                              //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                              //  //[self updateUniqueTickersv2];
                              //});
                          }
                    
                      }
                  }];
             }
         } else {
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             NSLog(@"You don't have a twitter account configured..");
             //Handle failure to get account access
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Configure a Twitter Account" message: @"To pull tweets configure a Twitter account under you're iPhone's Settings" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
         }  
     }];
    
    //Get ready to do this again.
    NSLog(@"calling set random query string");
}


-(void)refreshView:(UIRefreshControl *)refresh {
    NSLog(@"Starting refreshView");
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    // custom refresh logic would be placed here...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    
    [self setRandomQueryString];
    [self customSearch];
    
    //NSLog(@"count of queue: %lu", (unsigned long)[self.uniqueQueue count]);
    //NSLog(@"queue: %@", self.uniqueQueue);
    
    [refresh endRefreshing];
    
    NSLog(@"Done with refreshView");
}

@end
