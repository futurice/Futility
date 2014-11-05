//
//  NSString+FKPhoneNumbersTests.m
//  Futility
//
//  Created by Ali Rantakari on 19.10.2012.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+FKPhoneNumbers.h"

@interface NSString_FKPhoneNumbersTests : XCTestCase
@end

@implementation NSString_FKPhoneNumbersTests

- (void) testDetection
{
    XCTAssertFalse([@"" fk_looksLikeAPhoneNumber]);
    XCTAssertFalse([@"1234" fk_looksLikeAPhoneNumber], @"too short");
    XCTAssertTrue([@"12345" fk_looksLikeAPhoneNumber], @"just long enough");
    XCTAssertTrue([@"12345678901234567890" fk_looksLikeAPhoneNumber], @"just short enough");
    XCTAssertTrue([@"(((---12345678901234567890" fk_looksLikeAPhoneNumber],
                 @"chars that are semantically insignificant but typical in number formatting should not affect length check");
    XCTAssertFalse([@"123456789012345678901" fk_looksLikeAPhoneNumber], @"too long");

    XCTAssertTrue([@"+35840 7515 415" fk_looksLikeAPhoneNumber], @"typical international case");
    XCTAssertTrue([@"(+358) (0)40-7515-415" fk_looksLikeAPhoneNumber], @"typical international case, with irrelevant formatting chars");
    XCTAssertTrue([@"040 7515 415" fk_looksLikeAPhoneNumber], @"typical finnish case");
    XCTAssertFalse([@"555 GHOSTBUSTERS" fk_looksLikeAPhoneNumber], @"letters not allowed");
    XCTAssertTrue([@"  123       14     4   15          " fk_looksLikeAPhoneNumber], @"all whitespace should be ignored");

    XCTAssertFalse([@"100+200" fk_looksLikeAPhoneNumber], @"+ allowed only at the beginning");
}

- (void) testFinnishMobileNumberDetection
{
    XCTAssertFalse([@"+10407515415" fk_looksLikeAFinnishMobilePhoneNumber], @"Non-Finnish (US) number");

    XCTAssertTrue([@"0407515415" fk_looksLikeAFinnishMobilePhoneNumber]);
    XCTAssertTrue([@"+358407515415" fk_looksLikeAFinnishMobilePhoneNumber]);
    XCTAssertTrue([@"(+358) 40 7515-415" fk_looksLikeAFinnishMobilePhoneNumber]);

    // See: http://www.viestintavirasto.fi/index/puhelin/puhelinverkonnumerointi/matkaviestinverkkojensuuntanumerot/matkaviestinverkkojensuuntanumerot.html
    NSArray *finnishMobilePrefixes = @[@"040", @"041", @"042", @"04320", @"04321", @"0436", @"0438", @"044", @"0450", @"0451", @"0452", @"0453", @"04541", @"04542", @"04543", @"04544", @"04546", @"04547", @"04552", @"04554", @"04555", @"04556", @"04558", @"04559", @"0456", @"04570", @"04573", @"04574", @"04575", @"04576", @"04577", @"04578", @"04579", @"0458", @"046", @"04944", @"050"];
    for (NSString *prefix in finnishMobilePrefixes)
    {
        XCTAssertTrue(([[NSString stringWithFormat:@"%@7515415", prefix] fk_looksLikeAFinnishMobilePhoneNumber]), @"%@", prefix);
        XCTAssertTrue(([[NSString stringWithFormat:@"+358%@7515415", [prefix substringFromIndex:1]] fk_looksLikeAFinnishMobilePhoneNumber]), @"%@", prefix);
    }
}

- (void) testStandardization
{
    XCTAssertEqualObjects([@"(+3) - #*7" fk_standardizedPhoneNumber], @"+3#*7", @"irrelevant characters are stripped but relevant ones are not");
    XCTAssertEqualObjects([@"123456789012345678901234567890" fk_standardizedPhoneNumber], @"123456789012345678901234567890",
                         @"length limit not imposed; information (i.e. relevant phone number chars) never lost");
}

@end
