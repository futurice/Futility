//
//  FKDigitSpinnerView.h
//  DigitSpinner
//
//  Created by Juho Vähä-Herttua.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKDigitSpinnerView : UIView

@property (nonatomic, assign) NSInteger value;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

- (void)setValue:(NSInteger)value animated:(BOOL)animated;

@end
