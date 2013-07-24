//
//  FKNumberSpinnerView.h
//  NumberSpinner
//
//  Created by Juho Vähä-Herttua.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKNumberSpinnerView : UIView

@property (nonatomic, assign) NSInteger digitCount;
@property (nonatomic, assign) NSInteger value;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

- (void)setValue:(NSInteger)value animated:(BOOL)animated;
- (void)reset;

@end
