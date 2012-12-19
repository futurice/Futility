//
//  UIViewController+FKSplashScreenAnimation.h
//  Requires iOS 4.3+
//
//  Created by Ali Rantakari on 14.12.2012.
//
/*
 The MIT License
 
 Copyright (c) 2012 Futurice
 
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

typedef NS_OPTIONS(unsigned int, FKSplashScreenAnimation)
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

// Animates the removal of the splash screen by adding a UIImageView with
// the splash screen image into the window and then animating that off
// the screen somehow.
//
// Call this in the main UIViewController's -viewDidAppear: when
// it is called the first time during the lifetime of the app (you
// can use fk_splashScreenHasBeenAnimated for this).
//
// You may also call -fk_splashScreenPlaceholder in -viewDidLoad
// to ensure that the splash screen placeholder is in place when
// the system removes the actual default image from the screen.
//
// The `animations` argument accepts an OR-ed bitfield of values from the
// FKSplashScreenAnimation enumeration.
//
- (UIImageView *) fk_animateSplashScreenRemovalWithDuration:(NSTimeInterval)duration
                                                 animations:(int)animations
                                                 completion:(void(^)(BOOL finished))completion;

// Returns the splash screen placeholder image in the window.
//
// Creates it and adds it to the window, if it does not exist.
// You can use this to perform animations for it manually.
//
// Remember to remove the image view from its superview when
// you are done animating it.
//
- (UIImageView *) fk_splashScreenPlaceholder;

// Global state for whether the animation has already been
// performed.
//
- (BOOL) fk_splashScreenHasBeenAnimated;

@end
