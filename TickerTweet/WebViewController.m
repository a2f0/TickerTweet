//
//  WebViewController.m
//  TickerTweet
//
//  Created by Dan Sullivan on 6/3/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

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
    self.doneLoaded = false;
   
    NSURL *url = [NSURL URLWithString:self.URL];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    webView.scalesPageToFit = TRUE;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSLog(@"Finished loading URL.");
                               if ([data length] > 0 && error == nil) [webView loadRequest:request];
                               else if (error != nil) NSLog(@"Error: %@", error);
                           }];
     [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)viewWillAppear:(BOOL)animated   {
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

@end
