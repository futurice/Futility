//
//  NSString+FKPhoneNumbers.m
//  Author(s): Ali Rantakari / Futurice
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

#import "NSString+FKPhoneNumbers.h"

#if !__has_feature(objc_arc)
#warning "This file must be compiled with ARC enabled"
#endif

@implementation NSString (FKPhoneNumbers)

+ (NSCharacterSet *) fk_significantPhoneNumberChars
{
    return [NSCharacterSet characterSetWithCharactersInString:@"0123456789+#*"];
}
+ (NSCharacterSet *) fk_insignificantPhoneNumberChars
{
    return [self.fk_significantPhoneNumberChars invertedSet];
}

+ (NSCharacterSet *) fk_typicalPhoneNumberChars
{
    NSMutableCharacterSet *ret = self.fk_significantPhoneNumberChars.mutableCopy;
    [ret addCharactersInString:@"- ()"];
    return ret;
}
+ (NSCharacterSet *) fk_atypicalPhoneNumberChars
{
    return [self.fk_typicalPhoneNumberChars invertedSet];
}

- (NSString *) fk_stringWithoutCharactersInSet:(NSCharacterSet *)set
{
    return [[self componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
}

- (NSString *) fk_standardizedPhoneNumber
{
    return [self fk_stringWithoutCharactersInSet:NSString.fk_insignificantPhoneNumberChars];
}

// Optional: You can use Apple's detector, but this
// might not be fully in line with our standardization
// implementation:
- (BOOL) fk_looksLikeAPhoneNumber_usingDataDetector
{
    static NSDataDetector *phoneNumberDetector = nil;
    if (phoneNumberDetector == nil)
        phoneNumberDetector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)NSTextCheckingTypePhoneNumber error:NULL];
    return (0 < [phoneNumberDetector numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)]);
}

- (BOOL) fk_looksLikeAPhoneNumber
{
    NSString *standardized = self.fk_standardizedPhoneNumber;
    if (standardized.length < 5 || 20 < standardized.length)
        return NO;
    // + allowed only at beginning:
    NSInteger lastPlusIndex = [standardized rangeOfString:@"+" options:NSBackwardsSearch].location;
    if (lastPlusIndex != NSNotFound && 0 < lastPlusIndex)
        return NO;
    return ([self rangeOfCharacterFromSet:NSString.fk_atypicalPhoneNumberChars].location == NSNotFound);
}

- (BOOL) fk_looksLikeAFinnishMobilePhoneNumber
{
    if (!self.fk_looksLikeAPhoneNumber)
        return NO;
    
    NSString *numberToExamine = self.fk_standardizedPhoneNumber;
    if ([numberToExamine hasPrefix:@"+"])
    {
        NSString *finlandPrefix = @"+358";
        if (![numberToExamine hasPrefix:finlandPrefix])
            return NO;
        numberToExamine = [@"0" stringByAppendingString:[numberToExamine substringFromIndex:finlandPrefix.length]];
    }
    
    // http://www.viestintavirasto.fi/index/puhelin/puhelinverkonnumerointi/matkaviestinverkkojensuuntanumerot.html
    // "Matkaviestinverkot ja -palvelut numeroidaan 04- ja 050-alkuisilla numeroilla."
    return ([numberToExamine hasPrefix:@"04"] || [numberToExamine hasPrefix:@"050"]);
}

@end
