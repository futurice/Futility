//
//  UIActionSheet+FKBlocks.m
//  Futility
//
//  Created by Ali Rantakari on 20.3.2013.
//
/*
 The MIT License

 Copyright (c) 2013 Futurice

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
