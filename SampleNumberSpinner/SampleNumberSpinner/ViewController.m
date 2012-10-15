//
//  ViewController.m
//  SampleNumberSpinner
//
//  Created by Juho Vähä-Herttua on 10/15/12.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.numberSpinner setDigitCount:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentedControlValueChanged:(id)sender
{
    [self.numberSpinner setDigitCount:self.segmentedControl.selectedSegmentIndex+1];
}

- (IBAction)updateButtonPressed:(id)sender
{
    [self.numberSpinner setValue:self.textField.text.intValue animated:YES];
}

@end
