//
//  TickerTweetAppDelegate.h
//  TickerTweet
//
//  Created by Dan Sullivan on 4/4/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TickerTweetAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
