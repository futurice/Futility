//
//  UIViewController+FKSplashScreenAnimation.m
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

#import "UIViewController+FKSplashScreenAnimation.h"
#import <QuartzCore/QuartzCore.h>

#if !__has_feature(objc_arc)
#warning "This file must be compiled with ARC enabled"
#endif


@implementation UIViewController (FKSplashScreenAnimation)

#define SPLASH_PLACEHOLDER_TAG 77177171

static UIWindow *splashWindow;

- (void) fk_createSplashScreenWindow
{
    if (splashWindow)
        return;

    // Instantiating a UIWindow adds it to the app automatically.
    //
    CGSize keyWindowSize = UIApplication.sharedApplication.keyWindow.frame.size;
    splashWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, keyWindowSize.width, keyWindowSize.height)];
    splashWindow.backgroundColor = UIColor.clearColor;
    splashWindow.alpha = 1;
    splashWindow.windowLevel = UIWindowLevelStatusBar - 1;
    splashWindow.hidden = NO;
    splashWindow.rootViewController = [[UIViewController alloc] init];

    BOOL isFourInchScreen = fabs(568 - UIScreen.mainScreen.bounds.size.height) < 0.1;
    UIImageView *splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isFourInchScreen ? @"Default-568h" : @"Default")]];
    splash.layer.shouldRasterize = YES;
    splash.layer.rasterizationScale = UIScreen.mainScreen.scale;
    splash.tag = SPLASH_PLACEHOLDER_TAG;

    splash.frame = CGRectMake(0, 0, splashWindow.frame.size.width, splashWindow.frame.size.height);
    splashWindow.rootViewController.view.frame = splash.bounds;
    [splashWindow.rootViewController.view addSubview:splash];
}

- (UIImageView *) fk_splashScreenPlaceholder
{
    return (UIImageView *)[splashWindow.rootViewController.view viewWithTag:SPLASH_PLACEHOLDER_TAG];
}

#define CHANGE_Y(_view, _y) (_view).frame = CGRectMake((_view).frame.origin.x, (_y), (_view).frame.size.width, (_view).frame.size.height)
#define CHANGE_X(_view, _x) (_view).frame = CGRectMake((_x), (_view).frame.origin.y, (_view).frame.size.width, (_view).frame.size.height)
#define ANIMATION_IS_USED(_animationsBitfield, _animationBit) ((_animationsBitfield) & (_animationBit))

static BOOL animationIncludesSliding(int animations)
{
    return (ANIMATION_IS_USED(animations, FKSplashScreenAnimation_SlideUp)
            || ANIMATION_IS_USED(animations, FKSplashScreenAnimation_SlideDown)
            || ANIMATION_IS_USED(animations, FKSplashScreenAnimation_SlideLeft)
            || ANIMATION_IS_USED(animations, FKSplashScreenAnimation_SlideRight)
            );
}

- (void) fk_prepareAnimations:(int)animations forView:(UIView *)splashView
{
    if (animationIncludesSliding(animations))
    {
        splashView.layer.shadowColor = UIColor.blackColor.CGColor;
        splashView.layer.shadowOffset = CGSizeMake(0, 0);
        splashView.layer.shadowOpacity = 0.6;
        splashView.layer.shadowRadius = 10;
        splashView.layer.shadowPath = [UIBezierPath bezierPathWithRect:splashView.bounds].CGPath;
    }

    if (ANIMATION_IS_USED(animations, FKSplashScreenAnimation_ZoomViewUnderneath))
    {
        self.view.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.view.alpha = 0.5;
    }
}

- (void) fk_performAnimations:(int)animations forView:(UIView *)splashView
{
    if (ANIMATION_IS_USED(animations, FKSplashScreenAnimation_SlideUp))
        CHANGE_Y(splashView, -(splashView.frame.size.height + splashView.layer.shadowRadius));
    else if (ANIMATION_IS_USED(animations, FKSplashScreenAnimation_SlideDown))
        CHANGE_Y(splashView, (splashView.frame.size.height + splashView.layer.shadowRadius));
    else if (ANIMATION_IS_USED(animations, FKSplashScreenAnimation_SlideLeft))
        CHANGE_X(splashView, -(splashView.frame.size.width + splashView.layer.shadowRadius));
    else if (ANIMATION_IS_USED(animations, FKSplashScreenAnimation_SlideRight))
        CHANGE_X(splashView, (splashView.frame.size.width + splashView.layer.shadowRadius));

    if (ANIMATION_IS_USED(animations, FKSplashScreenAnimation_FadeOut))
        splashView.alpha = 0;

    if (ANIMATION_IS_USED(animations, FKSplashScreenAnimation_ZoomCloser))
    {
        splashView.transform = CGAffineTransformMakeScale(2, 2);
        splashView.alpha = 0;
    }

    if (ANIMATION_IS_USED(animations, FKSplashScreenAnimation_ZoomViewUnderneath))
    {
        self.view.transform = CGAffineTransformMakeScale(1, 1);
        self.view.alpha = 1.0;
    }
}

- (void) fk_completeAnimations:(int)animations forView:(UIView *)splashView
{
    self.view.transform = CGAffineTransformIdentity;
}

static BOOL splashScreenHasBeenAnimated = NO;
- (BOOL) fk_splashScreenHasBeenAnimated
{
    return splashScreenHasBeenAnimated;
}

- (UIImageView *) fk_animateSplashScreenRemovalWithDuration:(NSTimeInterval)duration
                                                 animations:(int)animations
                                                 completion:(void(^)(BOOL finished))completion
{
    if (animations == FKSplashScreenAnimation_None)
        return nil;

    [self fk_createSplashScreenWindow];
    UIImageView *splash = [self fk_splashScreenPlaceholder];

    [self fk_prepareAnimations:animations forView:splash];
    [UIView
     animateWithDuration:duration
     animations:^{
         [self fk_performAnimations:animations forView:splash];
     }
     completion:^(BOOL finished) {
         [self fk_completeAnimations:animations forView:splash];
         [splashWindow removeFromSuperview];
         splashWindow = nil;
         if (completion)
             completion(finished);
     }];

    splashScreenHasBeenAnimated = YES;
    return splash;
}

@end
