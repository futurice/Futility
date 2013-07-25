//
//  UIView+FKKeyboard.m
//
//  Created by Ali Rantakari on 26.3.2013.
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
