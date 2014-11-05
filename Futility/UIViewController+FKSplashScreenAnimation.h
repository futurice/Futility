//
//  UIViewController+FKSplashScreenAnimation.h
//  Requires iOS 4.3+
//
//  Created by Ali Rantakari on 14.12.2012.
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

typedef NS_OPTIONS(NSUInteger, FKSplashScreenAnimation)
{
    FKSplashScreenAnimation_None = 0,
    FKSplashScreenAnimation_SlideUp =    (1 << 0),
    FKSplashScreenAnimation_SlideDown =  (1 << 1),
    FKSplashScreenAnimation_SlideLeft =  (1 << 2),
    FKSplashScreenAnimation_SlideRight = (1 << 3),
    FKSplashScreenAnimation_FadeOut =    (1 << 4),
    FKSplashScreenAnimation_ZoomCloser = (1 << 5),
    FKSplashScreenAnimation_ZoomViewUnderneath = (1 << 6),
};

@interface UIViewController (FKSplashScreenAnimation)

// Animates the removal of the splash screen.
//
// Call this in the main UIViewController's -viewDidAppear: when
// it is called the first time during the lifetime of the app (you
// can use fk_splashScreenHasBeenAnimated for this).
//
// You may also call -fk_createSplashScreenWindow in -viewDidLoad
// to ensure that the splash screen placeholder is in place when
// the system removes the actual default image from the screen.
//
// The `animations` argument accepts an OR-ed bitfield of values from the
// FKSplashScreenAnimation enumeration.
//
- (UIImageView *) fk_animateSplashScreenRemovalWithDuration:(NSTimeInterval)duration
                                                 animations:(NSUInteger)animations
                                                 completion:(void(^)(BOOL finished))completion;

// Creates a temporary UIWindow that contains the splash screen image.
//
- (void) fk_createSplashScreenWindow;

// Returns the splash screen placeholder image in the window.
//
// You can use this to perform animations for it manually.
// Remember to remove the UIWindow from its superview when
// you are done animating it.
//
- (UIImageView *) fk_splashScreenPlaceholder;

// Global state for whether the animation has already been
// performed.
//
- (BOOL) fk_splashScreenHasBeenAnimated;

@end
