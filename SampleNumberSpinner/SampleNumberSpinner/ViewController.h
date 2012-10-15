//
//  ViewController.h
//  SampleNumberSpinner
//
//  Created by Juho Vähä-Herttua on 10/15/12.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FKNumberSpinnerView.h"

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet FKNumberSpinnerView *numberSpinner;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UITextField *textField;

- (IBAction)segmentedControlValueChanged:(id)sender;
- (IBAction)updateButtonPressed:(id)sender;

@end
