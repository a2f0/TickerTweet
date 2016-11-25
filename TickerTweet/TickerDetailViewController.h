//
//  TickerDetailViewController.h
//  TickerTweet
//
//  Created by Dan Sullivan on 5/10/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TickerTweetAppDelegate.h"

@interface TickerDetailViewController : UIViewController

@property (nonatomic, retain) NSString *tickerSymbol;
@property (nonatomic, retain) NSMutableString *chartInterval;

//Labels populated from CSV values
@property (nonatomic, strong) UILabel *lblTickerSymbolExchange;
@property (nonatomic, strong) UILabel *lblCompanyName;
@property (nonatomic, strong) UILabel *lblAskRealTime;
@property (nonatomic, strong) UILabel *lblChange;
@property (nonatomic, strong) UILabel *lblPERatio;
@property (nonatomic, strong) UILabel *lblMarketCap;
@property (nonatomic, strong) UILabel *lbl1yrTarget;
@property (nonatomic, strong) UILabel *lblDaysHigh;
@property (nonatomic, strong) UILabel *lblVolume;

//My local imageview
@property (nonatomic, strong) UIImageView *chartImage;
@property (nonatomic, strong) UIImage *greyImage;

//The size of the image passed through to the Query
@property (nonatomic, strong) NSMutableString *chartTimeRange;

//Labels for labels
@property (nonatomic, strong) UILabel *lbllblPERatio;
@property (nonatomic, strong) UILabel *lbllblMarketCap;
@property (nonatomic, strong) UILabel *lbllbl1yrTarget;
@property (nonatomic, strong) UILabel *lbllblDaysHigh;
@property (nonatomic, strong) UILabel *lbllblVolume;
@property (nonatomic, strong) UILabel *lbllbl52WeekRange;
@property (nonatomic, strong) UILabel *lbl52WeekRange;

//properties set by CSV parser.
@property (nonatomic, strong) NSMutableString *csvTickerSymbol;
@property (nonatomic, strong) NSMutableString *csvCompanyName;
@property (nonatomic, strong) NSMutableString *csvAskRealTime;
@property (nonatomic, strong) NSMutableString *csvChangePercent;
@property (nonatomic, strong) NSMutableString *csvPERatio;
@property (nonatomic, strong) NSMutableString *csvMarketCap;
@property (nonatomic, strong) NSMutableString *csv1yrTarget;
@property (nonatomic, strong) NSMutableString *csvDaysHigh;
@property (nonatomic, strong) NSMutableString *csvVolume;
@property (nonatomic, strong) NSMutableString *csv52WeekRange;
@property (nonatomic, strong) NSMutableString *csvExchange;
@property (nonatomic, strong) NSMutableString *csvChange;

@property (nonatomic, assign) BOOL finishedLabels;
@property (nonatomic, assign) BOOL finishedChart;
@property (nonatomic, assign) BOOL chartChanged;

@property (nonatomic, strong) NSTimer *tmrUpdateLabels;
@property (nonatomic, strong) NSTimer *tmrUpdateNetworkActivity;
@property (nonatomic, strong) NSTimer *tmrDrawIntervalButtons;

//These are for the favorites.
@property (nonatomic, strong) TickerTweetAppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end
