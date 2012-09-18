//
//  NSArray+FKBinarySearch.h
//  FuKit
//
//  Created by Oleg Grenrus on 9/15/12.
//  Copyright (c) 2012 Futurice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (FKBinarySearch)
/**
 Binary search operations for sorted arrays

 Influenced by std::lower_bound and std::upper_bound from C++.
 Consider using them (and c++ data structures), if you have a lot of data.

 With comparor defines as:
 ^NSComparisonResult(id object) {
     return [(NSNumber *)object compare:@3];
 }

 Function below should return indexes of values:
 2 2 2 3 3 3 4 4 4
     ^ ^   ^ ^- indexOfFirstObjectGreater
     | |   +--- indexOfLastObjectEqualOrLess
     | +------- indexOfFirstObjectEqualOrGreater
     +--------- indexOfLastObjectLess

 2 2 2 4 4 4
     ^ ^------- indexOfFirstObjectGreater | indexOfFirstObjectEqualOrGreater
     +--------- indexOfLastObjectLess | indexOfLastObjectEqualOrLess

 */

typedef NSComparisonResult (^FKBinarySearchComparatorBlock)(id object);

/** Find the first object greater than, in other words for which comparator returns NSOrderedAscending.
 * @param comparator Comparator block to call
 */
- (NSUInteger)indexOfFirstObjectGreaterUsingComparator:(FKBinarySearchComparatorBlock)comparator;

/** Find the last object less or equal, in other words for which comparator returns NSOrderedDescending or NSOrderedSame.
 * @param comparator Comparator block to call
 */
- (NSUInteger)indexOfLastObjectLessOrEqualUsingComparator:(FKBinarySearchComparatorBlock)comparator;

/** Find the first object greater or equal than, in other words for which comparator returns NSOrderedAscending or NSOrderedSame.
 * @param comparator Comparator block to call
 */
- (NSUInteger)indexOfFirstObjectGreaterOrEqualUsingComparator:(FKBinarySearchComparatorBlock)comparator;

/** Find the first object less than, in other words for which comparator returns NSOrderedDescending.
 * @param comparator Comparator block to call
 */
- (NSUInteger)indexOfLastObjectLessUsingComparator:(FKBinarySearchComparatorBlock)comparator;

@end
