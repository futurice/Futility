//
//  NSString+FKPhoneNumbers.h
//  Author(s): Ali Rantakari / Futurice
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

#import <Foundation/Foundation.h>

@interface NSString (FKPhoneNumbers)

// Characters that are typically found in phone numbers
// that are formatted in a human-readable way
+ (NSCharacterSet *) fk_typicalPhoneNumberChars;
+ (NSCharacterSet *) fk_atypicalPhoneNumberChars; // opposite of above

// Characters that are significant wrt the identity of
// the phone number (if any of these characters are
// omitted, changed or added, the result is a different
// phone number)
+ (NSCharacterSet *) fk_significantPhoneNumberChars;
+ (NSCharacterSet *) fk_insignificantPhoneNumberChars; // opposite of above

- (BOOL) fk_looksLikeAPhoneNumber;
- (BOOL) fk_looksLikeAFinnishMobilePhoneNumber;

- (NSString *) fk_standardizedPhoneNumber;

@end
