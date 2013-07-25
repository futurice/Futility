//
//  FKThirdPartyApps.h
//
//  Created by Ali Rantakari on 13.12.2012.
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
