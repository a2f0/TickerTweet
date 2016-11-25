//
//  TickerTableViewController.m
//  TickerTweet
//
//  Created by Dan Sullivan on 4/6/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import "TickerTableViewController.h"
#import "TickerTweetAppDelegate.h"
#import "TickerCell.h"
#import "Ticker.h"
#import "MWRootViewController.h"

#import "TweetieButtonUIButton.h"
#import "RSSButtonUIButton.h"
#import "TickerDetailUIButton.h"

#import "TickerDetailViewController.h"
#import "RootViewController.h"

#import "FavoriteButtonUIButton.h"

@interface TickerTableViewController ()

@end

@implementation TickerTableViewController


@synthesize searchFetchedResultsController;
@synthesize fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)hideKeyboard
{
    NSLog(@"On-screen drag detected.  Ending editing.");
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"***TickerTableViewControler is going to disappear***");
    [self.tableView setEditing:NO animated:NO];
    [self.view endEditing:YES];
}

- (void)otherContextDidSave:(NSNotification *)didSaveNotification {
    NSLog(@"***didSaveNotification sent to TickerTable***");
    [self.context mergeChangesFromContextDidSaveNotification:didSaveNotification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self.navigationController.navigationBar setTintColor:[UIColor grayColor]];
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [[NSManagedObjectContext alloc] init];
    [self.context setPersistentStoreCoordinator: [self.appDelegate persistentStoreCoordinator]];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(otherContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification object:nil];
    
    NSLog(@"Loading the ticker table view...");
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSLog(@"Preparing to perform fetch...");
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TickerCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"TickerCell"];
    
    
    NSLog(@"Symbol count: %d", [fetchedResultsController.fetchedObjects count]);
    NSLog(@"Search symbol count: %d", [searchFetchedResultsController.fetchedObjects count]);

    self.deleteCounter = 0;
    
    NSLog(@"Adding search bar...");
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0)];
    searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tableView.tableHeaderView = searchBar;
    
    [searchBar setTintColor:[UIColor grayColor]];
    
    self.mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
    
    NSLog(@"Finished adding search bar...");
 }



-(void)viewWillAppear:(BOOL)animated  {
    NSLog(@"TickerTableViewController will appear...");
   
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"walltweetfontbanner_lightgray-320x44.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"walltweetfontbanner_lightgray-320x44.png"] forBarMetrics:UIBarMetricsDefault];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"******Viewdidappear******");

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

-(IBAction)rssPressed:(RSSButtonUIButton*)sender
{
    NSLog(@"Pressed RSS for ticker %ld", (long)sender.tag);
    
    NSFetchedResultsController *nsfrc = [self fetchedResultsControllerForTableView:sender.tableView];
    
    NSIndexPath *path;
    if (sender.tag > self.deleteCounter) {
        path = [NSIndexPath indexPathForRow:(sender.tag - self.deleteCounter) inSection:0];
    }
    else {
        path = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    }
    
    Ticker *ticker = [nsfrc objectAtIndexPath:path];

    NSLog(@"Pressed RSS for ticker %@", ticker.symbol);
    
    MWRootViewController* rssftvc = [[MWRootViewController alloc] init];
    rssftvc.tickerSymbol = [ticker.symbol substringFromIndex:1];
    [self.navigationController pushViewController:rssftvc animated:YES];
}

-(IBAction)tweetiePressed:(TweetieButtonUIButton*)sender
{
    
    NSFetchedResultsController *nsfrc = [self fetchedResultsControllerForTableView:sender.tableView];    
    NSIndexPath *path;
    if (sender.tag > self.deleteCounter) {
        path = [NSIndexPath indexPathForRow:(sender.tag - self.deleteCounter) inSection:0];
    }
    else {
        path = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    }
    
    Ticker *ticker = [nsfrc objectAtIndexPath:path];
    
    NSLog(@"Pressed RSS for ticker %@", ticker.symbol);
    
    RootViewController *rvc = [[RootViewController alloc] init];
    
    rvc.searchQuery = ticker.symbol;
    rvc.single_tweet = TRUE;
    rvc.self.title = [ticker.symbol substringFromIndex:1];
    rvc.searchType = @"Single";
    [self.navigationController pushViewController:rvc animated:YES];
}

-(IBAction)wallTweetiePressed:(RSSButtonUIButton*)sender
{
    NSLog(@"Pressed RSS for ticker %ld", (long)sender.tag);
    
    NSFetchedResultsController *nsfrc = [self fetchedResultsControllerForTableView:sender.tableView];
    
    NSIndexPath *path;
    if (sender.tag > self.deleteCounter) {
        path = [NSIndexPath indexPathForRow:(sender.tag - self.deleteCounter) inSection:0];
    }
    else {
        path = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    }
    
    Ticker *ticker = [nsfrc objectAtIndexPath:path];
    
    NSLog(@"Pressed walltweetie for ticker %@", ticker.symbol);
    
    TickerDetailViewController * tdvc = [[TickerDetailViewController alloc] init];
    tdvc.tickerSymbol = [ticker.symbol substringFromIndex:1];;
    [self.navigationController pushViewController:tdvc animated:YES];
}

-(IBAction)toggleStarPressed:(FavoriteButtonUIButton*)sender
{
    
    NSLog(@"toggleStarPressed for ticker %ld", (long)sender.tag);
    
    NSFetchedResultsController *nsfrc = [self fetchedResultsControllerForTableView:sender.tableView];
    
    NSIndexPath *path;
    if (sender.tag > self.deleteCounter) {
        path = [NSIndexPath indexPathForRow:(sender.tag - self.deleteCounter) inSection:0];
    }
    else {
        path = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    }
    
    Ticker *ticker = [nsfrc objectAtIndexPath:path];

    NSLog(@"Pressed toggleStarPressed for ticker %@", ticker.symbol);
    
    if ([ticker.isFavorite intValue] == [[NSNumber numberWithBool:NO] intValue]) {
        NSLog(@"The ticker is currently not a favorite, setting it to yes.");
        ticker.isFavorite = [NSNumber numberWithBool:YES];
        [self.context save:nil];
        [sender.tableView reloadData];
    } else if ([ticker.isFavorite  intValue] == [[NSNumber numberWithBool:YES] intValue]){
        NSLog(@"The ticker currently is a favorite, setting it to no.");
        ticker.isFavorite = [NSNumber numberWithBool:NO];
        [self.context save:nil];
        [sender.tableView reloadData];
    } else {
        NSLog(@"This should never happen");
    }

}


- (void)configureCell:(TickerCell*)tickerCell atIndexPath:(NSIndexPath*)indexPath {
    NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
	
    NSString* symbol = [[NSString alloc] initWithString:[[managedObject valueForKey:@"symbol"] description]];

    tickerCell.tickerLabel.text = [symbol substringFromIndex:1];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error = nil;
		if (![self.context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);
		}
	}
}

//Delegate methods for the search bar
#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    NSLog(@"Filtercontent was called with searchText:  %@", searchText);
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}


- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    NSLog(@"searchDisplayController was called.");
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"Shouldreloadforsearchstring:%@", searchString);
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSLog(@"search string: %@",[self.searchDisplayController.searchBar text]);
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    return YES;
}

//FRC Creation Code.  This is hardcore.
- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSLog(@"Creating NSFetchedResultsController with search string: %@", searchString);
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"symbol!=nil AND symbol!=''"];    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Ticker"
                inManagedObjectContext:self.context];
	[fetchRequest setEntity:entityDesc];
	
	//Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"symbol" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setEntity:entityDesc];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    
    NSLog(@"Creating NSFetchedResultsController with search string: %@", searchString);
    
    if(searchString.length)
    {
        NSLog(@"Adding search string to predicate array");
        // your search predicate(s) are added to this array
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"symbol CONTAINS[cd] %@", searchString]];
        // finally add the filter predicate for this view
        
        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
    } else {
        NSLog(@"Search string not present");
    }
    
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.context
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    if (![aFetchedResultsController performFetch:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSLog(@"returning a Fetched count of %d from newFetchedResultsconntrollerFromSearch.", [aFetchedResultsController.fetchedObjects count]);
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    NSLog(@"called fetchedresults controller");
    if (fetchedResultsController != nil)
    {
        return fetchedResultsController;
    } else {
    }
    fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    return fetchedResultsController;

}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (searchFetchedResultsController != nil)
    {
        return searchFetchedResultsController;
    } else {
        searchFetchedResultsController = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
        return searchFetchedResultsController;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"Controller is going to change content");
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    NSLog(@"some sort of change detected");
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)theIndexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    NSLog(@"Something was updated...");
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //[self fetchedResultsController:controller configureCell:(TickerCell*)[tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
            [self configureCell:(TickerCell*)[self.tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"Controller Did Change Content Starting...");
    UITableView *tableView =
    controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
    //[tableView reloadData];
    NSLog(@"Controller Did Change Contentet Ended......");
}


- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TickerCell";

    [tableView registerNib:[UINib nibWithNibName:@"TickerCell"
                                          bundle:[NSBundle mainBundle]]
    forCellReuseIdentifier:@"TickerCell"];
    
    TickerCell *tickerCell = (TickerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [tickerCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Ticker *ticker = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
   
    NSLog(@"Assigning Ticker: %@",[ticker.symbol substringFromIndex:1] );

    NSInteger rightMargin = 10;
    
    tickerCell.shouldIndentWhileEditing = NO;
    
    UIImage *img = [UIImage imageNamed:@"purple_rss-39x39.png"];
    RSSButtonUIButton *aButton = [RSSButtonUIButton buttonWithType:UIButtonTypeCustom];
    aButton.tableView = tableView;
    [aButton setImage:img forState:UIControlStateNormal];
    [aButton addTarget:self
                action:@selector(rssPressed:)
      forControlEvents:UIControlEventTouchDown];
    aButton.tag = indexPath.item;
    aButton.frame = CGRectMake(self.view.frame.size.width-img.size.width - rightMargin, 0, 44, 44);
    [tickerCell.contentView addSubview:aButton];
    
    UIImage *img2 = [UIImage imageNamed:@"twitter_bird-39x39.png"];
    TweetieButtonUIButton *aButton2 = [TweetieButtonUIButton buttonWithType:UIButtonTypeCustom];
    aButton2.tableView = tableView;
    [aButton2 setImage:img2 forState:UIControlStateNormal];
    [aButton2 addTarget:self
                 action:@selector(tweetiePressed:)
       forControlEvents:UIControlEventTouchDown];
    aButton2.tag = indexPath.item;
    aButton2.frame = CGRectMake(aButton.frame.origin.x - aButton.frame.size.width, 0, 44, 44);
    [tickerCell.contentView addSubview:aButton2];
    
    UIImage *img3 = [UIImage imageNamed:@"walltweetie_turquois39x39.png"];
    TickerDetailUIButton *aButton3 = [TickerDetailUIButton buttonWithType:UIButtonTypeCustom];
    aButton3.tableView = tableView;
    [aButton3 setImage:img3 forState:UIControlStateNormal];
    [aButton3 addTarget:self
                 action:@selector(wallTweetiePressed:)
       forControlEvents:UIControlEventTouchDown];
    aButton3.tag = indexPath.item;
    aButton3.frame = CGRectMake(0, 0, 44, 44);
    [tickerCell.contentView addSubview:aButton3];
    
    NSLog(@"isFavorite: %@", ticker.isFavorite);
    UIImage *img4 = [[UIImage alloc] init];
    if ( [ticker.isFavorite  intValue] == [[NSNumber numberWithBool:NO] intValue]) {
        NSLog(@"It is not a favorite.");
        img4 = [UIImage imageNamed:@"purple_star-39x39"];
    } else if ([ticker.isFavorite  intValue] == [[NSNumber numberWithBool:YES] intValue]) {
        NSLog(@"It is a favorite.");
        img4 = [UIImage imageNamed:@"purple_star-39x39-filled.png"];
    } else {
        NSLog(@"This shouldn't happen");
    }
    FavoriteButtonUIButton *aButton4 = [FavoriteButtonUIButton buttonWithType:UIButtonTypeCustom];
    aButton4.tableView = tableView;
    [aButton4 setImage:img4 forState:UIControlStateNormal];
    [aButton4 addTarget:self
                 action:@selector(toggleStarPressed:)
       forControlEvents:UIControlEventTouchDown];
    aButton4.tag = indexPath.item;
    aButton4.frame = CGRectMake(aButton3.frame.origin.x + aButton2.frame.size.width, 0, 44, 44);
    [tickerCell.contentView addSubview:aButton4];
    
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:tickerCell atIndexPath:indexPath];
    
    return tickerCell;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)localFetchedResultsController configureCell:(TickerCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
    NSLog(@"ConfigureCell called");
    
    //Pull the object from the fetched results controller
    NSManagedObject *managedObject = [localFetchedResultsController objectAtIndexPath:theIndexPath];
	
    //Extract the name string
    NSString* symbol = [[NSString alloc] initWithString:[[managedObject valueForKey:@"symbol"] description]];

    NSLog(@"Configuring it local");
    theCell.tickerLabel.text = [symbol substringFromIndex:1];
    theCell.tickerLabel.textColor = [UIColor grayColor];
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    NSLog(@"Edit button clicked.");
}


- (void)dealloc {
    NSLog(@"deallocating TickerTableViewController");
}

@end