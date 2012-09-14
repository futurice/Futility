//
//  NSArray+FKExtensionsTests.m
//  FuKit
//
//  Created by Pyry Jahkola on 14.9.2012.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "NSArray+FKExtensions.h"

@interface NSArray_FKExtensionsTests : SenTestCase
@end

@implementation NSArray_FKExtensionsTests

- (void)test_fk_map
{
    FKArrayEnumerationBlock identity = ^id(id obj) { return obj; };
    FKArrayEnumerationBlock describe = ^id(id obj) { return [obj description]; };
    
    NSArray *array0 = @[];
    NSArray *array1 = @[@1, @2.0, @"three"];
    NSArray *array2 = @[@1, @2.0, @"three", @[], @{}];
    NSArray *array3 = @[@"1", @"2", @"three"];

    if (![array0 respondsToSelector:@selector(fk_map:)]) {
        STFail(@"respond to fk_map:");
        return;
    }
    
    STAssertEqualObjects([array0 fk_map:describe], @[], @"map over empty array");

    STAssertEqualObjects([array2 fk_map:identity], array2, @"map identity");

    STAssertEqualObjects([array1 fk_map:describe], array3, @"map function");
}

- (void)test_fk_filter
{
    FKArrayMatchBlock valid = ^BOOL(id obj) { return obj != [NSNull null]; };

    NSArray *array0 = @[];
    NSArray *array1 = @[@1, [NSNull null], @"three"];
    NSArray *array2 = @[@1, @2.0, @"three", @[], @{@123: [NSNull null]}];
    NSArray *array3 = @[[NSNull null], @"2", @"three", [NSNull null]];

    if (![array0 respondsToSelector:@selector(fk_filter:)]) {
        STFail(@"respond to fk_filter:");
        return;
    }

    STAssertEqualObjects([array0 fk_filter:valid], @[], @"filter empty array");
    STAssertEqualObjects([array1 fk_filter:valid], (@[@1, @"three"]), @"filter array1");
    STAssertEqualObjects([array2 fk_filter:valid], array2, @"filter array2");
    STAssertEqualObjects([array3 fk_filter:valid], (@[@"2", @"three"]), @"filter array3");
}

@end
