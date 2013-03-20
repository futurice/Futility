//
//  FKCollectionExtensionsTests.m
//  FuKit
//
//  Created by Pyry Jahkola on 14.9.2012.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "FKCollectionsExtensions.h"

@interface FKCollectionExtensionsTests : SenTestCase
@end

// This is used by some test cases:
@interface FKNonCopyingClass : NSObject
@end
@implementation FKNonCopyingClass
@end

@implementation FKCollectionExtensionsTests

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

- (void) test_fk_reduce
{
    id val_sum = [@[@1,@2,@3,@4] fk_reduce:^id(id x, id y) {
        return @([x intValue] + [y intValue]);
    }];
    STAssertEqualObjects(val_sum, @(1+2+3+4), @"sum");
    
    id val_div = [@[@1,@2,@3,@4] fk_reduce:^id(id x, id y) {
        return @([x floatValue] / [y floatValue]);
    }];
    STAssertEqualsWithAccuracy([val_div floatValue],
                               [@(((1.0/2.0)/3.0)/4.0) floatValue],
                               0.0001,
                               @"division");
}

- (void) test_fk_arrayWithoutDuplicates
{
    STAssertEqualObjects((@[@"a",@"b",@"c",@"a",@"c"].fk_arrayWithoutDuplicates),
                         (@[@"a",@"b",@"c"]),
                         @"Base case");
    STAssertEqualObjects((@[@"a",@"b",@"c",@"x",@"1"].fk_arrayWithoutDuplicates),
                         (@[@"a",@"b",@"c",@"x",@"1"]),
                         @"Preserves order");
}

- (void) test_fk_arrayWithoutNulls
{
    STAssertEqualObjects((@[@"a",@"b",NSNull.null,@""].fk_arrayWithoutNulls),
                         (@[@"a",@"b",@""]),
                         @"Base case");
    STAssertEqualObjects((@[@"a",@"b",@"c",@"x",@"1"].fk_arrayWithoutNulls),
                         (@[@"a",@"b",@"c",@"x",@"1"]),
                         @"Preserves order");
}

- (void) test_fk_arrayAsDictionary
{
    STAssertEqualObjects((@[@[@"a",@1], @[@"b",@2]].fk_asDictionary),
                         (@{@"a":@1, @"b":@2}),
                         @"Base case");
    STAssertEqualObjects((@[@[@"a",@1,@"extra"], @[@"b",@2,@"extra"]].fk_asDictionary),
                         (@{@"a":@1, @"b":@2}),
                         @"Pair arrays with too many items");
    STAssertEqualObjects((@[@[@"a",@1], @[@"b"], @[]].fk_asDictionary),
                         (@{@"a":@1, @"b":NSNull.null}),
                         @"Pair arrays with too few items");
    STAssertEqualObjects((@[@[[[FKNonCopyingClass alloc] init],@1], @[@"b",@2]].fk_asDictionary),
                         (@{@"b":@2}),
                         @"Non-NSCopying objects cannot be used as dictionary keys "
                         @"so they should be skipped");
}

- (void) test_fk_dictionaryPairs
{
    STAssertEqualObjects((@{@"a":@1, @"b":@2}.fk_pairs),
                         (@[@[@"a",@1], @[@"b",@2]]),
                         @"Base case");
    STAssertEqualObjects((@{@"a":NSNull.null, @"b":@2}.fk_pairs),
                         (@[@[@"a",NSNull.null], @[@"b",@2]]),
                         @"Keep NSNulls as-is");
}


@end