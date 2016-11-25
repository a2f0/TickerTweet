//
//  TickerDetailViewController.m
//  TickerTweet
//
//  Created by Dan Sullivan on 5/10/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import "TickerDetailViewController.h"
#import "CHCSVParser.h"
#import "UIColor+PXExtensions.h"
#import <QuartzCore/QuartzCore.h>
#import "RSSUIBarButtonItem.h"
#import "FavoriteButtonBarItem.h"
#import "Ticker.h"
#import "MWRootViewController.h"

@interface TickerDetailViewController ()

@end

@implementation TickerDetailViewController

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
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [[NSManagedObjectContext alloc] init];
    [self.context setPersistentStoreCoordinator: [self.appDelegate persistentStoreCoordinator]];

    self.finishedLabels = FALSE;
    self.finishedChart = FALSE;
    self.chartTimeRange = [NSString stringWithFormat:@"6m"];
}


-(void)startTimers {
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.tmrUpdateLabels = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(updateLabelHelper:) userInfo:nil repeats:YES];
    [runloop addTimer:self.tmrUpdateLabels forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.tmrUpdateLabels forMode:UITrackingRunLoopMode];
    NSRunLoop *runloop2 = [NSRunLoop currentRunLoop];
    self.tmrUpdateNetworkActivity = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(updateNetworkMonitorHelper:) userInfo:nil repeats:YES];
    [runloop2 addTimer:self.tmrUpdateNetworkActivity forMode:NSRunLoopCommonModes];
    [runloop2 addTimer:self.tmrUpdateNetworkActivity forMode:UITrackingRunLoopMode];
    
    NSRunLoop *runloop3 = [NSRunLoop currentRunLoop];
    self.tmrDrawIntervalButtons = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(drawIntervalButtonsHelper:) userInfo:nil repeats:YES];
    [runloop3 addTimer:self.tmrDrawIntervalButtons forMode:NSRunLoopCommonModes];
    [runloop3 addTimer:self.tmrDrawIntervalButtons forMode:UITrackingRunLoopMode];
    
    self.chartImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:self.chartImage];
}

- (IBAction)buttonPushed:(UILabel*)sender {
    NSLog(@"%ld pushed it for chart time range", (long)sender.tag);
    
    switch ( sender.tag ){
        case 1:
            self.chartTimeRange = [NSString stringWithFormat:@"1d"];
            [self downloadChart];
            break;
        case 2:
            self.chartTimeRange = [NSString stringWithFormat:@"5d"];
            [self downloadChart];
            break;
        case 3:
            self.chartTimeRange = [NSString stringWithFormat:@"3m"];
            [self downloadChart];
            break;
        case 4:
            self.chartTimeRange = [NSString stringWithFormat:@"6m"];
            [self downloadChart];
            break;
        case 5:
            self.chartTimeRange = [NSString stringWithFormat:@"1y"];
            [self downloadChart];
            break;
        case 6:
            self.chartTimeRange = [NSString stringWithFormat:@"2y"];
            [self downloadChart];
            break;
        case 7:
            self.chartTimeRange = [NSString stringWithFormat:@"5y"];
            [self downloadChart];
        case 8:
            self.chartTimeRange = [NSString stringWithFormat:@"max"];
            [self downloadChart];
    }    
}


-(void)updateNetworkMonitorHelper:(id)sender
{
    NSLog(@"Running updateNetworkMonitorHelper");
    BOOL allDone = TRUE;
    if(self.finishedLabels == FALSE) {
        allDone = FALSE;
    }
    if(self.finishedChart == FALSE) {
        allDone = FALSE;
    }
    if(self.chartChanged == TRUE && self.finishedLabels == TRUE) {
        NSLog(@"Setting the image");
        self.chartImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.greyImage.size.height, self.greyImage.size.width, self.greyImage.size.height)];
        [self.chartImage setImage:self.greyImage];
        [self.view addSubview:self.chartImage];
    }

    if(allDone == TRUE) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"Turned turned the network monitor off.");
    }
}


-(void)drawIntervalButtonsHelper:(id)sender
{
    NSLog(@"Running drawIntervalButtons this now..");
    if(self.finishedChart == TRUE && self.finishedLabels == TRUE) {
        [self.tmrDrawIntervalButtons invalidate];
        NSArray *timeIntervals = [NSArray arrayWithObjects: @"1d", @"5d", @"3m", @"6m", @"1y", @"2y", @"5y", @"max", nil];
        UIColor *myButtonColor = [UIColor pxColorWithHexValue:@"#F000FF"];
        float buttonWidth = 30;
        float buttonHeight = 30;
        float totalButtonAllocation = [timeIntervals count]*buttonWidth;
        float spaceRemaining = self.view.frame.size.width - totalButtonAllocation;
        float spacePerButton = spaceRemaining/([timeIntervals count] + 1);
        float currentX = spacePerButton;
        float yPosition = self.chartImage.frame.origin.y-buttonHeight;
        int positonTag = 1;
        for (NSString * interval in timeIntervals) {
            UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [aButton addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
            aButton.tag = positonTag;
            positonTag++;
            aButton.frame = CGRectMake(currentX,yPosition,buttonWidth,buttonHeight);
            aButton.alpha = 1.0;
            [aButton setTitle:interval forState:UIControlStateNormal];
            [self.view addSubview:aButton];
            [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            aButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [aButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
            [aButton setTitleColor:myButtonColor forState:UIControlStateNormal];
            currentX = currentX + buttonWidth + spacePerButton;
        }
    }
}


- (void)updateLabelHelper:(id)sender
{
    NSLog(@"Running updateLabelHelper");
    if(self.finishedLabels == TRUE && self.finishedChart == TRUE) {
        [self.tmrUpdateLabels invalidate];
        
        int horizontalSpace = 5;
        int leftMargin = 2;
        int rightMargin = 2;
        int middleMargin = 5;
        int topMargin = 5;
        int secondColumnStarting = [[UIScreen mainScreen] applicationFrame].size.width / 2;
        int rightEdge = [[UIScreen mainScreen] applicationFrame].size.width;
        UIColor *labelBackgroundColor = [UIColor clearColor];
        UIFont *tickerData = [UIFont systemFontOfSize:14];
   
        self.lblCompanyName = nil;
        self.lblCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        self.lblCompanyName.textColor = [UIColor grayColor];
        self.lblCompanyName.font = [UIFont systemFontOfSize:20];
        self.lblCompanyName.textAlignment = NSTextAlignmentLeft;
        self.lblCompanyName.numberOfLines = 5;
        self.lblCompanyName.text = self.csvCompanyName;
        self.lblCompanyName.backgroundColor = labelBackgroundColor;
        
        CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
        CGSize expectedLabelSize = [self.lblCompanyName.text sizeWithFont:self.lblCompanyName.font constrainedToSize:maximumLabelSize lineBreakMode:self.lblCompanyName.lineBreakMode];
        CGRect newFrame = self.lblCompanyName.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = leftMargin;
        newFrame.origin.y = topMargin;
        self.lblCompanyName.frame = newFrame;
        [self.lblCompanyName sizeToFit];
        [self.view addSubview:self.lblCompanyName];
        
        self.lblTickerSymbolExchange = nil;
        self.lblTickerSymbolExchange = [[UILabel alloc] initWithFrame:CGRectMake(self.lblCompanyName.frame.origin.x + self.lblCompanyName.frame.size.width, 0, 150, 50)];
        self.lblTickerSymbolExchange.textColor = [UIColor grayColor];
        self.lblTickerSymbolExchange.font = [UIFont systemFontOfSize:15];
        self.lblTickerSymbolExchange.textAlignment = NSTextAlignmentLeft;
        self.lblTickerSymbolExchange.numberOfLines = 5;
        self.lblTickerSymbolExchange.backgroundColor = labelBackgroundColor;
        self.lblTickerSymbolExchange.text = [NSString stringWithFormat:@"(%@:%@)", self.csvTickerSymbol, self.csvExchange]; ;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lblTickerSymbolExchange.text sizeWithFont:self.lblTickerSymbolExchange.font constrainedToSize:maximumLabelSize lineBreakMode:self.lblTickerSymbolExchange.lineBreakMode];
        newFrame = self.lblCompanyName.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = self.lblCompanyName.frame.origin.x + self.lblCompanyName.frame.size.width + horizontalSpace;
        newFrame.origin.y = self.lblCompanyName.frame.origin.y + (self.lblCompanyName.frame.size.height - newFrame.size.height)/2;
        self.lblTickerSymbolExchange.frame = newFrame;
        [self.lblTickerSymbolExchange sizeToFit];
        [self.view addSubview:self.lblTickerSymbolExchange];
    
        self.lblAskRealTime = nil;
        self.lblAskRealTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lblAskRealTime.textColor = [UIColor grayColor];
        self.lblAskRealTime.font = [UIFont boldSystemFontOfSize:20];
        self.lblAskRealTime.textAlignment = NSTextAlignmentLeft;
        self.lblAskRealTime.numberOfLines = 5;
        self.lblAskRealTime.backgroundColor = labelBackgroundColor;
        self.lblAskRealTime.text = [NSString stringWithFormat:@"%@", self.csvAskRealTime];
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lblAskRealTime.text sizeWithFont:self.lblAskRealTime.font constrainedToSize:maximumLabelSize lineBreakMode:self.lblAskRealTime.lineBreakMode];
        newFrame = self.lblAskRealTime.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = leftMargin;
        newFrame.origin.y = self.lblCompanyName.frame.origin.y + self.lblCompanyName.frame.size.height;
        self.lblAskRealTime.frame = newFrame;
        [self.view addSubview:self.lblAskRealTime];
        
        self.lblChange = nil;
        self.lblChange = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lblChange.textColor = [UIColor grayColor];
        self.lblChange.font = [UIFont systemFontOfSize:15];
        self.lblChange.textAlignment = NSTextAlignmentLeft;
        self.lblChange.numberOfLines = 5;
        self.lblChange.text = [NSString stringWithFormat:@"%@ (%@)", self.csvChange, [self.csvChangePercent substringFromIndex:1]];
        self.lblChange.backgroundColor = labelBackgroundColor;
        
        NSRange range = NSMakeRange (0,1);
        NSString *positiveNegative = [self.csvChangePercent substringWithRange:range];
             
        if([positiveNegative isEqualToString:@"+"]) {
            NSLog(@"It is positive");
            self.lblChange.textColor = [UIColor pxColorWithHexValue:@"#10E805"];
        } else if ([positiveNegative isEqualToString:@"-"]) {
            NSLog(@"It is negative");
            self.lblChange.textColor = [UIColor pxColorWithHexValue:@"#FF001E"];
        }
        
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lblChange.text sizeWithFont:self.lblChange.font constrainedToSize:maximumLabelSize lineBreakMode:self.lblChange.lineBreakMode];
        newFrame = self.lblChange.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = self.lblAskRealTime.frame.origin.x + self.lblAskRealTime.frame.size.width + horizontalSpace;
        newFrame.origin.y = self.lblAskRealTime.frame.origin.y + ((self.lblAskRealTime.frame.size.height-newFrame.size.height)/2);
        self.lblChange.frame = newFrame;
        [self.view addSubview:self.lblChange];

        //First row
        self.lbllblPERatio = nil;
        self.lbllblPERatio = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lbllblPERatio.textColor = [UIColor grayColor];
        self.lbllblPERatio.font = tickerData;
        self.lbllblPERatio.textAlignment = NSTextAlignmentLeft;
        self.lbllblPERatio.numberOfLines = 5;
        self.lbllblPERatio.text = [NSString stringWithFormat:@"P/E"];
        self.lbllblPERatio.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lbllblPERatio.text sizeWithFont:self.lbllblPERatio.font constrainedToSize:maximumLabelSize lineBreakMode:self.lbllblPERatio.lineBreakMode];
        newFrame = self.lbllblPERatio.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = leftMargin;
        newFrame.origin.y = self.lblAskRealTime.frame.origin.y + self.lblAskRealTime.frame.size.height;
        self.lbllblPERatio.frame = newFrame;
        [self.view addSubview:self.lbllblPERatio];
        
        //First row
        self.lblPERatio = nil;
        self.lblPERatio = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lblPERatio.textColor = [UIColor grayColor];
        self.lblPERatio.font = tickerData;
        self.lblPERatio.textAlignment = NSTextAlignmentRight;
        self.lblPERatio.numberOfLines = 5;
        self.lblPERatio.text = [NSString stringWithFormat:@"%@", self.csvPERatio];
        self.lblPERatio.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lblPERatio.text sizeWithFont:self.lblPERatio.font constrainedToSize:maximumLabelSize lineBreakMode:self.lblPERatio.lineBreakMode];
        newFrame = self.lblPERatio.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = secondColumnStarting - newFrame.size.width - (middleMargin);
        newFrame.origin.y = self.lblAskRealTime.frame.origin.y + self.lblAskRealTime.frame.size.height;
        self.lblPERatio.frame = newFrame;
        [self.view addSubview:self.lblPERatio];
        
        //Second Row
        self.lbllblMarketCap = nil;
        self.lbllblMarketCap = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lbllblMarketCap.textColor = [UIColor grayColor];
        self.lbllblMarketCap.font = tickerData;
        self.lbllblMarketCap.textAlignment = NSTextAlignmentLeft;
        self.lbllblMarketCap.numberOfLines = 5;
        self.lbllblMarketCap.text = [NSString stringWithFormat:@"Mkt Cap"];
        self.lbllblMarketCap.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lbllblMarketCap.text sizeWithFont:self.lbllblMarketCap.font constrainedToSize:maximumLabelSize lineBreakMode:self.lbllblMarketCap.lineBreakMode];
        newFrame = self.lbllblMarketCap.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        //newFrame.origin.x = self.lblAskRealTime.frame.origin.x + self.lblAskRealTime.frame.size.width + horizontalSpace;
        newFrame.origin.x = leftMargin;
        newFrame.origin.y = self.lbllblPERatio.frame.origin.y + self.lbllblPERatio.frame.size.height;
        self.lbllblMarketCap.frame = newFrame;
        [self.view addSubview:self.lbllblMarketCap];
        
        self.lblMarketCap = nil;
        self.lblMarketCap = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lblMarketCap.textColor = [UIColor grayColor];
        self.lblMarketCap.font = tickerData;
        self.lblMarketCap.textAlignment = NSTextAlignmentRight;
        self.lblMarketCap.numberOfLines = 5;
        self.lblMarketCap.text = [NSString stringWithFormat:@"%@", self.csvMarketCap];
        self.lblMarketCap.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lblMarketCap.text sizeWithFont:self.lblMarketCap.font constrainedToSize:maximumLabelSize lineBreakMode:self.lblMarketCap.lineBreakMode];
        newFrame = self.lblMarketCap.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = secondColumnStarting - newFrame.size.width - middleMargin;
        newFrame.origin.y = self.lbllblMarketCap.frame.origin.y;
        self.lblMarketCap.frame = newFrame;
        [self.view addSubview:self.lblMarketCap];
        
        //Third Row
        self.lbllbl1yrTarget = nil;
        self.lbllbl1yrTarget = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lbllbl1yrTarget.textColor = [UIColor grayColor];
        self.lbllbl1yrTarget.font = tickerData;
        self.lbllbl1yrTarget.textAlignment = NSTextAlignmentLeft;
        self.lbllbl1yrTarget.numberOfLines = 5;
        self.lbllbl1yrTarget.text = [NSString stringWithFormat:@"1yrTarget"];
        self.lbllbl1yrTarget.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lbllbl1yrTarget.text sizeWithFont:self.lbllbl1yrTarget.font constrainedToSize:maximumLabelSize lineBreakMode:self.lbllbl1yrTarget.lineBreakMode];
        newFrame = self.lbllbl1yrTarget.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = leftMargin;
        newFrame.origin.y = self.lbllblMarketCap.frame.origin.y + self.lbllblMarketCap.frame.size.height;
        self.lbllbl1yrTarget.frame = newFrame;
        [self.view addSubview:self.lbllbl1yrTarget];
        
        self.lbl1yrTarget = nil;
        self.lbl1yrTarget = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lbl1yrTarget.textColor = [UIColor grayColor];
        self.lbl1yrTarget.font = tickerData;
        self.lbl1yrTarget.textAlignment = NSTextAlignmentLeft;
        self.lbl1yrTarget.numberOfLines = 5;
        self.lbl1yrTarget.text = [NSString stringWithFormat:@"%@", self.csv1yrTarget];
        self.lbl1yrTarget.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lbl1yrTarget.text sizeWithFont:self.lbl1yrTarget.font constrainedToSize:maximumLabelSize lineBreakMode:self.lbl1yrTarget.lineBreakMode];
        newFrame = self.lbl1yrTarget.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = secondColumnStarting - newFrame.size.width - middleMargin;
        newFrame.origin.y = self.lbllbl1yrTarget.frame.origin.y;
        self.lbl1yrTarget.frame = newFrame;
        [self.view addSubview:self.lbl1yrTarget];

        
        self.lbllblDaysHigh = nil;
        self.lbllblDaysHigh = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lbllblDaysHigh.textColor = [UIColor grayColor];
        self.lbllblDaysHigh.font = tickerData;
        self.lbllblDaysHigh.textAlignment = NSTextAlignmentLeft;
        self.lbllblDaysHigh.numberOfLines = 5;
        self.lbllblDaysHigh.text = [NSString stringWithFormat:@"Day's High"];
        self.lbllblDaysHigh.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lbllblDaysHigh.text sizeWithFont:self.lbllblDaysHigh.font constrainedToSize:maximumLabelSize lineBreakMode:self.lbllblDaysHigh.lineBreakMode];
        newFrame = self.lbllblDaysHigh.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = secondColumnStarting;
        newFrame.origin.y = self.lbllblPERatio.frame.origin.y;
        self.lbllblDaysHigh.frame = newFrame;
        [self.view addSubview:self.lbllblDaysHigh];
        
        self.lblDaysHigh = nil;
        self.lblDaysHigh = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lblDaysHigh.textColor = [UIColor grayColor];
        self.lblDaysHigh.font = tickerData;
        self.lblDaysHigh.textAlignment = NSTextAlignmentLeft;
        self.lblDaysHigh.numberOfLines = 5;
        self.lblDaysHigh.text = [NSString stringWithFormat:@"%@", self.csvDaysHigh];
        self.lblDaysHigh.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lblDaysHigh.text sizeWithFont:self.lblDaysHigh.font constrainedToSize:maximumLabelSize lineBreakMode:self.lblDaysHigh.lineBreakMode];
        newFrame = self.lblDaysHigh.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = rightEdge - newFrame.size.width - rightMargin;
        newFrame.origin.y = self.lbllblDaysHigh.frame.origin.y;
        self.lblDaysHigh.frame = newFrame;
        [self.view addSubview:self.lblDaysHigh];
        
        self.lbllblVolume = nil;
        self.lbllblVolume = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lbllblVolume.textColor = [UIColor grayColor];
        self.lbllblVolume.font = tickerData;
        self.lbllblVolume.textAlignment = NSTextAlignmentLeft;
        self.lbllblVolume.numberOfLines = 5;
        self.lbllblVolume.text = [NSString stringWithFormat:@"Volume"];
        self.lbllblVolume.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lbllblVolume.text sizeWithFont:self.lbllblVolume.font constrainedToSize:maximumLabelSize lineBreakMode:self.lbllblVolume.lineBreakMode];
        newFrame = self.lbllblVolume.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = secondColumnStarting;
        newFrame.origin.y = self.lbllblMarketCap.frame.origin.y;
        self.lbllblVolume.frame = newFrame;
        [self.view addSubview:self.lbllblVolume];
        
        self.lblVolume = nil;
        self.lblVolume = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lblVolume.textColor = [UIColor grayColor];
        self.lblVolume.font = tickerData;
        self.lblVolume.textAlignment = NSTextAlignmentLeft;
        self.lblVolume.numberOfLines = 5;
        self.lblVolume.text = [NSString stringWithFormat:@"%@", self.csvVolume];
        self.lblVolume.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lblVolume.text sizeWithFont:self.lblVolume.font constrainedToSize:maximumLabelSize lineBreakMode:self.lblVolume.lineBreakMode];
        newFrame = self.lblVolume.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = rightEdge - newFrame.size.width - rightMargin;
        newFrame.origin.y = self.lbllblVolume.frame.origin.y;
        self.lblVolume.frame = newFrame;
        [self.view addSubview:self.lblVolume];
        
        self.lbllbl52WeekRange = nil;
        self.lbllbl52WeekRange = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lbllbl52WeekRange.textColor = [UIColor grayColor];
        self.lbllbl52WeekRange.font = tickerData;
        self.lbllbl52WeekRange.textAlignment = NSTextAlignmentLeft;
        self.lbllbl52WeekRange.numberOfLines = 5;
        self.lbllbl52WeekRange.text = [NSString stringWithFormat:@"1yrRange"];
        self.lbllbl52WeekRange.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lbllbl52WeekRange.text sizeWithFont:self.lbllbl52WeekRange.font constrainedToSize:maximumLabelSize lineBreakMode:self.lbllbl52WeekRange.lineBreakMode];
        newFrame = self.lbllbl52WeekRange.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = secondColumnStarting;
        newFrame.origin.y = self.lbllbl1yrTarget.frame.origin.y;
        self.lbllbl52WeekRange.frame = newFrame;
        [self.view addSubview:self.lbllbl52WeekRange];
        
        self.lbl52WeekRange = nil;
        self.lbl52WeekRange = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.lbl52WeekRange.textColor = [UIColor grayColor];
        self.lbl52WeekRange.font = tickerData;
        self.lbl52WeekRange.textAlignment = NSTextAlignmentLeft;
        self.lbl52WeekRange.numberOfLines = 5;
        self.lbl52WeekRange.text = [NSString stringWithFormat:@"%@", self.csv52WeekRange];
        self.lbl52WeekRange.backgroundColor = labelBackgroundColor;
        maximumLabelSize = CGSizeMake(296, FLT_MAX);
        expectedLabelSize = [self.lbl52WeekRange.text sizeWithFont:self.lbl52WeekRange.font constrainedToSize:maximumLabelSize lineBreakMode:self.lbl52WeekRange.lineBreakMode];
        newFrame = self.lbl52WeekRange.frame;
        newFrame.size.height = expectedLabelSize.height;
        newFrame.size.width = expectedLabelSize.width;
        newFrame.origin.x = rightEdge - newFrame.size.width - rightMargin;
        newFrame.origin.y = self.lbllbl52WeekRange.frame.origin.y;
        self.lbl52WeekRange.frame = newFrame;
        [self.view addSubview:self.lbl52WeekRange];
    }
}


- (void)viewWillAppear:(BOOL)animated
{       
    self.title = NSLocalizedString(self.tickerSymbol, nil);
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
 
    //Clean up.
    for(UIView *subview in [self.view subviews]) {
        [subview removeFromSuperview];
    }
    
    UIView* baseView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                [[UIScreen mainScreen] applicationFrame].size.width,
                                                                [[UIScreen mainScreen] applicationFrame].size.height)];
    
    [baseView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:baseView];
    
    [self refreshRightButtons];
    [self startTimers];
    [self downloadTickerInfo];
    [self downloadChart];
}

-(void)refreshRightButtons {
    NSLog(@"********Refreshing Buttons*********");
    
    UIButton *btnRSS = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imgRSS = [UIImage imageNamed:@"purple_rss-39x39.png"];
    [btnRSS setBackgroundImage:imgRSS forState:UIControlStateNormal];
    [btnRSS addTarget:self action:@selector(RSS:) forControlEvents:UIControlEventTouchUpInside];
    btnRSS.frame = CGRectMake(0, 0, 39, 39);
    UIBarButtonItem *uibtnRSS = [[UIBarButtonItem alloc] initWithCustomView:btnRSS];
    
    UIButton *btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imgFavorite = [UIImage alloc];
    if([self isCurrentlyFavorite]) {
        imgFavorite = [UIImage imageNamed:@"purple_star_solid-39x39.png"];
    } else if (![self isCurrentlyFavorite]) {
        imgFavorite = [UIImage imageNamed:@"purple_star-39x39.png"];
    }
    [btnFavorite setBackgroundImage:imgFavorite forState:UIControlStateNormal];
    [btnFavorite addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
    btnFavorite.frame = CGRectMake(0, 0, 39, 39);
    FavoriteButtonBarItem * uibtnFavorite = [[FavoriteButtonBarItem alloc] initWithCustomView:btnFavorite];
    
    NSArray *buttonArray = [NSArray arrayWithObjects: uibtnRSS,uibtnFavorite,nil];
    self.parentViewController.navigationItem.rightBarButtonItems = buttonArray;
    [[self navigationItem] setRightBarButtonItems:buttonArray];
    
}

- (void)toggleFavorite:(id)sender
{
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Ticker"
                inManagedObjectContext:self.context];
    
    //initialize a fetch request and set the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    //Set the entity description
    [request setEntity:entityDesc];
    
    //Prepend a dollar onto this string.
    NSString *mySymbol = [NSString stringWithFormat:@"$%@", self.tickerSymbol];
    mySymbol = [mySymbol uppercaseString];
    
    NSLog(@"tickersymbol: %@", mySymbol);
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(symbol = %@)", mySymbol];
    [request setPredicate:pred];
    
    NSError *error;
    
    //Execute the fetch request, have it return objects
    NSArray *objects = [self.context executeFetchRequest:request
                                                   error:&error];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"symbol" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSLog(@"Object count was from toggleFavorites: %d", [objects count]);
    NSLog(@"isfavorite: %c", [self isCurrentlyFavorite]);
    
    if ([objects count] == 1) {
        if ([self isCurrentlyFavorite] == YES) {
            Ticker *currentTicker  = [objects objectAtIndex:0];
            currentTicker.isFavorite = [NSNumber numberWithBool:NO];
        } else if ([self isCurrentlyFavorite] == NO) {
            Ticker *currentTicker  = [objects objectAtIndex:0];
            currentTicker.isFavorite = [NSNumber numberWithBool:YES];
        } else {
            NSLog(@"Should always be favorite or not favorite.  This should never happen");
        }
    } else {
        [self addTicker:self.tickerSymbol];
    }
    
    //After we make the change, save the context.
    error = nil;
    if (![self.context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self refreshRightButtons];
}

- (void)RSS:(id)sender {
    NSLog(@"Pressed RSS for ticker %@", self.tickerSymbol);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    MWRootViewController* rssftvc = [[MWRootViewController alloc] init];
    rssftvc.tickerSymbol = self.tickerSymbol;
    [self.navigationController pushViewController:rssftvc animated:YES];
}


-(BOOL)isCurrentlyFavorite {
    NSLog(@"Called isCurrentlyFavorite");
    
    //Set the entity of the search
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Ticker"
                inManagedObjectContext:self.context];
    
    //initialize a fetch request and set the
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    //Set the entity description
    [request setEntity:entityDesc];
        
    //Prepend a dollar onto this string.
    NSString *mySymbol = [NSString stringWithFormat:@"$%@", self.tickerSymbol];
    mySymbol = [mySymbol uppercaseString];
    
    NSLog(@"tickersymbol: %@", mySymbol);
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(symbol = %@)", mySymbol];
    [request setPredicate:pred];
    
    //instantiate an error
    NSError *error;
    
    //Execute the fetch request, have it return objects
    NSArray *objects = [self.context executeFetchRequest:request
                                                   error:&error];
    
    //for (NSDictionary *tweet in self.twitterSearchResults) {
    //If a match was found, return YES, if not, NO.
        
    Ticker *currentTicker  = [objects objectAtIndex:0];
    NSLog(@"currentTicker from isfavorite %@", currentTicker);
    
    if ([currentTicker.isFavorite intValue] == 1) {
        NSLog(@"Returning YES");
        return YES;
    } else if ([currentTicker.isFavorite intValue] == 0){
        NSLog(@"Returning yes");
        return NO;
    } else {
        NSLog(@"Unable to determine if this is current favorite.");
        return NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    // Return the new grayscale image
    return newImage;
}

-(void) downloadChart
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        self.finishedChart = FALSE;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
        NSString *imageURL = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@&z=s&t=%@", self.tickerSymbol, self.chartTimeRange];
        
        NSError* error = nil;
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString: imageURL] options:NSDataReadingUncached error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
    
            UIImage *image = [UIImage imageWithData: imageData];
            
            float oldWidth = image.size.width;
            float scaleFactor = [UIScreen mainScreen].bounds.size.width / oldWidth;
            
            float newHeight = image.size.height * scaleFactor;
            float newWidth = oldWidth * scaleFactor;
            
            UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
            [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
            
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            self.greyImage = [self convertImageToGrayScale:newImage];
            
            UIGraphicsEndImageContext();
        }
        self.chartChanged = TRUE;
        self.finishedChart = TRUE;
    });
    
}

//The CSV Ticker Information
-(void) downloadTickerInfo
{
    
    NSString *tickercsv = [NSString stringWithFormat:@"http://finance.yahoo.com/d/quotes.csv?s=%@+&f=snb2p2rj1t8hvwxc1", self.tickerSymbol];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            
        NSError* error = nil;
        NSString* csv = [NSString stringWithContentsOfURL:[NSURL URLWithString:tickercsv] encoding:NSASCIIStringEncoding error:&error];
        
        if( error )
        {
            NSLog(@"Error = %@", error);
        }
        else
        {
            NSArray *fields = [csv CSVComponents];
            NSMutableArray *firstRow = [fields objectAtIndex:0];
            
            for (id object in firstRow) {
                // do something with object
                NSLog(@"object: %@", object);
            }
            
            NSString *csvTickerSymbol = [firstRow objectAtIndex:0];
            NSLog(@"csvTickerSymbol: %@", csvTickerSymbol);
            self.csvTickerSymbol = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:0]];
            [self.csvTickerSymbol replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csvTickerSymbol length])];
            
            NSMutableString *csvCompanyName = [firstRow objectAtIndex:1];
            NSLog(@"csvCompanyName: %@", csvCompanyName);
            self.csvCompanyName = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:1]];
            [self.csvCompanyName replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csvCompanyName length])];
            
            NSString *csvAskRealTime = [firstRow objectAtIndex:2];
            NSLog(@"csvAskRealTime: %@", csvAskRealTime);
            self.csvAskRealTime = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:2]];
            [self.csvAskRealTime replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csvAskRealTime length])];
            
            NSString *csvChangePercent = [firstRow objectAtIndex:3];
            self.csvChangePercent = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:3]];
            [self.csvChangePercent replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csvChangePercent length])];
            NSLog(@"csvChangePercent: %@", csvChangePercent);
            
            NSString *csvPERatio = [firstRow objectAtIndex:4];
            self.csvPERatio = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:4]];
            [self.csvPERatio replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csvPERatio length])];
            NSLog(@"csvPERatio: %@", csvPERatio);
            
            NSString *csvMarketCap = [firstRow objectAtIndex:5];
            self.csvMarketCap = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:5]];
            [self.csvMarketCap replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csvMarketCap length])];
            NSLog(@"csvMarketCap: %@", csvMarketCap);
            
            NSString *csv1yrTarget = [firstRow objectAtIndex:6];
            self.csv1yrTarget = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:6]];
            [self.csv1yrTarget replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csv1yrTarget length])];
            NSLog(@"csv1yrTarget: %@", csv1yrTarget);
            
            NSString *csvDaysHigh = [firstRow objectAtIndex:7];
            self.csvDaysHigh = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:7]];
            [self.csvDaysHigh replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csvDaysHigh length])];
            NSLog(@"csvDaysHigh: %@", csvDaysHigh);
            
            NSString *csvVolume = [firstRow objectAtIndex:8];
            self.csvVolume = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:8]];
            [self.csvVolume replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csvVolume length])];
            NSLog(@"csvVolume: %@", csvVolume);
            
            NSString *csv52WeekRange = [firstRow objectAtIndex:9];
            self.csv52WeekRange = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:9]];
            [self.csv52WeekRange replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csv52WeekRange length])];
            [self.csv52WeekRange replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csv52WeekRange length])];
            NSLog(@"csv52WeekRange: %@", csv52WeekRange);
            
            NSString *csvExchange = [firstRow objectAtIndex:10];
            self.csvExchange = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:10]];
            [self.csvExchange replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csvExchange length])];
            NSLog(@"csvExchange: %@", csvExchange);
            
            NSString *csvChange = [firstRow objectAtIndex:11];
            self.csvChange = [NSMutableString stringWithFormat:@"%@",[firstRow objectAtIndex:11]];
            [self.csvChange replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.csvChange length])];
            NSLog(@"csvChange: %@", csvChange);
            
                
            NSLog(@"askRealTime: %@", [firstRow objectAtIndex:2]);

            self.title = NSLocalizedString(self.tickerSymbol, nil);
            self.finishedLabels = TRUE;
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    [self.tmrDrawIntervalButtons invalidate];
    [self.tmrUpdateLabels invalidate];
    [self.tmrUpdateNetworkActivity invalidate];
}

- (void)dealloc {
    NSLog(@"Dealloc of tickerdetail");
}

-(void)addTicker:(NSString *)symbol {
    
    NSError *error;
    
    Ticker *newTicker = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Ticker"
                         inManagedObjectContext:self.context];
    [newTicker setValue:symbol forKey:@"symbol"];
    [newTicker setValue:[NSNumber numberWithBool:NO] forKey:@"isFavorite"];
    [self.context save:&error];
    NSLog(@"Added new ticker from TickerDetailView: %@", symbol);
}
@end
