//
//  FKThirdPartyApps.h
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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef enum
{
    FKMapsAppNavigationMode_None = 0,
    FKMapsAppNavigationMode_Drive,
    FKMapsAppNavigationMode_Walk,
    FKMapsAppNavigationMode_Transit,
}
FKMapsAppNavigationMode;

// The functions below will open the standard system app by default, but
// if there are any relevant third-party apps installed, an action sheet
// will be shown to the user so they can choose which app to invoke.

void fk_openURLInAnyBrowser(NSURL *url, UIView *sheetParentView, NSString *sheetTitle, NSString *sheetCancelButtonTitle);
void fk_openSearchInAnyMapsApp(NSString *mapSearchQuery, UIView *sheetParentView, NSString *sheetTitle, NSString *sheetCancelButtonTitle);

void fk_showDirectionsInAnyMapsApp(MKPlacemark *source,
                                   MKPlacemark *destination,
                                   FKMapsAppNavigationMode navigationMode,
                                   BOOL showNonInstalledApps,
                                   UIView *sheetParentView,
                                   NSString *sheetTitle,
                                   NSString *sheetCancelButtonTitle);
