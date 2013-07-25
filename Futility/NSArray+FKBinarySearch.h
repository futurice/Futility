//
//  NSArray+FKBinarySearch.h
//  Futility
//
//  Created by Oleg Grenrus on 9/15/12.
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
