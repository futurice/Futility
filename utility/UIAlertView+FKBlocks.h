//
//  UIAlertView+FKBlocks.h
//  Non-ARC version
//  iOS 4.3+
//
/*
The MIT License

Copyright (c) 2011-2012 Ali Rantakari

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#import <UIKit/UIKit.h>

typedef void (^FKAlertViewDismissBlock)(UIAlertView *alert, int buttonIndex, NSString *input);
typedef void (^FKAlertViewCancelBlock)(UIAlertView *alert);

@interface UIAlertView (UIAlertView_FKBlocks)

// Show alert with just an "OK" button
+ (UIAlertView*) fk_showWithTitle:(NSString*)title
                          message:(NSString*)message
                        okHandler:(FKAlertViewCancelBlock)okBlock;

// Show alert with "Cancel" and "Whatever-action" buttons
+ (UIAlertView*) fk_showCancelableWithTitle:(NSString*)title
                                    message:(NSString*)message
                                 actionName:(NSString*)actionName
                              actionHandler:(FKAlertViewDismissBlock)actionBlock;

// Show alert with arbitrary buttons
+ (UIAlertView*) fk_showWithTitle:(NSString*)title
                          message:(NSString*)message
                cancelButtonTitle:(NSString*)cancelButtonTitle
                otherButtonTitles:(NSArray*)otherButtonTitles
                   dismissHandler:(FKAlertViewDismissBlock)dismissBlock
                    cancelHandler:(FKAlertViewCancelBlock)cancelBlock;

// Show alert with text input and arbitrary buttons
+ (UIAlertView *) fk_showWithTitle:(NSString*)title
                           message:(NSString*)message
                     textFieldText:(NSString*)fieldText
                       placeholder:(NSString*)fieldPlaceholder
                       secureInput:(BOOL)secureInput
                      keyboardType:(UIKeyboardType)keyboardType
                 cancelButtonTitle:(NSString*)cancelButtonTitle
                 otherButtonTitles:(NSArray*)otherButtonTitles
                    dismissHandler:(FKAlertViewDismissBlock)dismissBlock
                     cancelHandler:(FKAlertViewCancelBlock)cancelBlock;

@end
