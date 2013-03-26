//
//  UIView+FKKeyboard.h
//  FuKit
//
//  Created by Ali Rantakari on 26.3.2013.
//
/*
 The MIT License
 
 Copyright (c) 2013 Futurice
 
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

typedef void(^FKViewKeyboardReactionHandler)(NSNotification *note, BOOL keyboardWillShow, BOOL willBeObscuredByKeyboard);

@interface UIView (FKKeyboard)

- (void) fk_reactToKeyboardWithHandler:(FKViewKeyboardReactionHandler)handler __attribute__((nonnull(1)));
- (void) fk_reactToKeyboardWithAnimationHandler:(void (^)(BOOL keyboardWillShow))handler __attribute__((nonnull(1)));
- (void) fk_stopReactingToKeyboard;

@end
