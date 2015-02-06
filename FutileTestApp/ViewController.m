//
//  ViewController.m
//  FutileTestApp
//
//  Created by Ali Rantakari on 06.02.15.
//  Copyright (c) 2015 Futurice. All rights reserved.
//

#import "ViewController.h"
#import "UIAlertView+FKBlocks.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testAlert:(id)sender {
    [UIAlertView
     fk_showCancelableWithTitle:@"Foo"
     message:@"bar?"
     actionName:@"Destroy"
     actionHandler:^(UIAlertView *alert, NSInteger buttonIndex, NSString *input) {
         [UIAlertView
          fk_showWithTitle:@"Baz!"
          message:@"Skiigge Böy"
          okHandler:^(UIAlertView *alert) {
              NSLog(@"Yeppers.");
          }];
     }];
}
@end
