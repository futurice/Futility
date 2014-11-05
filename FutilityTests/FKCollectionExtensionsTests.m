//
//  FKCollectionExtensionsTests.m
//  Futility
//
//  Created by Pyry Jahkola on 14.9.2012.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "FKCollectionsExtensions.h"

@interface FKCollectionExtensionsTests : XCTestCase
@end

// This is used by some test cases:
@interface FKNonCopyingClass : NSObject
@end
@implementation FKNonCopyingClass
@end

@implementation FKCollectionExtensionsTests

- (void)test_fk_map
{
    FKUnaryOperatorBlock identity = ^id(id obj) { return obj; };
    FKUnaryOperatorBlock describe = ^id(id obj) { return [obj description]; };

    NSArray *array0 = @[];
    NSArray *array1 = @[@1, @2.0, @"three"];
    NSArray *array2 = @[@1, @2.0, @"three", @[], @{}];
    NSArray *array3 = @[@"1", @"2", @"three"];

    if (![array0 respondsToSelector:@selector(fk_map:)]) {
        XCTFail(@"respond to fk_map:");
        return;
    }

    XCTAssertEqualObjects([array0 fk_map:describe], @[], @"map over empty array");

    XCTAssertEqualObjects([array2 fk_map:identity], array2, @"map identity");

    XCTAssertEqualObjects([array1 fk_map:describe], array3, @"map function");
}

- (void)test_fk_parallelMap
{
    FKUnaryOperatorBlock identity = ^id(id obj) { return obj; };
    FKUnaryOperatorBlock describe = ^id(id obj) { return [obj description]; };
    
    NSArray *array0 = @[];
    NSArray *array1 = @[@1, @2.0, @"three"];
    NSArray *array2 = @[@1, @2.0, @"three", @[], @{}];
    NSArray *array3 = @[@"1", @"2", @"three"];
    
    if (![array0 respondsToSelector:@selector(fk_map:)]) {
        XCTFail(@"respond to fk_map:");
        return;
    }
    
    XCTAssertEqualObjects([array0 fk_parallelMap:describe], @[], @"map over empty array");
    
    XCTAssertEqualObjects([array2 fk_parallelMap:identity], array2, @"map identity");
    
    XCTAssertEqualObjects([array1 fk_parallelMap:describe], array3, @"map function");
}

- (void)test_fk_filter
{
    FKObjectToBoolBlock valid = ^BOOL(id obj) { return obj != [NSNull null]; };

    NSArray *array0 = @[];
    NSArray *array1 = @[@1, [NSNull null], @"three"];
    NSArray *array2 = @[@1, @2.0, @"three", @[], @{@123: [NSNull null]}];
    NSArray *array3 = @[[NSNull null], @"2", @"three", [NSNull null]];

    if (![array0 respondsToSelector:@selector(fk_filter:)]) {
        XCTFail(@"respond to fk_filter:");
        return;
    }

    XCTAssertEqualObjects([array0 fk_filter:valid], @[], @"filter empty array");
    XCTAssertEqualObjects([array1 fk_filter:valid], (@[@1, @"three"]), @"filter array1");
    XCTAssertEqualObjects([array2 fk_filter:valid], array2, @"filter array2");
    XCTAssertEqualObjects([array3 fk_filter:valid], (@[@"2", @"three"]), @"filter array3");
}

- (void) test_fk_reduce
{
    XCTAssertNil(([@[] fk_reduce:^id(id x, id y) { return @1; }]), @"Empty receiver -> response is nil");
    XCTAssertEqualObjects(([@[@1] fk_reduce:^id(id x, id y) { return x; }]), @1, @"Only one value");
    XCTAssertEqualObjects(([@[@1,@2] fk_reduce:^id(id x, id y) { return x; }]), @1, @"base");
    XCTAssertNil(([@[@1,@2] fk_reduce:^id(id x, id y) { return nil; }]), @"nil");

    id val_sum = [@[@1,@2,@3,@4] fk_reduce:^id(id x, id y) {
        return @([x intValue] + [y intValue]);
    }];
    XCTAssertEqualObjects(val_sum, @(1+2+3+4), @"sum");

    id val_div = [@[@1,@2,@3,@4] fk_reduce:^id(id x, id y) {
        return @([x floatValue] / [y floatValue]);
    }];
    XCTAssertEqualWithAccuracy([val_div floatValue],
                               [@(((1.0/2.0)/3.0)/4.0) floatValue],
                               0.0001,
                               @"division");
}

- (void) test_fk_flattened
{
    XCTAssertEqualObjects((@[@"a",@[@"b",@"c"],@"d"].fk_flattened),
                         (@[@"a",@"b",@"c",@"d"]),
                         @"Base case");
    XCTAssertEqualObjects((@[@"a",@[@"b",@[@"c",@"d"],@"e"],@"f"].fk_flattened),
                         (@[@"a",@"b",@"c",@"d",@"e",@"f"]),
                         @"Two levels deep");
    XCTAssertEqualObjects((@[@"a",@"b"].fk_flattened),
                         (@[@"a",@"b"]),
                         @"Already flat");
    XCTAssertEqualObjects((@[].fk_flattened),
                         (@[]),
                         @"Empty array");
}

- (void) test_fk_arrayWithoutDuplicates
{
    XCTAssertEqualObjects((@[@"a",@"b",@"c",@"a",@"c"].fk_arrayWithoutDuplicates),
                         (@[@"a",@"b",@"c"]),
                         @"Base case");
    XCTAssertEqualObjects((@[@"a",@"b",@"c",@"x",@"1"].fk_arrayWithoutDuplicates),
                         (@[@"a",@"b",@"c",@"x",@"1"]),
                         @"Preserves order");
    XCTAssertEqualObjects((@[].fk_arrayWithoutDuplicates),
                         (@[]),
                         @"Empty array");
}

- (void) test_fk_arrayWithoutNulls
{
    XCTAssertEqualObjects((@[@"a",@"b",NSNull.null,@""].fk_arrayWithoutNulls),
                         (@[@"a",@"b",@""]),
                         @"Base case");
    XCTAssertEqualObjects((@[@"a",@"b",@"c",@"x",@"1"].fk_arrayWithoutNulls),
                         (@[@"a",@"b",@"c",@"x",@"1"]),
                         @"Preserves order");
    XCTAssertEqualObjects((@[].fk_arrayWithoutNulls),
                         (@[]),
                         @"Empty array");
}

- (void) test_fk_arrayWithoutEmpties
{
    XCTAssertEqualObjects((@[@"a",@"b",@""].fk_arrayWithoutEmpties),
                         (@[@"a",@"b"]),
                         @"Base case");
    XCTAssertEqualObjects((@[@"a",@"b",NSNull.null,@4].fk_arrayWithoutEmpties),
                         (@[@"a",@"b"]),
                         @"Removes non-strings");
    XCTAssertEqualObjects((@[@"a",@"b",@"c",@"x",@"1"].fk_arrayWithoutEmpties),
                         (@[@"a",@"b",@"c",@"x",@"1"]),
                         @"Preserves order");
    XCTAssertEqualObjects((@[].fk_arrayWithoutEmpties),
                         (@[]),
                         @"Empty array");
}

- (void) test_fk_arrayAsDictionary
{
    XCTAssertEqualObjects((@[@[@"a",@1], @[@"b",@2]].fk_asDictionary),
                         (@{@"a":@1, @"b":@2}),
                         @"Base case");
    XCTAssertEqualObjects((@[@[@"a",@1,@"extra"], @[@"b",@2,@"extra"]].fk_asDictionary),
                         (@{@"a":@1, @"b":@2}),
                         @"Pair arrays with too many items");
    XCTAssertEqualObjects((@[@[@"a",@1], @[@"b"], @[]].fk_asDictionary),
                         (@{@"a":@1, @"b":NSNull.null}),
                         @"Pair arrays with too few items");
    XCTAssertEqualObjects((@[@[[[FKNonCopyingClass alloc] init],@1], @[@"b",@2]].fk_asDictionary),
                         (@{@"b":@2}),
                         @"Non-NSCopying objects cannot be used as dictionary keys "
                         @"so they should be skipped");
    XCTAssertEqualObjects((@[].fk_asDictionary),
                         (@{}),
                         @"Empty array");
}

- (void) test_fk_dictionaryPairs
{
    XCTAssertEqualObjects((@{@"a":@1, @"b":@2}.fk_pairs),
                         (@[@[@"a",@1], @[@"b",@2]]),
                         @"Base case");
    XCTAssertEqualObjects((@{@"a":NSNull.null, @"b":@2}.fk_pairs),
                         (@[@[@"a",NSNull.null], @[@"b",@2]]),
                         @"Keep NSNulls as-is");
    XCTAssertEqualObjects((@{}.fk_pairs),
                         (@[]),
                         @"Empty dictionary");
}

- (void) test_fk_dictionaryMap
{
#define DICTMAP(_d, _f) [(_d) fk_map:^NSArray*(id<NSCopying> key, id value) { return (_f); }]
    XCTAssertEqualObjects(DICTMAP(@{}, (@[key,value])), (@{}), @"Empty receiver -> response is an empty dict");
    
    NSDictionary *d = @{@"a":@1, @"b":@2};
    XCTAssertEqualObjects(DICTMAP(d, (@[key,value])), (@{@"a":@1, @"b":@2}), @"Identity");
    XCTAssertEqualObjects(DICTMAP(d, (@[key, @([value intValue] + 1)])), (@{@"a":@2, @"b":@3}), @"Value mapping");
    XCTAssertEqualObjects(DICTMAP(d, (@[[(NSString*)key stringByAppendingString:@"x"], @([value intValue] + 1)])), (@{@"ax":@2, @"bx":@3}), @"Value and key mapping");
    
    XCTAssertEqualObjects(DICTMAP(d, ([(NSObject*)key isEqual:@"a"] ? @[key, value] : @[])),
                         (@{@"a":@1}), @"Skip returned empty array");
    XCTAssertEqualObjects(DICTMAP(d, ([(NSObject*)key isEqual:@"a"] ? @[key, value] : nil)),
                         (@{@"a":@1}), @"Skip returned nil");
    XCTAssertEqualObjects(DICTMAP(d, ([(NSObject*)key isEqual:@"a"] ? @[key, value] : (NSArray*)NSNull.null)),
                         (@{@"a":@1}), @"Skip returned NSNull");
    
    FKNonCopyingClass *nonCopyingObj = [[FKNonCopyingClass alloc] init];
    XCTAssertEqualObjects(DICTMAP(d, ([(NSObject*)key isEqual:@"a"] ? @[key, value] : @[nonCopyingObj, @1])),
                         (@{@"a":@1}), @"Skip returned non-NSCopying keys");
#undef DICTMAP
}

- (void) test_fk_mapSel
{
    XCTAssertEqualObjects(([@[] fk_mapSel:NULL]), @[], @"Null selector --> return self");
    XCTAssertEqualObjects(([@[] fk_mapSel:@selector(lowercaseString)]), @[], @"Empty receiver -> response is an empty array");
    XCTAssertEqualObjects(([@[@1,@2] fk_mapSel:@selector(stringValue)]), (@[@"1",@"2"]), @"basic");
    XCTAssertEqualObjects(([@[@1,@2] fk_mapSel:@selector(lowercaseString)]), (@[NSNull.null, NSNull.null]), @"Doesn't respond to selector -> nil values");
}

- (void) test_fk_filterSel
{
    XCTAssertEqualObjects(([@[] fk_filterSel:NULL]), @[], @"Null selector --> return self");
    XCTAssertEqualObjects(([@[] fk_filterSel:@selector(intValue)]), @[], @"Empty receiver -> response is an empty array");
    XCTAssertEqualObjects(([@[@"1",@"2"] fk_filterSel:@selector(intValue)]), (@[@"1",@"2"]), @"basic");
    XCTAssertEqualObjects(([@[@"1",@"0",@"2"] fk_filterSel:@selector(intValue)]), (@[@"1",@"2"]), @"basic");
    XCTAssertEqualObjects(([@[@"0",@"0",@"0"] fk_filterSel:@selector(intValue)]), @[], @"basic");
    XCTAssertEqualObjects(([@[@0,@1,@2] fk_filterSel:@selector(lowercaseString)]), @[], @"Doesn't respond to selector -> empty array");
}

- (void) test_fk_contains
{
    XCTAssertFalse(([@[] fk_contains:nil]), @"Nil block --> 'does not contain'");
    XCTAssertEqual(([@[] fk_contains:^BOOL(id obj) { return YES; }]), NO, @"Empty receiver -> response is always NO");
    XCTAssertEqual(([@[@1,@2] fk_contains:^BOOL(id obj) { return [obj isEqual:@1]; }]), YES, @"Basic");
    XCTAssertEqual(([@[@2,@3] fk_contains:^BOOL(id obj) { return [obj isEqual:@1]; }]), NO, @"Basic");
}

- (void) test_fk_first
{
    XCTAssertNil(([@[] fk_first:nil]), @"Nil block");
    XCTAssertNil(([@[] fk_first:^BOOL(id obj) { return YES; }]), @"Empty receiver -> response is always nil");
    XCTAssertNil(([@[@2,@3] fk_first:^BOOL(id obj) { return [obj isEqual:@1]; }]), @"Not found");
    XCTAssertEqualObjects(([@[@1,@2] fk_first:^BOOL(id obj) { return [obj isEqual:@1]; }]), @1, @"Basic");
    XCTAssertEqualObjects(([@[@1,@2] fk_first:^BOOL(id obj) { return [obj isEqual:@2]; }]), @2, @"Basic");
}

- (void) test_fk_indexOfFirst
{
    XCTAssertEqual(([@[] fk_indexOfFirst:nil]), (NSUInteger)NSNotFound, @"Nil block -> response is always NSNotFound");
    XCTAssertEqual(([@[] fk_indexOfFirst:^BOOL(id obj) { return YES; }]), (NSUInteger)NSNotFound, @"Empty receiver -> response is always NSNotFound");
    XCTAssertEqual(([@[@2,@3] fk_indexOfFirst:^BOOL(id obj) { return [obj isEqual:@1]; }]), (NSUInteger)NSNotFound, @"Not found");
    XCTAssertEqual(([@[@1,@2] fk_indexOfFirst:^BOOL(id obj) { return [obj isEqual:@1]; }]), (NSUInteger)0, @"Basic");
    XCTAssertEqual(([@[@1,@2] fk_indexOfFirst:^BOOL(id obj) { return [obj isEqual:@2]; }]), (NSUInteger)1, @"Basic");
}

- (void) test_fk_withoutObject
{
    XCTAssertEqualObjects(([@[@"a",@"b",@"c"] fk_arrayWithoutObject:@"a"]),
                         (@[@"b",@"c"]),
                         @"Base case");
    XCTAssertEqualObjects(([@[@"a",@"b",@"a"] fk_arrayWithoutObject:@"a"]),
                         (@[@"b"]),
                         @"Multiple instances to remove");
    XCTAssertEqualObjects(([@[@"a",@"b",@"c"] fk_arrayWithoutObject:nil]),
                         (@[@"a", @"b",@"c"]),
                         @"nil");
}

- (void) test_fk_withoutObjects
{
    XCTAssertEqualObjects(([@[@"a",@"b",@"c"] fk_arrayWithoutObjects:@[@"a"]]),
                         (@[@"b",@"c"]),
                         @"Base case");
    XCTAssertEqualObjects(([@[@"a",@"b",@"c"] fk_arrayWithoutObjects:@[@"a",@"c"]]),
                         (@[@"b"]),
                         @"Multiple specified");
    XCTAssertEqualObjects(([@[@"a",@"b",@"a",@"c"] fk_arrayWithoutObjects:@[@"a",@"c"]]),
                         (@[@"b"]),
                         @"Multiple instances to remove");
    XCTAssertEqualObjects(([@[@"a",@"b",@"c"] fk_arrayWithoutObjects:nil]),
                         (@[@"a", @"b",@"c"]),
                         @"nil");
}

@end
