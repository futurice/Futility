//
//  NSArray+FKBinarySearchTests.m
//  Futility
//
//  Created by Oleg Grenrus on 9/15/12.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSArray+FKBinarySearch.h"

#import <vector>
#import <algorithm>

@interface NSArray_FKBinarySearchTests : XCTestCase
@end

@implementation NSArray_FKBinarySearchTests

- (void)perform:(NSArray *)array number:(NSNumber *)n gt:(NSUInteger)gt le:(NSUInteger)le ge:(NSUInteger)ge lt:(NSUInteger)lt
{
    FKBinarySearchComparatorBlock comparator = ^NSComparisonResult (NSNumber *number) {
        return [number compare:n];
    };

    XCTAssertEqual([array indexOfFirstObjectGreaterUsingComparator:comparator],
                   gt,
                   @"index of x > %@ should be %lu in %@", n, gt, array);

    XCTAssertEqual([array indexOfLastObjectLessOrEqualUsingComparator:comparator],
                   le,
                   @"index of x <= %@ should be %lu in %@", n, le, array);

    XCTAssertEqual([array indexOfFirstObjectGreaterOrEqualUsingComparator:comparator],
                   ge,
                   @"index of x >= %@ should be %lu in %@", n, ge, array);

    XCTAssertEqual([array indexOfLastObjectLessUsingComparator:comparator],
                   lt,
                   @"index of x < %@ should be %lu in %@", n, lt, array);

}

- (void)test_fk_binary_search_empty
{
    NSArray *array = @[];
    [self perform:array number:@0 gt:0 le:0 ge:0 lt:0];
}

- (void)test_fk_binary_search_singleton
{
    NSArray *array = @[@1];

    [self perform:array number:@0 gt:0 le:1 ge:0 lt:1];
    [self perform:array number:@1 gt:1 le:0 ge:0 lt:1];
    [self perform:array number:@2 gt:1 le:0 ge:1 lt:0];
}


- (void)test_fk_binary_search_unique
{
    NSArray *array = @[@1, @2, @3, @4, @5];

    [self perform:array number:@0 gt:0 le:5 ge:0 lt:5];
    [self perform:array number:@1 gt:1 le:0 ge:0 lt:5];
    [self perform:array number:@2 gt:2 le:1 ge:1 lt:0];
    [self perform:array number:@3 gt:3 le:2 ge:2 lt:1];
    [self perform:array number:@4 gt:4 le:3 ge:3 lt:2];
    [self perform:array number:@5 gt:5 le:4 ge:4 lt:3];
    [self perform:array number:@6 gt:5 le:4 ge:5 lt:4];
}

- (void)test_fk_binary_search_unique_holes
{
    NSArray *array = @[@1, @3, @5, @7, @9];

    [self perform:array number:@0 gt:0 le:5 ge:0 lt:5];
    [self perform:array number:@1 gt:1 le:0 ge:0 lt:5];
    [self perform:array number:@2 gt:1 le:0 ge:1 lt:0];
    [self perform:array number:@3 gt:2 le:1 ge:1 lt:0];
    [self perform:array number:@4 gt:2 le:1 ge:2 lt:1];
    [self perform:array number:@5 gt:3 le:2 ge:2 lt:1];
    [self perform:array number:@6 gt:3 le:2 ge:3 lt:2];
    [self perform:array number:@7 gt:4 le:3 ge:3 lt:2];
    [self perform:array number:@8 gt:4 le:3 ge:4 lt:3];
    [self perform:array number:@9 gt:5 le:4 ge:4 lt:3];
    [self perform:array number:@10 gt:5 le:4 ge:5 lt:4];
}

- (void)test_fk_binary_search_nonunique
{
    NSArray *array = @[@1, @1, @1, @2, @2, @2, @3, @3, @3, @4, @4, @4, @5, @5, @5];

    [self perform:array number:@0 gt:0 le:15 ge:0 lt:15];
    [self perform:array number:@1 gt:3 le:2 ge:0 lt:15];
    [self perform:array number:@2 gt:6 le:5 ge:3 lt:2];
    [self perform:array number:@3 gt:9 le:8 ge:6 lt:5];
    [self perform:array number:@4 gt:12 le:11 ge:9 lt:8];
    [self perform:array number:@5 gt:15 le:14 ge:12 lt:11];
    [self perform:array number:@6 gt:15 le:14 ge:15 lt:14];
}

- (void)test_fk_binary_search_nonunique_holes
{
    NSArray *array = @[@1, @1, @1, @3, @3, @3, @5, @5, @5, @7, @7, @7, @9, @9, @9];

    [self perform:array number:@0 gt:0 le:15 ge:0 lt:15];
    [self perform:array number:@1 gt:3 le:2 ge:0 lt:15];
    [self perform:array number:@2 gt:3 le:2 ge:3 lt:2];
    [self perform:array number:@3 gt:6 le:5 ge:3 lt:2];
    [self perform:array number:@4 gt:6 le:5 ge:6 lt:5];
    [self perform:array number:@5 gt:9 le:8 ge:6 lt:5];
    [self perform:array number:@6 gt:9 le:8 ge:9 lt:8];
    [self perform:array number:@7 gt:12 le:11 ge:9 lt:8];
    [self perform:array number:@8 gt:12 le:11 ge:12 lt:11];
    [self perform:array number:@9 gt:15 le:14 ge:12 lt:11];
    [self perform:array number:@10 gt:15 le:14 ge:15 lt:14];
}

- (void)test_fk_binary_search_cxx
{
    std::vector<int> vec;
    NSMutableArray *array = [NSMutableArray array];

    for (int i = 0; i < 100; i++) {
        for (int j = 0; j < 5; j++) {
            vec.push_back(i);
            [array addObject:@(i)];
        }
    }

    FKBinarySearchComparatorBlock comparator = ^NSComparisonResult (NSNumber *number) {
        return [number compare:@50];
    };

    {
        auto iter = std::lower_bound(vec.begin(), vec.end(), 50);
        NSUInteger index = iter - vec.begin();

        XCTAssertEqual([array indexOfFirstObjectGreaterOrEqualUsingComparator:comparator],
                       index,
                       @"std::lower_bound is the same as indexOfFirstObjectGreaterOrEqualUsingComparator");
    }

    {
        auto iter = std::upper_bound(vec.begin(), vec.end(), 50);
        NSUInteger index = iter - vec.begin();

        XCTAssertEqual([array indexOfFirstObjectGreaterUsingComparator:comparator],
                       index,
                       @"std::upper_bound is the same as indexOfFirstObjectGreaterUsingComparator");
    }
}

@end
