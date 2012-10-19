//
//  NSString+FKPhoneNumbers.m
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

#import "NSString+FKPhoneNumbers.h"

#if __has_feature(objc_arc)
#define FK_RETAIN(__a) __a
#else
#define FK_RETAIN(__a) [(__a) retain]
#endif

#define RETURN_CACHED(__type, ...) \
    static __type *value = nil; \
    if (value == nil) { \
        __VA_ARGS__ \
    } \
    return value;

@implementation NSString (FKPhoneNumbers)

- (NSCharacterSet *) fk_significantPhoneNumberChars
{
    RETURN_CACHED(NSCharacterSet,
        value = FK_RETAIN([NSCharacterSet characterSetWithCharactersInString:@"0123456789+#*"]);
    )
}
- (NSCharacterSet *) fk_insignificantPhoneNumberChars
{
    RETURN_CACHED(NSCharacterSet,
        value = FK_RETAIN([self.fk_significantPhoneNumberChars invertedSet]);
    )
}

- (NSCharacterSet *) fk_typicalPhoneNumberChars
{
    RETURN_CACHED(NSCharacterSet,
        value = FK_RETAIN(self.fk_significantPhoneNumberChars.mutableCopy);
        [(NSMutableCharacterSet *)value addCharactersInString:@"- ()"];
    )
}
- (NSCharacterSet *) fk_atypicalPhoneNumberChars
{
    RETURN_CACHED(NSCharacterSet,
        value = FK_RETAIN([self.fk_typicalPhoneNumberChars invertedSet]);
    )
}

- (NSString *) fk_stringWithoutCharactersInSet:(NSCharacterSet *)set
{
    return [[self componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
}

- (NSString *) fk_standardizedPhoneNumber
{
    return [self fk_stringWithoutCharactersInSet:self.fk_insignificantPhoneNumberChars];
}

// Optional: You can use Apple's detector, but this
// might not be fully in line with our standardization
// implementation:
- (BOOL) fk_looksLikeAPhoneNumber_usingDataDetector
{
    static NSDataDetector *phoneNumberDetector = nil;
    if (phoneNumberDetector == nil)
        phoneNumberDetector = FK_RETAIN([NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:NULL]);
    return (0 < [phoneNumberDetector numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)]);
}

- (BOOL) fk_looksLikeAPhoneNumber
{
    NSString *standardized = self.fk_standardizedPhoneNumber;
    if (standardized.length < 5 || 20 < standardized.length)
        return NO;
    return ([self rangeOfCharacterFromSet:self.fk_atypicalPhoneNumberChars].location == NSNotFound);
}

@end
