//
//  UIViewController+FKSplashScreenAnimation.m
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

#import "UIViewController+FKSplashScreenAnimation.h"

#if __has_feature(objc_arc)
#define FK_RELEASE(__a)
#define FK_RETAIN(__a) __a
#define FK_AUTORELEASE(__a) __a
#else
#define FK_RELEASE(__a) [(__a) release]
#define FK_RETAIN(__a) [(__a) retain]
#define FK_AUTORELEASE(__a) [(__a) autorelease]
#endif


@implementation UIViewController (FKSplashScreenAnimation)

- (UIImageView *) fk_addSplashScreenPlaceholderToWindow
{
    BOOL isFourInchScreen = fabs(568 - UIScreen.mainScreen.bounds.size.height) < 0.1;
    UIImage *splashImage = [UIImage imageNamed:(isFourInchScreen ? @"Default-568h" : @"Default")];
    
    UIImageView *splash = FK_AUTORELEASE([[UIImageView alloc] initWithImage:splashImage]);
    splash.layer.shouldRasterize = YES;
    
    UIWindow *win = UIApplication.sharedApplication.keyWindow;
    splash.frame = CGRectMake(0, 0, win.frame.size.width, win.frame.size.height);
    [win addSubview:splash];
    
    return splash;
}

#define CHANGE_Y(__view, __y) (__view).frame = CGRectMake((__view).frame.origin.x, (__y), (__view).frame.size.width, (__view).frame.size.height)
#define CHANGE_X(__view, __x) (__view).frame = CGRectMake((__x), (__view).frame.origin.y, (__view).frame.size.width, (__view).frame.size.height)
#define ANIMATION_IS_USED(__animationsBitfield, __animationBit) (((__animationsBitfield) & (__animationBit)) != 0)

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

- (UIImageView *) fk_animateSplashScreenRemovalWithDuration:(NSTimeInterval)duration
                                                 animations:(int)animations
                                                 completion:(void(^)(BOOL finished))completion;
{
    if (animations == FKSplashScreenAnimation_None)
        return nil;
    
    UIImageView *splash = [self fk_addSplashScreenPlaceholderToWindow];
    
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
    
    return splash;
}

@end
