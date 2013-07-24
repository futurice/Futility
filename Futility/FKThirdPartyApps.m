//
//  FKThirdPartyApps.m
//  Futility
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
- (void) offerToInstall;
- (void) handleOpaqueValue:(id)value;
@end
@implementation FKApp
- (NSString *) appStoreId { return nil; }
- (NSString *) name { return nil; }
- (BOOL) isInstalled { return NO; }
- (void) handleOpaqueValue:(id)value {}
- (void) offerToInstall {
    openURL([NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", self.appStoreId]]);
}
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
- (BOOL) supportsNavigationMode:(FKMapsAppNavigationMode)mode;
- (void) openWithNavigationFromAddress:(NSString *)from toAddress:(NSString *)to navigationMode:(FKMapsAppNavigationMode)mode;
- (void) openWithNavigationFromPlacemark:(MKPlacemark *)from toPlacemark:(MKPlacemark *)to navigationMode:(FKMapsAppNavigationMode)mode;
@end
@implementation FKMapsApp
- (void) openWithSearch:(NSString *)searchQuery {}
- (BOOL) supportsNavigationMode:(FKMapsAppNavigationMode)mode { return NO; }
- (void) openWithNavigationFromAddress:(NSString *)from toAddress:(NSString *)to navigationMode:(FKMapsAppNavigationMode)mode {}
- (void) openWithNavigationFromPlacemark:(MKPlacemark *)from toPlacemark:(MKPlacemark *)to navigationMode:(FKMapsAppNavigationMode)mode {}
- (void) handleOpaqueValue:(id)value {
    if ([value isKindOfClass:[NSString class]])
        [self openWithSearch:(NSString *)value];
}
@end

@interface FKMapsAppAppleMaps : FKMapsApp
@end
@implementation FKMapsAppAppleMaps
- (NSString *) name { return @"Apple Maps"; } // TODO: should localize
- (BOOL) isInstalled { return YES; }
- (void) openWithSearch:(NSString *)searchQuery {
    openURL([NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/maps?q=%@", urlEncoded(searchQuery ?: @"")]]);
}
- (NSString *) parameterForNavigationMode:(FKMapsAppNavigationMode)mode {
    switch (mode) {
        case FKMapsAppNavigationMode_Drive: return MKLaunchOptionsDirectionsModeDriving;
        case FKMapsAppNavigationMode_Walk: return MKLaunchOptionsDirectionsModeWalking;
        case FKMapsAppNavigationMode_Transit: return nil;
        case FKMapsAppNavigationMode_None: return nil;
    }
}
- (BOOL) supportsNavigationMode:(FKMapsAppNavigationMode)mode { return ([self parameterForNavigationMode:mode] != nil); }
- (void) openWithNavigationFromAddress:(NSString *)from toAddress:(NSString *)to navigationMode:(FKMapsAppNavigationMode)mode {
    openURL([NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%@&daddr=%@",
                                  urlEncoded(from ?: @""), urlEncoded(to ?: @"")]]);
}
- (void) openWithNavigationFromPlacemark:(MKPlacemark *)from toPlacemark:(MKPlacemark *)to navigationMode:(FKMapsAppNavigationMode)mode {
    MKMapItem *fromItem = from ? [[MKMapItem alloc] initWithPlacemark:from] : [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toItem = to ? [[MKMapItem alloc] initWithPlacemark:to] : [MKMapItem mapItemForCurrentLocation];
    [MKMapItem openMapsWithItems:@[fromItem, toItem] launchOptions:@{
     MKLaunchOptionsDirectionsModeKey: [self parameterForNavigationMode:mode],
     }];
}
@end

@interface FKMapsAppGoogleMaps : FKMapsApp
@end
@implementation FKMapsAppGoogleMaps
- (NSString *) name { return @"Google Maps"; } // TODO: should localize?
- (NSString *) appStoreId { return @"585027354"; }
- (BOOL) isInstalled { return canOpenURL(@"comgooglemaps://"); }
- (void) openWithSearch:(NSString *)searchQuery {
    openURL([NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?q=%@", urlEncoded(searchQuery ?: @"")]]);
}
- (NSString *) parameterForNavigationMode:(FKMapsAppNavigationMode)mode {
    switch (mode) {
        case FKMapsAppNavigationMode_Drive: return @"driving";
        case FKMapsAppNavigationMode_Walk: return @"walking";
        case FKMapsAppNavigationMode_Transit: return @"transit";
        case FKMapsAppNavigationMode_None: return nil;
    }
}
- (BOOL) supportsNavigationMode:(FKMapsAppNavigationMode)mode { return ([self parameterForNavigationMode:mode] != nil); }
- (void) openWithNavigationFromAddress:(NSString *)from toAddress:(NSString *)to navigationMode:(FKMapsAppNavigationMode)mode {
    openURL([NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&directionsmode=%@",
                                  urlEncoded(from ?: @""), urlEncoded(to ?: @""),
                                  urlEncoded([self parameterForNavigationMode:mode])]]);
}
+ (NSString *) parameterFromPlacemark:(MKPlacemark *)placemark
{
    if (placemark == nil)
        return nil;
    // Prefer address format
    if (placemark.addressDictionary) {
        NSDictionary *dict = placemark.addressDictionary;
        NSArray *addressParts = @[
                                  dict[(NSString*)kABPersonAddressStreetKey] ?: @"",
                                  FMT(@"%@ %@", dict[(NSString*)kABPersonAddressZIPKey], dict[(NSString*)kABPersonAddressCityKey]) ?: @"",
                                  dict[(NSString*)kABPersonAddressCountryKey] ?: @"",
                                  ];
        BOOL allPartsExist = YES;
        for (NSString *part in addressParts) {
            if ([part stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length == 0) {
                allPartsExist = NO;
                break;
            }
        }
        if (allPartsExist)
            return [addressParts componentsJoinedByString:@", "];
    }
    // Otherwise use coordinate format (shows as such in the Google Maps UI)
    return [NSString stringWithFormat:@"%f,%f", placemark.coordinate.latitude, placemark.coordinate.longitude];
}
- (void) openWithNavigationFromPlacemark:(MKPlacemark *)from toPlacemark:(MKPlacemark *)to navigationMode:(FKMapsAppNavigationMode)mode {
    openURL([NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&directionsmode=%@",
                                  urlEncoded([self.class parameterFromPlacemark:from] ?: @""),
                                  urlEncoded([self.class parameterFromPlacemark:to] ?: @""),
                                  urlEncoded([self parameterForNavigationMode:mode])]]);
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
    openURL([NSURL URLWithString:[NSString stringWithFormat:@"nok://search/%@", urlEncoded(searchQuery ?: @"")]]);
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
static void *kFKSheetHandlerAssociationKey = (void *)&kFKSheetHandlerAssociationKey;
typedef void(^FKSheetHandler)(FKApp *app);

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
    FKSheetHandler handler = objc_getAssociatedObject(actionSheet, kFKSheetHandlerAssociationKey);
    objc_setAssociatedObject(actionSheet, kFKSheetAppsAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(actionSheet, kFKSheetHandlerAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);

    for (FKApp *app in sheetApps)
    {
        if ([app.name isEqualToString:buttonTitle])
        {
            handler(app);
            return;
        }
    }
}
@end



static void presentAppChoice(NSArray *apps, UIView *sheetParentView, NSString *sheetTitle, NSString *sheetCancelButtonTitle, FKSheetHandler handler)
{
    if (apps.count == 0)
        return;

    if (apps.count == 1)
    {
        handler(apps.lastObject);
        return;
    }

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
    objc_setAssociatedObject(sheet, kFKSheetHandlerAssociationKey, handler, OBJC_ASSOCIATION_COPY);

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

    presentAppChoice(availableBrowsers, sheetParentView, sheetTitle, sheetCancelButtonTitle, ^void(FKApp *selectedApp){
        [(FKWebBrowserApp *)selectedApp openURL:urlToOpen];
    });
}

void fk_openSearchInAnyMapsApp(NSString *mapSearchQuery, UIView *sheetParentView, NSString *sheetTitle, NSString *sheetCancelButtonTitle)
{
    NSMutableArray *availableMapsApps = [NSMutableArray arrayWithCapacity:10];
    for (FKMapsApp *mapsApp in getMapsApps())
    {
        if (mapsApp.isInstalled)
            [availableMapsApps addObject:mapsApp];
    }

    presentAppChoice(availableMapsApps, sheetParentView, sheetTitle, sheetCancelButtonTitle, ^void(FKApp *selectedApp){
        [(FKMapsApp *)selectedApp openWithSearch:mapSearchQuery];
    });
}

void fk_showDirectionsInAnyMapsApp(MKPlacemark *source,
                                   MKPlacemark *destination,
                                   FKMapsAppNavigationMode navigationMode,
                                   BOOL showNonInstalledApps,
                                   UIView *sheetParentView,
                                   NSString *sheetTitle,
                                   NSString *sheetCancelButtonTitle)
{
    NSMutableArray *availableMapsApps = [NSMutableArray arrayWithCapacity:10];
    for (FKMapsApp *mapsApp in getMapsApps())
    {
        if (!showNonInstalledApps && !mapsApp.isInstalled)
            continue;
        if ([mapsApp supportsNavigationMode:navigationMode])
            [availableMapsApps addObject:mapsApp];
    }

    presentAppChoice(availableMapsApps, sheetParentView, sheetTitle, sheetCancelButtonTitle, ^void(FKApp *selectedApp) {
        FKMapsApp *selectedMapsApp = (FKMapsApp *)selectedApp;

        if (!selectedMapsApp.isInstalled)
        {
            [selectedMapsApp offerToInstall];
            return;
        }

        [selectedMapsApp
         openWithNavigationFromPlacemark:source
         toPlacemark:destination
         navigationMode:navigationMode];
    });
}

