//
//  FKNumberSpinnerView.m
//  NumberSpinner
//
//  Created by Juho Vähä-Herttua.
//  Loosely based on code written by Janne Käki.
//
//
// Copyright © Futurice (http://www.futurice.com)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// * Neither the name of Futurice nor the names of its contributors may be used to
//   endorse or promote products derived from this software without specific prior
//   written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//

#import "FKNumberSpinnerView.h"
#import "FKDigitSpinnerView.h"

// FIXME: Fix these issues here:
#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wsign-conversion"

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
        FKDigitSpinnerView *digitSpinner = self.digitSpinners[i];
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
        self.digitSpinners[i] = digitSpinner;
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
        FKDigitSpinnerView *digitSpinner = self.digitSpinners[(self.digitCount-1-i)];
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
