//
//  WebViewController.h
//  TickerTweet
//
//  Created by Dan Sullivan on 6/3/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIWebView.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) NSString *URL;

@property (nonatomic, assign) BOOL doneLoaded;

@end
