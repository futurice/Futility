//
//  UIActionSheet+FKBlocks.m
//
//  Created by Ali Rantakari on 20.3.2013.
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

#import "UIActionSheet+FKBlocks.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#warning "This file must be compiled with ARC enabled"
#endif

static void *kFKDismissBlockAssociationKey = (void *)&kFKDismissBlockAssociationKey;
static void *kFKCancelBlockAssociationKey = (void *)&kFKCancelBlockAssociationKey;

@implementation UIActionSheet (FKBlocks)

+ (UIActionSheet *) fk_showInView:(UIView *)sheetParentView
                        withStyle:(UIActionSheetStyle)style
                            title:(NSString *)title
                cancelButtonTitle:(NSString *)cancelButtonTitle
           destructiveButtonTitle:(NSString *)destructiveButtonTitle
                otherButtonTitles:(NSArray *)otherButtonTitles
                   dismissHandler:(FKActionSheetDismissBlock)dismissBlock
                    cancelHandler:(FKActionSheetCancelBlock)cancelBlock
{
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:title
                            delegate:(id<UIActionSheetDelegate>)self.class
                            cancelButtonTitle:nil
                            destructiveButtonTitle:destructiveButtonTitle
                            otherButtonTitles:nil];
    sheet.actionSheetStyle = style;

    for (NSString *buttonTitle in otherButtonTitles)
    {
        [sheet addButtonWithTitle:buttonTitle];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:cancelButtonTitle];

    objc_setAssociatedObject(sheet, kFKDismissBlockAssociationKey, dismissBlock, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(sheet, kFKCancelBlockAssociationKey, cancelBlock, OBJC_ASSOCIATION_COPY);

    if ([sheetParentView isKindOfClass:UITabBar.class])
        [sheet showFromTabBar:(UITabBar *)sheetParentView];
    else if ([sheetParentView isKindOfClass:UIToolbar.class])
        [sheet showFromToolbar:(UIToolbar *)sheetParentView];
    else if ([sheetParentView isKindOfClass:UIBarButtonItem.class])
        [sheet showFromBarButtonItem:(UIBarButtonItem *)sheetParentView animated:YES];
    else
        [sheet showInView:sheetParentView];

    return sheet;
}

+ (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    FKActionSheetDismissBlock dismissBlock = objc_getAssociatedObject(actionSheet, kFKDismissBlockAssociationKey);
    FKActionSheetCancelBlock cancelBlock = objc_getAssociatedObject(actionSheet, kFKCancelBlockAssociationKey);

    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        if (cancelBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                cancelBlock(actionSheet);
            });
        }
    }
    else
    {
        if (dismissBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                dismissBlock(actionSheet, buttonIndex);
            });
        }
    }

    objc_setAssociatedObject(actionSheet, kFKDismissBlockAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(actionSheet, kFKCancelBlockAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

+ (void) actionSheetCancel:(UIActionSheet *)actionSheet
{
    FKActionSheetCancelBlock cancelBlock = objc_getAssociatedObject(actionSheet, kFKCancelBlockAssociationKey);

    if (cancelBlock != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            cancelBlock(actionSheet);
        });
    }

    objc_setAssociatedObject(actionSheet, kFKDismissBlockAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(actionSheet, kFKCancelBlockAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

@end
