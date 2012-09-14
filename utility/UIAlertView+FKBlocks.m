//
//  UIAlertView+FKBlocks.m
//  Non-ARC version
//  iOS 4.3+
// 
/*
The MIT License

Copyright (c) 2011-2012 Ali Rantakari

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

#import "UIAlertView+FKBlocks.h"
#import <objc/runtime.h>

#define FK_ASSOCIATION_KEY_DISMISS_BLOCK @"FKDismissBlock"
#define FK_ASSOCIATION_KEY_CANCEL_BLOCK @"FKCancelBlock"

@implementation UIAlertView (UIAlertView_FKBlocks)

+ (UIAlertView *) fk_alertViewWithTitle:(NSString*)title
                                message:(NSString*)message
                      cancelButtonTitle:(NSString*)cancelButtonTitle
                      otherButtonTitles:(NSArray*)otherButtonTitles
                         dismissHandler:(FKAlertViewDismissBlock)dismissBlock
                          cancelHandler:(FKAlertViewCancelBlock)cancelBlock
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    for (NSString *otherButtonTitle in otherButtonTitles)
        [alert addButtonWithTitle:otherButtonTitle];
    
    objc_setAssociatedObject(alert, FK_ASSOCIATION_KEY_DISMISS_BLOCK, dismissBlock, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(alert, FK_ASSOCIATION_KEY_CANCEL_BLOCK, cancelBlock, OBJC_ASSOCIATION_COPY);
    
#if __has_feature(objc_arc)
    return alert;
#else
    return [alert autorelease];
#endif
}

+ (UIAlertView *) fk_showWithTitle:(NSString*)title
                           message:(NSString*)message
                 cancelButtonTitle:(NSString*)cancelButtonTitle
                 otherButtonTitles:(NSArray*)otherButtonTitles
                    dismissHandler:(FKAlertViewDismissBlock)dismissBlock
                     cancelHandler:(FKAlertViewCancelBlock)cancelBlock
{
    UIAlertView *alert = [UIAlertView fk_alertViewWithTitle:title
                                                    message:message
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:otherButtonTitles
                                             dismissHandler:dismissBlock
                                              cancelHandler:cancelBlock];
    [alert show];
    return alert;
}

#define TAG_INPUT_FIELD 1977

+ (UIAlertView *) fk_showWithTitle:(NSString*)title
                           message:(NSString*)message
                     textFieldText:(NSString*)fieldText
                       placeholder:(NSString*)fieldPlaceholder
                       secureInput:(BOOL)secureInput
                      keyboardType:(UIKeyboardType)keyboardType
                 cancelButtonTitle:(NSString*)cancelButtonTitle
                 otherButtonTitles:(NSArray*)otherButtonTitles
                    dismissHandler:(FKAlertViewDismissBlock)dismissBlock
                     cancelHandler:(FKAlertViewCancelBlock)cancelBlock
{
    UIAlertView *alert = [UIAlertView fk_alertViewWithTitle:title
                                                    message:message
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:otherButtonTitles
                                             dismissHandler:dismissBlock
                                              cancelHandler:cancelBlock];
    
    UITextField *field = nil;
    if ([alert respondsToSelector:@selector(alertViewStyle)])
    {
        // iOS 5+ : Supports text field alerts natively.
        alert.alertViewStyle = secureInput ? UIAlertViewStyleSecureTextInput : UIAlertViewStylePlainTextInput;
        field = [alert textFieldAtIndex:0];
        field.keyboardType = keyboardType;
        field.placeholder = fieldPlaceholder;
        field.text = fieldText;
        [alert show];
    }
    else
    {
        // iOS 4.x or earlier : must implement hacky workaround.
        
        // We add newlines to the end of the 'message' to reserve a bit of space
        // below it, and then drop our UITextField there.
        // 
        // This works fine unless 'message' is so long that the alert view will
        // display it in a scroll view, in which case we won't be able to reserve
        // space for the text field by adding newlines to the end.
        // 
        // Three lines of message text (~100pt height) is shown as a normal label,
        // but four lines (~120pt height) is shown as a scroll view. So we remove one
        // word at a time from our message until it's short enough to fit on three
        // lines:
        // 
        NSString *modifiedMessage = alert.message;
        BOOL messageIsTruncated = NO;
        while (110.0f < [[modifiedMessage stringByAppendingFormat:@"%@\n\n\n", (messageIsTruncated ? @"…" : @"")]
                         sizeWithFont:[UIFont systemFontOfSize:16]
                         constrainedToSize:CGSizeMake(260, 1000)
                         lineBreakMode:UILineBreakModeWordWrap].height)
        {
            messageIsTruncated = YES;
            NSArray *words = [modifiedMessage componentsSeparatedByString:@" "];
            modifiedMessage = [[words subarrayWithRange:NSMakeRange(0, words.count-1)] componentsJoinedByString:@" "];
        }
        
        alert.message = [modifiedMessage stringByAppendingFormat:@"%@\n\n\n", (messageIsTruncated ? @"…" : @"")];
        
#if __has_feature(objc_arc)
        field = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, 252, 25)];
#else
        field = [[[UITextField alloc] initWithFrame:CGRectMake(16, 0, 252, 25)] autorelease];
#endif
        field.font = [UIFont systemFontOfSize:18];
        field.keyboardAppearance = UIKeyboardAppearanceAlert;
        field.secureTextEntry = secureInput;
        field.borderStyle = UITextBorderStyleRoundedRect;
        field.tag = TAG_INPUT_FIELD;
        field.keyboardType = keyboardType;
        field.placeholder = fieldPlaceholder;
        field.text = fieldText;
        [field becomeFirstResponder];
        [alert addSubview:field];
        
        [alert show];
        
        // The alert view positions its subviews only after calling -show, so
        // we have to do this here:
        CGFloat alertLabelsBottom = 0;
        for (UIView *subview in alert.subviews)
        {
            if (![subview isKindOfClass:[UILabel class]])
                continue;
            CGFloat bottom = CGRectGetMaxY(subview.frame);
            if (alertLabelsBottom < bottom)
                alertLabelsBottom = bottom;
        }
        field.frame = CGRectMake(field.frame.origin.x,
                                 alertLabelsBottom - field.frame.size.height,
                                 field.frame.size.width,
                                 field.frame.size.height);
    }
    
    return alert;
}

+ (UIAlertView*) fk_showWithTitle:(NSString*)title
                          message:(NSString*)message
                        okHandler:(FKAlertViewCancelBlock)okBlock
{
    return [self fk_showWithTitle:title
                          message:message
                cancelButtonTitle:NSLocalizedString(@"Ok", @"Alert view dialog Ok button")
                otherButtonTitles:nil
                   dismissHandler:NULL
                    cancelHandler:okBlock];
}

+ (UIAlertView*) fk_showCancelableWithTitle:(NSString*)title
                                    message:(NSString*)message
                                 actionName:(NSString*)actionName
                              actionHandler:(FKAlertViewDismissBlock)actionBlock
{
    return [self fk_showWithTitle:title
                          message:message
                cancelButtonTitle:NSLocalizedString(@"Cancel", @"Alert view dialog cancel button")
                otherButtonTitles:@[actionName]
                   dismissHandler:actionBlock
                    cancelHandler:NULL];
}

+ (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    FKAlertViewDismissBlock dismissBlock = objc_getAssociatedObject(alertView, FK_ASSOCIATION_KEY_DISMISS_BLOCK);
    FKAlertViewCancelBlock cancelBlock = objc_getAssociatedObject(alertView, FK_ASSOCIATION_KEY_CANCEL_BLOCK);
    
    if (buttonIndex == [alertView cancelButtonIndex])
    {
        if (cancelBlock != nil)
        {
            FKAlertViewCancelBlock bCancelBlock =
#if __has_feature(objc_arc)
                cancelBlock;
#else
                [cancelBlock retain];
#endif
            dispatch_async(dispatch_get_main_queue(), ^{
                bCancelBlock(alertView);
#if !__has_feature(objc_arc)
                [bCancelBlock release];
#endif
            });
        }
    }
    else
    {
        UITextField *inputField;
        if ([self respondsToSelector:@selector(alertViewStyle)])
            inputField = [alertView textFieldAtIndex:0];
        else
            inputField = (UITextField *)[alertView viewWithTag:TAG_INPUT_FIELD];
        NSString *input = inputField.text;
        
        if (dismissBlock != nil)
        {
            FKAlertViewDismissBlock bDismissBlock =
#if __has_feature(objc_arc)
                dismissBlock;
#else
                [dismissBlock retain];
#endif
            dispatch_async(dispatch_get_main_queue(), ^{
                bDismissBlock(alertView, buttonIndex, input);
#if !__has_feature(objc_arc)
                [bDismissBlock release];
#endif
            });
        }
    }
    
    objc_setAssociatedObject(alertView, FK_ASSOCIATION_KEY_DISMISS_BLOCK, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(alertView, FK_ASSOCIATION_KEY_CANCEL_BLOCK, nil, OBJC_ASSOCIATION_ASSIGN);
}

@end