//
//  UIAlertView+FKBlocks.h
//  Non-ARC version
//  iOS 4.3+
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
