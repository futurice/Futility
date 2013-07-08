//
//  FKThirdPartyApps.m
//  FuKit
//
//  Created by Ali Rantakari on 13.12.2012.
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

#import "FKThirdPartyApps.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#warning "This file must be compiled with ARC enabled"
#endif


static BOOL canOpenURL(NSString *urlString)
{
    return [UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:urlString]];
}
static BOOL openURL(NSURL *url)
{
    return [UIApplication.sharedApplication openURL:url];
}

static NSURL *urlByChangingScheme(NSURL *url, NSString *newScheme)
{
    NSMutableString *s = [NSMutableString stringWithCapacity:100];
    
    // [NSURL -path] strips possible trailing slashes, CFURLCopyPath() does not:
    NSString *path = (NSString *)CFBridgingRelease(CFURLCopyPath((__bridge CFURLRef)url));
    
    if (newScheme != nil && 0 < newScheme.length)
        [s appendFormat:@"%@://", newScheme];
    if (url.host != nil && 0 < url.host.length)
        [s appendString:url.host];
    if (url.port != nil)
        [s appendFormat:@":%@", url.port];
    if (path != nil && 0 < path.length)
        [s appendString:path];
    if (url.query != nil && 0 < url.query.length)
        [s appendFormat:@"?%@", url.query];
    
    return [NSURL URLWithString:s];
}

static NSString *urlEncoded(NSString *str)
{
	CFStringRef ref = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                              (__bridge CFStringRef)str,
                                                              NULL,
                                                              (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                              CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return (NSString *)CFBridgingRelease(ref);
}



@interface FKApp : NSObject
- (NSString *) appStoreId;
- (NSString *) name;
- (BOOL) isInstalled;
- (void) handleOpaqueValue:(id)value;
@end
@implementation FKApp
- (NSString *) appStoreId { return nil; }
- (NSString *) name { return nil; }
- (BOOL) isInstalled { return NO; }
- (void) handleOpaqueValue:(id)value {}
@end


// Web browsers
//
@interface FKWebBrowserApp : FKApp
- (BOOL) canOpenURL:(NSURL *)url;
- (void) openURL:(NSURL *)url;
@end
@implementation FKWebBrowserApp
- (BOOL) canOpenURL:(NSURL *)url { return NO; }
- (void) openURL:(NSURL *)url {}
- (void) handleOpaqueValue:(id)value {
    if ([value isKindOfClass:[NSURL class]])
        [self openURL:(NSURL *)value];
}
@end

@interface FKWebBrowserAppSafari : FKWebBrowserApp
@end
@implementation FKWebBrowserAppSafari
- (NSString *) name { return @"Safari"; }
- (BOOL) isInstalled { return YES; }
- (BOOL) canOpenURL:(NSURL *)url {
    return [@[@"http", @"https"] containsObject:url.scheme.lowercaseString];
}
- (void) openURL:(NSURL *)url {
    openURL(url);
}
@end

@interface FKWebBrowserAppGoogleChrome : FKWebBrowserApp
@end
@implementation FKWebBrowserAppGoogleChrome
- (NSString *) name { return @"Google Chrome"; }
- (NSString *) appStoreId { return @"535886823"; }
- (BOOL) isInstalled { return canOpenURL(@"googlechrome://"); }
- (BOOL) canOpenURL:(NSURL *)url {
    return [@[@"http", @"https"] containsObject:url.scheme.lowercaseString];
}
- (void) openURL:(NSURL *)url {
    openURL(urlByChangingScheme(url, ([url.scheme.lowercaseString isEqualToString:@"http"]
                                      ? @"googlechrome" : @"googlechromes")));
}
@end

@interface FKWebBrowserAppOperaMini : FKWebBrowserApp
@end
@implementation FKWebBrowserAppOperaMini
- (NSString *) name { return @"Opera Mini"; }
- (NSString *) appStoreId { return @"363729560"; }
- (BOOL) isInstalled { return canOpenURL(@"ohttp://"); }
- (BOOL) canOpenURL:(NSURL *)url {
    return [@[@"http", @"https", @"ftp"] containsObject:url.scheme.lowercaseString];
}
- (void) openURL:(NSURL *)url {
    openURL(urlByChangingScheme(url, [@"o" stringByAppendingString:url.scheme]));
}
@end


// Maps apps
//
@interface FKMapsApp : FKApp
- (void) openWithSearch:(NSString *)searchQuery;
@end
@implementation FKMapsApp
- (void) openWithSearch:(NSString *)searchQuery {}
- (void) handleOpaqueValue:(id)value {
    if ([value isKindOfClass:[NSString class]])
        [self openWithSearch:(NSString *)value];
}
@end

@interface FKMapsAppAppleMaps : FKMapsApp
@end
@implementation FKMapsAppAppleMaps
- (NSString *) name { return @"Maps"; } // TODO: should localize
- (BOOL) isInstalled { return YES; }
- (void) openWithSearch:(NSString *)searchQuery {
    openURL([NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/maps?q=%@", urlEncoded(searchQuery)]]);
}
@end

@interface FKMapsAppGoogleMaps : FKMapsApp
@end
@implementation FKMapsAppGoogleMaps
- (NSString *) name { return @"Google Maps"; } // TODO: should localize?
- (NSString *) appStoreId { return @"585027354"; }
- (BOOL) isInstalled { return canOpenURL(@"comgooglemaps://"); }
- (void) openWithSearch:(NSString *)searchQuery {
    openURL([NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?q=%@", urlEncoded(searchQuery)]]);
}
@end

@interface FKMapsAppNokiaHere : FKMapsApp
@end
@implementation FKMapsAppNokiaHere
- (NSString *) name { return @"HERE Maps"; }
- (NSString *) appStoreId { return @"577430143"; }
- (BOOL) isInstalled { return canOpenURL(@"nok://"); }
- (void) openWithSearch:(NSString *)searchQuery {
    // TODO: The URL scheme is "nok", but what is the URL format supposed to be for searches?
    openURL([NSURL URLWithString:[NSString stringWithFormat:@"nok://search/%@", urlEncoded(searchQuery)]]);
}
@end


static NSArray *getBrowserApps()
{
    return @[
    [[FKWebBrowserAppSafari alloc] init],
    [[FKWebBrowserAppGoogleChrome alloc] init],
    [[FKWebBrowserAppOperaMini alloc] init],
    ];
}

static NSArray *getMapsApps()
{
    return @[
    [[FKMapsAppAppleMaps alloc] init],
    [[FKMapsAppGoogleMaps alloc] init],
    //[[FKMapsAppNokiaHere alloc] init],
    ];
}


static void *kFKSheetAppsAssociationKey = (void *)&kFKSheetAppsAssociationKey;
static void *kFKSheetTargetValueAssociationKey = (void *)&kFKSheetTargetValueAssociationKey;

@class FKAppActionSheetDelegate;
static FKAppActionSheetDelegate *sheetDelegate;

@interface FKAppActionSheetDelegate : NSObject <UIActionSheetDelegate>
@end
@implementation FKAppActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    NSArray *sheetApps = objc_getAssociatedObject(actionSheet, kFKSheetAppsAssociationKey);
    NSObject *targetValue = objc_getAssociatedObject(actionSheet, kFKSheetTargetValueAssociationKey);
    objc_setAssociatedObject(actionSheet, kFKSheetAppsAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(actionSheet, kFKSheetTargetValueAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    for (FKApp *app in sheetApps)
    {
        if ([app.name isEqualToString:buttonTitle])
        {
            [app handleOpaqueValue:targetValue];
            return;
        }
    }
}
@end



static void presentAppChoice(NSArray *apps, id targetValue, UIView *sheetParentView, NSString *sheetTitle, NSString *sheetCancelButtonTitle)
{
    
    if (sheetDelegate == nil)
        sheetDelegate = [[FKAppActionSheetDelegate alloc] init];
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:sheetTitle
                            delegate:sheetDelegate
                            cancelButtonTitle:nil
                            destructiveButtonTitle:nil
                            otherButtonTitles:nil];
    
    for (FKApp *app in apps)
    {
        [sheet addButtonWithTitle:app.name];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:sheetCancelButtonTitle];
    
    objc_setAssociatedObject(sheet, kFKSheetAppsAssociationKey, apps, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(sheet, kFKSheetTargetValueAssociationKey, targetValue, OBJC_ASSOCIATION_COPY);
    
    if ([sheetParentView isKindOfClass:[UITabBar class]])
        [sheet showFromTabBar:(UITabBar *)sheetParentView];
    else if ([sheetParentView isKindOfClass:[UIToolbar class]])
        [sheet showFromToolbar:(UIToolbar *)sheetParentView];
    else if ([sheetParentView isKindOfClass:[UIBarButtonItem class]])
        [sheet showFromBarButtonItem:(UIBarButtonItem *)sheetParentView animated:YES];
    else
        [sheet showInView:sheetParentView];
}

void fk_openURLInAnyBrowser(NSURL *url, UIView *sheetParentView, NSString *sheetTitle, NSString *sheetCancelButtonTitle)
{
    NSURL *urlToOpen = url;
    if (urlToOpen.scheme == nil || 0 == urlToOpen.scheme.length)
        urlToOpen = urlByChangingScheme(urlToOpen, @"http");
    
    NSMutableArray *availableBrowsers = [NSMutableArray arrayWithCapacity:10];
    for (FKWebBrowserApp *browser in getBrowserApps())
    {
        if (browser.isInstalled && [browser canOpenURL:url])
            [availableBrowsers addObject:browser];
    }
    
    if (availableBrowsers.count == 0)
        return;
    
    if (availableBrowsers.count == 1)
    {
        [(FKWebBrowserApp *)availableBrowsers.lastObject openURL:url];
        return;
    }
    
    presentAppChoice(availableBrowsers, urlToOpen, sheetParentView, sheetTitle, sheetCancelButtonTitle);
}

void fk_openSearchInAnyMapsApp(NSString *mapSearchQuery, UIView *sheetParentView, NSString *sheetTitle, NSString *sheetCancelButtonTitle)
{
    NSMutableArray *availableMapsApps = [NSMutableArray arrayWithCapacity:10];
    for (FKMapsApp *mapsApp in getMapsApps())
    {
        if (mapsApp.isInstalled)
            [availableMapsApps addObject:mapsApp];
    }
    
    if (availableMapsApps.count == 0)
        return;
    
    if (availableMapsApps.count == 1)
    {
        [(FKMapsApp *)availableMapsApps.lastObject openWithSearch:mapSearchQuery];
        return;
    }
    
    presentAppChoice(availableMapsApps, mapSearchQuery, sheetParentView, sheetTitle, sheetCancelButtonTitle);
}


