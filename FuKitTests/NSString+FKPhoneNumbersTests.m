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

- (void) testDetection
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
    
    STAssertFalse([@"100+200" fk_looksLikeAPhoneNumber], @"+ allowed only at the beginning");
}

- (void) testFinnishMobileNumberDetection
{
    STAssertFalse([@"+10407515415" fk_looksLikeAFinnishMobilePhoneNumber], @"Non-Finnish (US) number");
    
    STAssertTrue([@"0407515415" fk_looksLikeAFinnishMobilePhoneNumber], nil);
    STAssertTrue([@"+358407515415" fk_looksLikeAFinnishMobilePhoneNumber], nil);
    STAssertTrue([@"(+358) 40 7515-415" fk_looksLikeAFinnishMobilePhoneNumber], nil);
    
    // See: http://www.viestintavirasto.fi/index/puhelin/puhelinverkonnumerointi/matkaviestinverkkojensuuntanumerot/matkaviestinverkkojensuuntanumerot.html
    NSArray *finnishMobilePrefixes = @[@"040", @"041", @"042", @"04320", @"04321", @"0436", @"0438", @"044", @"0450", @"0451", @"0452", @"0453", @"04541", @"04542", @"04543", @"04544", @"04546", @"04547", @"04552", @"04554", @"04555", @"04556", @"04558", @"04559", @"0456", @"04570", @"04573", @"04574", @"04575", @"04576", @"04577", @"04578", @"04579", @"0458", @"046", @"04944", @"050"];
    for (NSString *prefix in finnishMobilePrefixes)
    {
        STAssertTrue(([[NSString stringWithFormat:@"%@7515415", prefix] fk_looksLikeAFinnishMobilePhoneNumber]), prefix);
        STAssertTrue(([[NSString stringWithFormat:@"+358%@7515415", [prefix substringFromIndex:1]] fk_looksLikeAFinnishMobilePhoneNumber]), prefix);
    }
}

- (void) testStandardization
{
    STAssertEqualObjects([@"(+3) - #*7" fk_standardizedPhoneNumber], @"+3#*7", @"irrelevant characters are stripped but relevant ones are not");
    STAssertEqualObjects([@"123456789012345678901234567890" fk_standardizedPhoneNumber], @"123456789012345678901234567890",
                         @"length limit not imposed; information (i.e. relevant phone number chars) never lost");
}

@end
