//
//  FKNumberSpinnerView.m
//  NumberSpinner
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

#import "FKNumberSpinnerView.h"
#import "FKDigitSpinnerView.h"

@interface FKNumberSpinnerView ()

@property (nonatomic, strong) NSMutableArray *digitSpinners;

@end

@implementation FKNumberSpinnerView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.value = -1;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setFrame:frame];
        self.backgroundColor = [UIColor clearColor];
        self.value = -1;
    }
    return self;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.value = -1;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    // Layout all the subviews correctly
    NSInteger digitWidth = self.bounds.size.width/self.digitCount;
    NSInteger digitHeight = self.bounds.size.height;
    for (int i=0; i<self.digitCount; i++) {
        FKDigitSpinnerView *digitSpinner = [self.digitSpinners objectAtIndex:i];
        digitSpinner.frame = CGRectMake(i*digitWidth, 0, digitWidth, digitHeight);
    }
}

- (void)setDigitCount:(NSInteger)digitCount
{
    _digitCount = digitCount;
    
    // Remove all old subviews
    for (FKDigitSpinnerView *digitSpinner in self.digitSpinners) {
        [digitSpinner removeFromSuperview];
    }
    
    // Create and all the subviews
    self.digitSpinners = [NSMutableArray arrayWithCapacity:self.digitCount];
    for (int i=0; i<self.digitCount; i++) {
        FKDigitSpinnerView *digitSpinner = [[FKDigitSpinnerView alloc] init];
        [self.digitSpinners setObject:digitSpinner atIndexedSubscript:i];
        [self addSubview:digitSpinner];
    }
    [self setFrame:self.frame];
    [self setValue:self.value];
}

- (void)setValue:(NSInteger)value
{
    [self setValue:value animated:NO];
}

- (void)setValue:(NSInteger)value animated:(BOOL)animated
{
    _value = value;

    // Set correct value for each digit
    for (int i=0; i<self.digitCount; i++) {
        FKDigitSpinnerView *digitSpinner = [self.digitSpinners objectAtIndex:(self.digitCount-1-i)];
        if (value < 0) {
            [digitSpinner setValue:-1 animated:animated];
        } else if (i == 0) {
            [digitSpinner setValue:value animated:animated];
        } else {
            [digitSpinner setValue:(value/(pow(10, i))) animated:animated];
        }
    }
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    for (FKDigitSpinnerView *digitSpinner in self.digitSpinners) {
        digitSpinner.font = font;
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    for (FKDigitSpinnerView *digitSpinner in self.digitSpinners) {
        digitSpinner.textColor = textColor;
    }
}

- (void)reset
{
    self.value = -1;
}

@end
