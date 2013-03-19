//
//  UIViewController+FKSplashScreenAnimation.m
//  Requires iOS 4.3+
//
//  Created by Ali Rantakari on 14.12.2012.
//
/*
 The MIT License
 
 Copyright (c) 2012-2013 Futurice
 
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

#import "UIViewController+FKSplashScreenAnimation.h"

#if !__has_feature(objc_arc)
#warning "This file must be compiled with ARC enabled"
#endif


@implementation UIViewController (FKSplashScreenAnimation)

#define SPLASH_PLACEHOLDER_TAG 77177171

- (UIImageView *) fk_splashScreenPlaceholder
{
    UIWindow *win = UIApplication.sharedApplication.keyWindow;
    UIImageView *splash = (UIImageView *)[win viewWithTag:SPLASH_PLACEHOLDER_TAG];
    if (splash)
        return splash;
    
    BOOL isFourInchScreen = fabs(568 - UIScreen.mainScreen.bounds.size.height) < 0.1;
    UIImage *splashImage = [UIImage imageNamed:(isFourInchScreen ? @"Default-568h" : @"Default")];
    
    splash = [[UIImageView alloc] initWithImage:splashImage];
    splash.layer.shouldRasterize = YES;
    splash.layer.rasterizationScale = UIScreen.mainScreen.scale;
    splash.tag = SPLASH_PLACEHOLDER_TAG;
    
    splash.frame = CGRectMake(0, 0, win.frame.size.width, win.frame.size.height);
    [win addSubview:splash];
    
    return splash;
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
    
    UIImageView *splash = [self fk_splashScreenPlaceholder];
    
    [self fk_prepareAnimations:animations forView:splash];
    [UIView
     animateWithDuration:duration
     animations:^{
         [self fk_performAnimations:animations forView:splash];
     }
     completion:^(BOOL finished) {
         [self fk_completeAnimations:animations forView:splash];
         [splash removeFromSuperview];
         if (completion)
             completion(finished);
     }];
    
    splashScreenHasBeenAnimated = YES;
    return splash;
}

@end
