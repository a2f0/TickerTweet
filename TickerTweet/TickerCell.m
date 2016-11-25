//
//  TickerCell.m
//  TickerTweet
//
//  Created by Dan Sullivan on 4/6/13.
//  Copyright (c) 2013 Dan Sullivan. All rights reserved.
//

#import "TickerCell.h"

@implementation TickerCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //self.tickerLabel.textColor = [UIColor orangeColor];
    
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
