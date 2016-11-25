// AttributedTableViewCell.m
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <QuartzCore/QuartzCore.h>
#import "AttributedTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "UIColor+PXExtensions.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static CGFloat const kEspressoDescriptionTextFontSize = 17;
//static CGFloat const kAttributedTableViewCellVerticalMargin = 20.0f;
static CGFloat const kAttributedTableViewCellVerticalMargin = 0.0f;

static inline NSRegularExpression * NameRegularExpression() {
    static NSRegularExpression *_nameRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _nameRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"^\\w+" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _nameRegularExpression;
}

static inline NSRegularExpression * ParenthesisRegularExpression() {
    static NSRegularExpression *_parenthesisRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _parenthesisRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"\\([^\\(\\)]+\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _parenthesisRegularExpression;
}

static inline NSRegularExpression * CashbangRegularExpression() {
    static NSRegularExpression *_CashbangRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{  
        //_CashbangRegularExpression  = [[NSRegularExpression alloc] initWithPattern:@"\\$\\w+" options:NSRegularExpressionCaseInsensitive error:nil];
        _CashbangRegularExpression  = [[NSRegularExpression alloc] initWithPattern:@"(\\$[a-zA-Z]{1,4})" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _CashbangRegularExpression;
}

@implementation AttributedTableViewCell
@synthesize summaryText = _summaryText;
@synthesize summaryLabel = _summaryLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.summaryLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    //self.summaryLabel.font = [UIFont systemFontOfSize:kEspressoDescriptionTextFontSize];
    self.summaryLabel.font = [UIFont systemFontOfSize:15];
    //self.summaryLabel.textColor = [UIColor darkGrayColor];
    self.summaryLabel.textColor = [UIColor grayColor];
    self.summaryLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.summaryLabel.numberOfLines = 0;
    self.summaryLabel.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setValue:(id)[[UIColor redColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    [mutableActiveLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableActiveLinkAttributes setValue:(id)[[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.1f] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
    [mutableActiveLinkAttributes setValue:(id)[[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.25f] CGColor] forKey:(NSString *)kTTTBackgroundStrokeColorAttributeName];
    [mutableActiveLinkAttributes setValue:(id)[NSNumber numberWithFloat:1.0f] forKey:(NSString *)kTTTBackgroundLineWidthAttributeName];
    [mutableActiveLinkAttributes setValue:(id)[NSNumber numberWithFloat:5.0f] forKey:(NSString *)kTTTBackgroundCornerRadiusAttributeName];
    self.summaryLabel.activeLinkAttributes = mutableActiveLinkAttributes;
    
    
    self.summaryLabel.highlightedTextColor = [UIColor whiteColor];
    self.summaryLabel.shadowColor = [UIColor colorWithWhite:0.87 alpha:1.0];
    self.summaryLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.summaryLabel.highlightedShadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
    self.summaryLabel.highlightedShadowOffset = CGSizeMake(0.0f, -1.0f);
    self.summaryLabel.highlightedShadowRadius = 1;
    self.summaryLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    
    //NSLog(@"self.contentview: %@", self.contentView);
    
    [self.contentView addSubview:self.summaryLabel];
    
    //NSLog(@"self.contentview: %@", self.contentView);
    
    return self;
}


- (void)setSummaryText:(NSString *)text {
    [self willChangeValueForKey:@"summaryText"];
    _summaryText = [text copy];
    [self didChangeValueForKey:@"summaryText"];
    
    NSMutableArray * customTickerLocations = [NSMutableArray new];
    
    [self.summaryLabel setText:self.summaryText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange stringRange = NSMakeRange(0, [mutableAttributedString length]);
    
        
        //NSRegularExpression *regexp = NameRegularExpression();
        /*
        NSRegularExpression *regexp = CashbangRegularExpression();
        NSRange nameRange = [regexp rangeOfFirstMatchInString:[mutableAttributedString string] options:0 range:stringRange];
        
        UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:kEspressoDescriptionTextFontSize];
        
        CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        
        if (boldFont) {
            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:nameRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:nameRange];
            CFRelease(boldFont);
        }*/
        
        //NSLog(@"nameRangeLocation: %lu", (unsigned long)nameRange.location);
        //NSLog(@"nameRangelength: %lu", (unsigned long)nameRange.length);
        //[mutableAttributedString replaceCharactersInRange:nameRange withString:[[[mutableAttributedString string] substringWithRange:nameRange] uppercaseString]];
        
        
        //regexp = ParenthesisRegularExpression();
        
        NSRegularExpression *regexp = CashbangRegularExpression();
        //int count_this_cell =   1;
        
        [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            //count_this_cell +=1;
            
            //NSLog(@"Iterating");
            
            //NSLog(@"mutableAttributedString: %@", mutableAttributedString);
            //NSLog(@"mutableAttributedString: %@", mutableAttributedString);
            
            NSRange myRange = result.range;
            BOOL bounded_left = FALSE;
            BOOL bounded_right = FALSE;
            BOOL bounded_correctly = TRUE;
            //
            NSLog(@"Original comparison: %@",  [mutableAttributedString.mutableString substringWithRange:myRange]);
            if (myRange.location == 0) {
                bounded_left = TRUE;
                NSLog(@"Bounded left");
            } else {
                NSLog(@"Not bounded left");
            }
            if (myRange.location + myRange.length + 1 > [mutableAttributedString.mutableString length]) {
                bounded_right = TRUE;
            } else {
                NSLog(@"Not bounded right");
            }
            
            //Then we need to make sure there is a space on the left side before we highlight it.
            if (bounded_left == FALSE) {
                NSString *myLeftCharacter = [mutableAttributedString.mutableString substringWithRange:NSMakeRange(myRange.location-1, 1)];
                NSLog(@"My left character: %@", myLeftCharacter);
                if ([myLeftCharacter hasPrefix:@" "] || [myLeftCharacter hasPrefix:@","] ) {
                    NSLog(@"It is prefixed corretly");
                } else {
                    NSLog(@"It is not prefixed correctly");
                    bounded_correctly = FALSE;
                }
            }
            
            //Then we need to make sure there is a space on the right side before we highlight it.
            if (bounded_right == FALSE ) {
                NSString *myRightCharacter = [mutableAttributedString.mutableString substringWithRange:NSMakeRange(myRange.location + myRange.length, 1)];
                NSLog(@"My right character: %@", myRightCharacter);
                if ([myRightCharacter hasSuffix:@" "] || [myRightCharacter hasSuffix:@","] || [myRightCharacter hasSuffix:@"."] ) {
                    NSLog(@"It is prefixed corretly");
                } else {
                    NSLog(@"It is not prefixed correctly");
                    bounded_correctly = FALSE;
                }
            }
            
            if (bounded_correctly == FALSE) {
                NSLog(@"**********Not bounded correctly, will not highlight **********");
            
            } else {
                /*
                 if ( bounded_left == FALSE ) {
                 NSRange myNewRange = NSMakeRange(myRange.location-1, 1);
                 NSString *leftCharacter = [mutableAttributedString.mutableString substringWithRange:myNewRange];
                 }
                 
                 if ( bounded_right == FALSE ) {
                 NSRange myNewRange = NSMakeRange(myRange.location + myRange.length, 1);
                 NSString *rightCharacter = [mutableAttributedString.mutableString substringWithRange:myNewRange];
                 }
                 */
                
                
                
                
                
                //NSString *myBroadenedMatch = [mutableAttributedString.mutableString substringWithRange:myNewRange];
                
                //NSLog(@"Broadened: %@", myBroadenedMatch);
                
                //NSLog(@"The actual string: %@", mutableAttributedString.mutableString );
                
                //if([myMatch hasPrefix:@" "] && [myMatch hasSuffix:@" "] ) {
                
                //NSString * newString = [mutableAttributedString substringWithRange:NSMakeRange(myRange.location, 1)];
                //NSString * newString = [s substringWithRange:NSMakeRange(i, 1)];
                
                //NSLog(@"nameRangeLocation: %lu", (unsigned long)myRange.location);
                //NSLog(@"nameRangelength: %lu", (unsigned long)myRange.length);
                
                [customTickerLocations addObject:[NSValue valueWithRange:myRange]];
                
                
                
                //NSLog(@"value: %@",[self.summaryText substringWithRange:myRange]);
                
                //[self.summaryText substringWithRange:myRange]]];
                
                
                //addLinkToAddress:(NSDictionary *)addressComponents            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys: @"userName", @"DoronK", nil];
                
                //NSLog(@"result: %@", result.range);
                //NSLog(@"nameRangeLocation: %lu", (unsigned long)stringRange.location);
                //NSLog(@"nameRangelength: %lu", (unsigned long)stringRange.length);
                
                //UIFont *italicSystemFont = [UIFont italicSystemFontOfSize:kEspressoDescriptionTextFontSize];
                UIFont *cashBang = [UIFont systemFontOfSize:15];
                
                //CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)italicSystemFont.fontName, italicSystemFont.pointSize, NULL);
                CTFontRef cashBangFont = CTFontCreateWithName((__bridge CFStringRef)cashBang.fontName, cashBang.pointSize, NULL);
                
                //UIColor *myColor = [UIColor pxColorWithHexValue:@"#0000FF"];
                UIColor *myCashBangColor = [UIColor pxColorWithHexValue:@"#F000FF"];
                
                //if (italicSystemFont) {
                if (cashBang) {
                    [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:result.range];
                    //[mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:result.range];
                    [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)cashBangFont range:result.range];
                    //CFRelease(italicFont);
                    CFRelease(cashBangFont);
                    [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:result.range];
                    //[mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[myColor CGColor] range:result.range];
                    [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[myCashBangColor CGColor] range:result.range];
                }
            
            }
        
        }];
        
        
        //regexp = CashbangRegularExpression();
        
        return mutableAttributedString;
    }];
    
    //NSRegularExpression *regexp = NameRegularExpression();
    
    /*
    NSRegularExpression *regexp = CashbangRegularExpression();
    NSRange linkRange = [regexp rangeOfFirstMatchInString:self.summaryText options:0 range:NSMakeRange(0, [self.summaryText length])];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", [self.summaryText substringWithRange:linkRange]]];
    [self.summaryLabel addLinkToURL:url withRange:linkRange];
     */
    
    //NSLog(@"count of customTickerLocations: %lu",(unsigned long)[customTickerLocations count]);
    
    for (NSValue *myValue in customTickerLocations) {
        //NSLog(@"myValue: %@", myValue);;
        NSRange myRange = [myValue rangeValue];
        //NSLog(@"Location: %lu", (unsigned long)myRange.location);
        
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys: [self.summaryText substringWithRange:myRange], @"tickerName", nil];
        [self.summaryLabel addLinkToAddress:dictionary withRange:myRange];

    }
    
    
    
    //NSRange stringRange = NSMakeRange(8,4);

}

+ (CGFloat)heightForCellWithText:(NSString *)text {
    CGFloat height = 10.0f;
    height += ceilf([text sizeWithFont:[UIFont systemFontOfSize:kEspressoDescriptionTextFontSize] constrainedToSize:CGSizeMake(270.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height);
    height += kAttributedTableViewCellVerticalMargin;
    return height;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
        
    self.summaryLabel.frame = CGRectOffset(CGRectInset(self.bounds, 20.0f, 5.0f), -10.0f, 0.0f);
}

@end

#pragma clang diagnostic pop
