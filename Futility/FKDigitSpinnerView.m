//
//  FKDigitSpinnerView.m
//  DigitSpinner
//
//  Created by Juho Vähä-Herttua.
//  Loosely based on code written by Janne Käki.
//
//  Copyright (c) 2012 Futurice.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "FKDigitSpinnerView.h"
#import "UIView+FKGeometry.h"

@interface FKDigitSpinnerView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation FKDigitSpinnerView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.scrollView = [self createScrollView];
        [self addSubview:self.scrollView];
        [self updateScrollView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.scrollView = [self createScrollView];
        [self addSubview:self.scrollView];
        [self updateScrollView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.scrollView = [self createScrollView];
    [self addSubview:self.scrollView];
    [self updateScrollView];
}

- (UIScrollView *)createScrollView
{
    // Create the scrollview and set its properties
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.userInteractionEnabled = NO;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    
    // Add all labels
    for (int i=-1; i<20; i++) {
        NSInteger countFromBottom = 20-(i+1);
        CGRect labelFrame = CGRectMake(0, countFromBottom*self.height, self.width, self.height);
        
        UILabel *numberLabel = [[UILabel alloc] initWithFrame:labelFrame];
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        if (i < 0) {
            numberLabel.text = @"-";
        } else {
            numberLabel.text = [NSString stringWithFormat:@"%d", (i%10)];
        }
        numberLabel.tag = 1000+i;
        [scrollView addSubview:numberLabel];
    }
    
    // Initialize scroll view to default value of -1
    self.value = -1;
    
    return scrollView;
}

- (void)updateScrollView
{
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.width, 21*self.height);
    
    // Update locations of all the labels
    for (int i=-1; i<20; i++) {
        NSInteger countFromBottom = 20-(i+1);
        UILabel *numberLabel = (UILabel *)[self.scrollView viewWithTag:1000+i];
        numberLabel.frame = CGRectMake(0, countFromBottom*self.height, self.width, self.height);
    }
    
    // Scrolling finished, get tag of the lower value
    NSInteger tag = 999;
    if (self.value >= 0) {
        tag = 1000+(self.value%10);
    }
    UILabel *lastLabel = (UILabel *)[self.scrollView viewWithTag:tag];
    [self.scrollView scrollRectToVisible:lastLabel.frame animated:NO];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updateScrollView];
}

- (void)setValue:(NSInteger)value
{
    [self setValue:value animated:NO];
}

- (void)setValue:(NSInteger)value animated:(BOOL)animated
{
    NSInteger tag = 999;
    if (value >= 0 && value >= _value) {
        // Get tag for the lower label
        tag = 1000+(value%10);
    } else if (value > 0) {
        // Get tag for the upper label
        tag = 1000+10+(value%10);
    }
    
    // Scroll to the correct label
    UILabel *nextLabel = (UILabel *)[self.scrollView viewWithTag:tag];
    [self.scrollView scrollRectToVisible:nextLabel.frame animated:animated];
    
    _value = value;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    
    // Update locations of all the labels
    for (int i=-1; i<20; i++) {
        UILabel *numberLabel = (UILabel *)[self.scrollView viewWithTag:1000+i];
        numberLabel.font = font;
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    
    // Update colors of all the labels
    for (int i=-1; i<20; i++) {
        UILabel *numberLabel = (UILabel *)[self.scrollView viewWithTag:1000+i];
        numberLabel.textColor = textColor;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // Scrolling finished, get tag of the lower value
    NSInteger tag = 999;
    if (self.value >= 0) {
        tag = 1000+(self.value%10);
    }
    
    // Scroll to the correct label
    UILabel *nextLabel = (UILabel *)[self.scrollView viewWithTag:tag];
    [self.scrollView scrollRectToVisible:nextLabel.frame animated:NO];
}

@end
