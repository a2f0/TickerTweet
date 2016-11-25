//
//  TickerTweetTabBarController.m
//  TickerTweet
//
//  Created by Dan Sullivan on 4/6/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import "TickerTweetTabBarController.h"
#import "TickerTweetAppDelegate.h"
#import "Ticker.h"
#import "TickerTableViewController.h"

@interface TickerTweetTabBarController ()

@end

@implementation TickerTweetTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    NSLog(@"Setting selected index of Tab Bar Controller");
    [self.tabBarController setSelectedIndex:4];

    //Pull the existing userdefault
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Extract the initialLaunch setting
    NSString *initialLaunch = [defaults stringForKey:@"Initial Launch"];
    NSLog(@"Inital Launch: %@", initialLaunch);
    
    //Check if the initialLaunch is nil
    if ( initialLaunch == nil)
    {
        NSLog(@"This is the first time the app has launched, setting the value.");
        
        //Configure a dateFormatter, set a date string.
        NSDateFormatter *formatter;
        NSString        *dateString;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
        dateString = [formatter stringFromDate:[NSDate date]];
        
        //Write the setting
        [defaults setObject:dateString forKey:@"Initial Launch"];
        [defaults synchronize];
        
        //Do the default data load
        [self sampleLoad];
        
    }
    else
    {
        NSLog(@"This not is the first time the app has launched.");
    }
    
    
}

-(void)sampleLoad {
    NSLog(@"Loading default sample data...");
    
    TickerTweetAppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSError *error;
    
    Ticker *newTicker = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Ticker"
                         inManagedObjectContext:context];
    [newTicker setValue: @"$AAPL" forKey:@"symbol"];
    [newTicker setValue:[NSNumber numberWithBool:YES] forKey:@"isFavorite"];

    newTicker = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Ticker"
                         inManagedObjectContext:context];
    [newTicker setValue: @"$FB" forKey:@"symbol"];
    [newTicker setValue:[NSNumber numberWithBool:NO] forKey:@"isFavorite"];
    
    newTicker = [NSEntityDescription
                 insertNewObjectForEntityForName:@"Ticker"
                 inManagedObjectContext:context];
    [newTicker setValue: @"$GOOG" forKey:@"symbol"];
    [newTicker setValue:[NSNumber numberWithBool:NO] forKey:@"isFavorite"];
    
    newTicker = [NSEntityDescription
                 insertNewObjectForEntityForName:@"Ticker"
                 inManagedObjectContext:context];
    [newTicker setValue: @"$AMZN" forKey:@"symbol"];
    [newTicker setValue:[NSNumber numberWithBool:NO] forKey:@"isFavorite"];

    newTicker = [NSEntityDescription
                 insertNewObjectForEntityForName:@"Ticker"
                 inManagedObjectContext:context];
    [newTicker setValue: @"$YHOO" forKey:@"symbol"];
    [newTicker setValue:[NSNumber numberWithBool:NO] forKey:@"isFavorite"];
    
    [context save:&error];
    NSLog(@"Finished saving default sample data...");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchTickers
{
    NSLog(@"Fetching tickers...");
    
    TickerTweetAppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Ticker"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    NSMutableArray *incidents = [NSMutableArray arrayWithArray:objects];
    
    NSLog(@"Tickers count: %d", [incidents count]);
}

@end
