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

typedef enum
{
    FKSplashScreenAnimation_None = 0,
    FKSplashScreenAnimation_SlideUp =    (1 << 0),
    FKSplashScreenAnimation_SlideDown =  (1 << 1),
    FKSplashScreenAnimation_SlideLeft =  (1 << 2),
    FKSplashScreenAnimation_SlideRight = (1 << 3),
    FKSplashScreenAnimation_FadeOut =    (1 << 4),
    FKSplashScreenAnimation_ZoomCloser = (1 << 5),
    FKSplashScreenAnimation_ZoomViewUnderneath = (1 << 6),
}
FKSplashScreenAnimation;

@interface UIViewController (FKSplashScreenAnimation)

// Animates the removal of the splash screen by adding a UIImageView with
// the splash screen image into the window and then animating that off
// the screen somehow.
//
// Call this in the main UIViewController's -viewDidAppear: when
// it is called the first time during the lifetime of the app.
//
// The `animations` argument accepts an OR-ed bitfield of values from the
// FKSplashScreenAnimation enumeration.
//
- (UIImageView *) fk_animateSplashScreenRemovalWithDuration:(NSTimeInterval)duration
                                                 animations:(int)animations
                                                 completion:(void(^)(BOOL finished))completion;

// Creates the splash screen image and adds it to the window.
// You can use this to perform animations for it manually.
//
// Remember to remove the image view from its superview when
// you are done animating it.
//
- (UIImageView *) fk_addSplashScreenPlaceholderToWindow;

@end
