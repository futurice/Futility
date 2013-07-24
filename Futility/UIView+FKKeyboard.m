//
//  UIView+FKKeyboard.m
//  Futility
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

#import "UIView+FKKeyboard.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#warning "This file must be compiled with ARC enabled"
#endif

// We use a separate observer object because we want to make sure that when the
// UIView gets deallocated, we remove the observer from the notification center.
//
// We cannot do that in the UIView dealloc, because categories cannot add
// dealloc behavior directly. So we create this separate observer object and
// add it to the view using the associated object API. This object will
// then get deallocated when the host UIView gets deallocated, and we can
// react to this by detaching the observer.
//
@interface FKViewKeyboardObserver : NSObject
@property(retain) NSMutableArray *observers;
@property(retain) NSTimer *throttlingTimer;
@property(retain) UIView *view;
@property(copy) FKViewKeyboardReactionHandler handler;
@property(assign) NSTimeInterval throttlingInterval;
@end
@implementation FKViewKeyboardObserver

- (BOOL) viewIsObscured:(UIView *)view byScreenRect:(CGRect)rectInScreenCoords
{
    if (view.superview == nil)
        return NO;

    CGRect viewFrameInScreenCoords = [UIApplication.sharedApplication.keyWindow
                                      convertRect:[view.superview convertRect:view.frame toView:nil]
                                      toWindow:nil];
    return CGRectIntersectsRect(rectInScreenCoords, viewFrameInScreenCoords);
}

- (void) handleKeyboardForView:(UIView *)view withHandler:(FKViewKeyboardReactionHandler)handler throttlingInterval:(NSTimeInterval)interval
{
    self.view = view;
    self.handler = handler;
    self.throttlingInterval = interval;

    [NSNotificationCenter.defaultCenter
     addObserver:self
     selector:@selector(didReceiveKeyboardNotification:)
     name:UIKeyboardWillShowNotification
     object:nil];
    [NSNotificationCenter.defaultCenter
     addObserver:self
     selector:@selector(didReceiveKeyboardNotification:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void) didReceiveKeyboardNotification:(NSNotification *)note
{
    if (self.throttlingTimer)
        [self.throttlingTimer invalidate];
    self.throttlingTimer = [NSTimer
                            scheduledTimerWithTimeInterval:self.throttlingInterval
                            target:self
                            selector:@selector(throttlingTimerDidFire:)
                            userInfo:note
                            repeats:NO];
}

- (void) throttlingTimerDidFire:(NSTimer *)timer
{
    NSNotification *note = timer.userInfo;
    if ([note.name isEqualToString:UIKeyboardWillShowNotification])
    {
        self.handler(note,
                     YES,
                     [self
                      viewIsObscured:self.view
                      byScreenRect:[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]]);
    }
    else
    {
        self.handler(note, NO, NO);
    }
}

- (void) dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end

@implementation UIView (FKKeyboard)

static void *kFKObserverAssociationKey = (void *)&kFKObserverAssociationKey;

- (void) fk_reactToKeyboardWithHandler:(FKViewKeyboardReactionHandler)handler throttlingInterval:(NSTimeInterval)interval
{
    FKViewKeyboardObserver *observer = [[FKViewKeyboardObserver alloc] init];
    [observer handleKeyboardForView:self withHandler:handler throttlingInterval:interval];
    objc_setAssociatedObject(self, kFKObserverAssociationKey, observer, OBJC_ASSOCIATION_RETAIN);
}

- (void) fk_stopReactingToKeyboard
{
    objc_setAssociatedObject(self, kFKObserverAssociationKey, nil, OBJC_ASSOCIATION_RETAIN);
}

- (void) fk_reactToKeyboardWithAnimationHandler:(void (^)(BOOL keyboardWillShow))handler
{
    // When you press the `x` button on a text field to clear its value, the keyboard
    // hides and shows again in quick succession. To avoid reacting to these, we
    // throttle the events with a short interval.
    //
    __block BOOL hasAnimatedDueToKeyboard = NO;
    [self fk_reactToKeyboardWithHandler:^(NSNotification *note, BOOL keyboardWillShow, BOOL willBeObscuredByKeyboard) {
        if ((keyboardWillShow && willBeObscuredByKeyboard)
            || (!keyboardWillShow && hasAnimatedDueToKeyboard))
        {
            hasAnimatedDueToKeyboard = keyboardWillShow;
            [UIView
             animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
             delay:0
             options:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]
             animations:^{
                 handler(keyboardWillShow);
             }
             completion:NULL];
        }
    } throttlingInterval:0.1];
}

@end
