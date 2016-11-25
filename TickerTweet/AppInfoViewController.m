//
//  AppInfoViewController.m
//  TickerTweet
//
//  Created by Dan Sullivan on 6/17/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import "AppInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+PXExtensions.h"

@interface AppInfoViewController ()

@end

@implementation AppInfoViewController

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
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.

}

-(void)viewWillAppear:(BOOL)animated{
    
    self.tabBarController.tabBar.hidden = YES;
    
    NSInteger creditsWidth = 300;
    NSInteger creditsTitleHeight = 25;
    NSInteger buttonWidth = 100;
    NSInteger startingHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    NSInteger lineWidth = 200;
    NSInteger spacing = 10;
    NSInteger topMargin = 25;
    UIColor *textColor = [UIColor grayColor];
    
    UIView* creditsView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - (creditsWidth/2),startingHeight,creditsWidth, [[UIScreen mainScreen] applicationFrame].size.height)];
    [creditsView setBackgroundColor:[UIColor whiteColor]];
            UILabel *credits = [[UILabel alloc] initWithFrame:CGRectMake((creditsView.bounds.size.width/2) - (creditsWidth/2),topMargin,creditsWidth,creditsTitleHeight)];
    credits.textColor = textColor;
    credits.font = [UIFont systemFontOfSize:20];
    credits.textAlignment = NSTextAlignmentCenter;
    credits.numberOfLines = 5;
    credits.text = @"WallTweet";
    [creditsView addSubview:credits];
    
    UILabel *conceptualization = [[UILabel alloc] initWithFrame:CGRectMake((creditsView.bounds.size.width/2) - (creditsWidth/2),credits.frame.origin.y + credits.frame.size.height + spacing,creditsWidth,creditsTitleHeight)];
    conceptualization.textColor = textColor;
    conceptualization.font = [UIFont systemFontOfSize:15];
    conceptualization.textAlignment = NSTextAlignmentCenter;
    conceptualization.numberOfLines = 0;
    conceptualization.text = @"Conceptualization:\nKevin Stephen";
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize expectedLabelSize = [conceptualization.text sizeWithFont:conceptualization.font constrainedToSize:maximumLabelSize lineBreakMode:conceptualization.lineBreakMode];
    CGRect newFrame = conceptualization.frame;
    newFrame.size.height = expectedLabelSize.height;
    conceptualization.frame = newFrame;
    [creditsView addSubview:conceptualization];
    
    UILabel *graphicdesign = [[UILabel alloc] initWithFrame:CGRectMake((creditsView.bounds.size.width/2) - (creditsWidth/2),conceptualization.frame.origin.y + conceptualization.frame.size.height + spacing,creditsWidth,creditsTitleHeight)];
    graphicdesign.textColor = textColor;
    graphicdesign.font = [UIFont systemFontOfSize:15];
    graphicdesign.textAlignment = NSTextAlignmentCenter;
    graphicdesign.numberOfLines = 0;
    graphicdesign.text = @"Graphic Design:\nChelsea Stephen\nhttp://leftpebble.com";
    maximumLabelSize = CGSizeMake(296, FLT_MAX);
    expectedLabelSize = [graphicdesign.text sizeWithFont:graphicdesign.font constrainedToSize:maximumLabelSize lineBreakMode:graphicdesign.lineBreakMode];
    newFrame = graphicdesign.frame;
    newFrame.size.height = expectedLabelSize.height;
    graphicdesign.frame = newFrame;
    [creditsView addSubview:graphicdesign];

    UILabel *developer = [[UILabel alloc] initWithFrame:CGRectMake((creditsView.bounds.size.width/2) - (creditsWidth/2),graphicdesign.frame.origin.y + graphicdesign.frame.size.height + spacing,creditsWidth,creditsTitleHeight)];
    developer.textColor = textColor;
    developer.font = [UIFont systemFontOfSize:15];
    developer.textAlignment = NSTextAlignmentCenter;
    developer.numberOfLines = 0;
    developer.text = @"Developer:\nDan Sullivan";
    maximumLabelSize = CGSizeMake(296, FLT_MAX);
    expectedLabelSize = [developer.text sizeWithFont:developer.font constrainedToSize:maximumLabelSize lineBreakMode:developer.lineBreakMode];
    newFrame = developer.frame;
    newFrame.size.height = expectedLabelSize.height;
    developer.frame = newFrame;
    [creditsView addSubview:developer];
    
    UILabel *shoutouts = [[UILabel alloc] initWithFrame:CGRectMake((creditsView.bounds.size.width/2) - (creditsWidth/2),developer.frame.origin.y + developer.frame.size.height + spacing,creditsWidth,creditsTitleHeight)];
    shoutouts.textColor = textColor;
    shoutouts.font = [UIFont systemFontOfSize:10];
    shoutouts.textAlignment = NSTextAlignmentCenter;
    shoutouts.numberOfLines = 0;
    shoutouts.text = @"Shout Outs:\nI would like to thank Mattt Thompson for writing TTTAttributedLabel, Byron Salau for UIColor+PXExtentions, Dave DeLong for CHCSVParser, Michael Waterfall for MWFeedParser, Google for GTMNSString+HTML.h, Yahoo and Twitter for their APIs, and the brilliant engineers at Apple Computer Corporation, for without these individuals this creation would not be possible.  I would also like to thank my parents, and say hello to my brothers Tim and John and my friend Nick Harris.";
    maximumLabelSize = CGSizeMake(296, FLT_MAX);
    expectedLabelSize = [shoutouts.text sizeWithFont:shoutouts.font constrainedToSize:maximumLabelSize lineBreakMode:shoutouts.lineBreakMode];
    newFrame = shoutouts.frame;
    newFrame.size.height = expectedLabelSize.height;
    shoutouts.frame = newFrame;
    [creditsView addSubview:shoutouts];
    
    UIColor *myButtonColor = [UIColor pxColorWithHexValue:@"#F000FF"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aButton.frame = CGRectMake((creditsView.bounds.size.width/2)-(buttonWidth/2),shoutouts.frame.origin.y + shoutouts.frame.size.height + spacing,buttonWidth,30);
    aButton.alpha = 0.0;
    [aButton setTitle:@"Ok" forState:UIControlStateNormal];
    [aButton addTarget:self action:@selector(buttonPushed) forControlEvents:UIControlEventTouchUpInside];
    [creditsView addSubview:aButton];
    [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    aButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [aButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
    [aButton setTitleColor:myButtonColor forState:UIControlStateNormal];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(-lineWidth*2, credits.frame.origin.y+credits.frame.size.height, lineWidth, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [creditsView addSubview:lineView];
    
    [self.view addSubview:creditsView];
    
    UIImage *img = [UIImage imageNamed:@"walltweet_birdonly_graypurptie43tall.png"];
    UIImageView *tweetieView = [[UIImageView alloc] init];
    [tweetieView setImage:img];
    tweetieView.frame = CGRectMake(225, -img.size.height, img.size.width, img.size.height);
    [self.view addSubview:tweetieView];
    
    [UIView animateWithDuration:.5 animations:^{
        creditsView.frame = CGRectMake((self.view.frame.size.width/2) - (creditsWidth/2),0,creditsWidth,[[UIScreen mainScreen] applicationFrame].size.height);
    }];

    [UIView animateWithDuration:.5
                          delay:1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         lineView.frame = CGRectMake((creditsView.bounds.size.width/2) - (lineWidth/2),credits.frame.origin.y+credits.frame.size.height,lineWidth,1);
                     }
                     completion:^(BOOL finished) {
                         //completion();
                     }];
    
    [UIView animateWithDuration:.5
                          delay:2.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         aButton.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         //completion();
                     }];
    
    [UIView animateWithDuration:.05
                          delay:4
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tweetieView.frame = CGRectMake(225, credits.frame.origin.y+credits.frame.size.height-img.size.height+1, img.size.width, img.size.height);
                     }
                     completion:^(BOOL finished) {
                         //completion();
                     }];
}




- (void)buttonPushed
{
    NSLog(@"Pushed the button.");
    
    [self.navigationController setNavigationBarHidden:NO];
    [[self navigationController] popViewControllerAnimated:NO];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"AppInfoViewController Disappearing");
     self.tabBarController.tabBar.hidden = NO;
	[self.navigationController setNavigationBarHidden:NO];
}

-(void)dealloc{
    [self.navigationController setNavigationBarHidden:NO];  
    NSLog(@"Deallocing AppinfoViewController");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
