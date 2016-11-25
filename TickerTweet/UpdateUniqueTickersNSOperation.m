//
//  UpdateUniqueTickersNSOperation.m
//  TickerTweet
//
//  Created by Dan Sullivan on 7/13/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import "UpdateUniqueTickersNSOperation.h"
#import "TickerTweetAppDelegate.h"
#import "TIcker.h"

@implementation UpdateUniqueTickersNSOperation

- (void)main {
    @autoreleasepool {
        self.uniqueQueue = [[ NSMutableArray alloc ] init];
        self.appDelegate = [[UIApplication sharedApplication] delegate];
        self.context = [[NSManagedObjectContext alloc] init];
        [self.context setPersistentStoreCoordinator: [self.appDelegate persistentStoreCoordinator]];
        
        //This is to generate notifications
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(mergeChanges:)
                   name:NSManagedObjectContextDidSaveNotification
                 object:self.context];
        
        for (NSDictionary *tweet in self.twitterSearchResults) {
            NSString *tweetText = [tweet valueForKey:@"text"];
            NSArray *array = [tweetText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            for (NSMutableString *token in array) {
                if([token hasPrefix:@"$"]) {
                    if([token length] > 1 && [token length] < 6) {
                        NSCharacterSet *alphaSet = [NSCharacterSet uppercaseLetterCharacterSet];
                        if ([[[token substringFromIndex:1] stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""])
                        {
                            //If all criteria are met, we know this is a valid ticker.  Add it to the array.
                            [self.uniqueQueue insertObject:token atIndex:0];
                        }
                    }
                }
            }
        }
        for (NSString *individualTicker in self.uniqueQueue){
            //NSLog(@"processing %@", individualTicker);
            
            if ([self tickerExistsAlready:individualTicker]) {
                //NSLog(@"it exists already: %@", individualTicker);
            } else {
                //NSLog(@"it doesnt exist");
                [self addTicker:individualTicker];
            }
        }
    }
}

-(BOOL)tickerExistsAlready:(NSString *)symbol {
    
    //Set the entity of the search
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Ticker"
                inManagedObjectContext:self.context];
    
    //initialize a fetch request and set the
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    //Set the entity description
    [request setEntity:entityDesc];
    
    
    //Define a search predicate for the search, set it to the value of the text box
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(symbol = %@)", symbol];
    [request setPredicate:pred];
    
    //instantiate an error
    NSError *error;
    
    //Execute the fetch request, have it return objects
    NSArray *objects = [self.context executeFetchRequest:request
                                              error:&error];
    
    //If a match was found, return YES, if not, NO.
    if ([objects count] == 0) {
        //NSLog(@"Object count was 0");
        return NO;
    } else {
        //NSLog(@"Object count was %d", [objects count]);
        return YES;
    }
}


-(void)addTicker:(NSString *)symbol {
            
    NSError *error;
    
    Ticker *newTicker = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Ticker"
                         inManagedObjectContext:self.context];
    [newTicker setValue:symbol forKey:@"symbol"];
    [newTicker setValue:[NSNumber numberWithBool:NO] forKey:@"isFavorite"];
    [self.context save:&error];
    NSLog(@"Added new ticker: %@", symbol);
}


- (void)mergeChanges:(NSNotification *)notification
{
    NSLog(@"Merge changes called from NSOperation");
    // Merge changes into the main context on the main thread
    [self.context performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification
                               waitUntilDone:YES];
}

@end
