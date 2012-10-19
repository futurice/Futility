//
//  NSString+FKPhoneNumbersTests.m
//  FuKit
//
//  Created by Ali Rantakari on 19.10.2012.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSString+FKPhoneNumbers.h"

@interface NSString_FKPhoneNumbersTests : SenTestCase
@end

@implementation NSString_FKPhoneNumbersTests

- (void) testDetectionHeuristics
{
    STAssertFalse([@"" fk_looksLikeAPhoneNumber], nil);
    STAssertFalse([@"1234" fk_looksLikeAPhoneNumber], @"too short");
    STAssertTrue([@"12345" fk_looksLikeAPhoneNumber], @"just long enough");
    STAssertTrue([@"12345678901234567890" fk_looksLikeAPhoneNumber], @"just short enough");
    STAssertTrue([@"(((---12345678901234567890" fk_looksLikeAPhoneNumber],
                 @"chars that are semantically insignificant but typical in number formatting should not affect length check");
    STAssertFalse([@"123456789012345678901" fk_looksLikeAPhoneNumber], @"too long");
    
    STAssertTrue([@"+35840 7515 415" fk_looksLikeAPhoneNumber], @"typical international case");
    STAssertTrue([@"(+358) (0)40-7515-415" fk_looksLikeAPhoneNumber], @"typical international case, with irrelevant formatting chars");
    STAssertTrue([@"040 7515 415" fk_looksLikeAPhoneNumber], @"typical finnish case");
    STAssertFalse([@"555 GHOSTBUSTERS" fk_looksLikeAPhoneNumber], @"letters not allowed");
    STAssertTrue([@"  123       14     4   15          " fk_looksLikeAPhoneNumber], @"all whitespace should be ignored");
}

- (void) testStandardization
{
    STAssertEqualObjects([@"(+3) - #*7" fk_standardizedPhoneNumber], @"+3#*7", @"irrelevant characters are stripped but relevant ones are not");
    STAssertEqualObjects([@"123456789012345678901234567890" fk_standardizedPhoneNumber], @"123456789012345678901234567890",
                         @"length limit not imposed; information (i.e. relevant phone number chars) never lost");
}

@end
