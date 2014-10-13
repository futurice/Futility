//
//  NSArray+FKExtensions.h
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

typedef id(^FKUnaryOperatorBlock)(id obj);
typedef id(^FKBinaryOperatorBlock)(id x, id y);
typedef id(^FKIndexedEnumerationBlock)(id obj, NSUInteger idx);
typedef BOOL(^FKObjectToBoolBlock)(id obj);
typedef NSArray*(^FKKeyValueEnumerationBlock)(id<NSCopying> key, id value);


@interface NSArray (FKExtensions)

/// Create new array by performing block(obj) on each item
- (NSArray *) fk_map:(FKUnaryOperatorBlock)block;

/// Create new array by performing block(obj,idx) on each item
- (NSArray *) fk_mapWithIndex:(FKIndexedEnumerationBlock)block;

/// Create new array by performing block(obj) on each item in parallel
- (NSArray *) fk_parallelMap:(FKUnaryOperatorBlock)block;

/// Create new array by removing items for which block(obj) returns NO
- (NSArray *) fk_filter:(FKObjectToBoolBlock)block;

/// Return value obtained by performing block(x, y) for items left-to-right
/// (i.e. for [1,2,3,4] we would get (((1 op 2) op 3) op 4) )
- (id) fk_reduce:(FKBinaryOperatorBlock)block;

/// Return first item for which block(obj) returns YES
- (id) fk_first:(FKObjectToBoolBlock)block;

/// Return index of first item for which block(obj) returns YES
- (NSUInteger) fk_indexOfFirst:(FKObjectToBoolBlock)block;

/// Return whether array contains an item for which block(obj) returns YES
- (BOOL) fk_contains:(FKObjectToBoolBlock)block;

/// Create new array by
- (NSArray *) fk_flattened;

/// Return copy of self without duplicate values
- (NSArray *) fk_arrayWithoutDuplicates;

/// Return copy of self without NSNull values
- (NSArray *) fk_arrayWithoutNulls;

/// Return copy of self without empty values (typically NSStrings) or NSNulls
- (NSArray *) fk_arrayWithoutEmpties;

/// Return copy of self without occurrences of `obj`
- (NSArray *) fk_arrayWithoutObject:(id)obj;

/// Return copy of self without occurrences of the objects in `objs`
- (NSArray *) fk_arrayWithoutObjects:(NSArray *)objs;

/// Return @[@[a,x], @[c,y]] as @{a:x, c:y}
- (NSDictionary *) fk_asDictionary;

/// Create new array by performing `selector` on each item
- (NSArray *) fk_mapSel:(SEL)selector;

/// Create new array by removing items for which `selector` returns NO
- (NSArray *) fk_filterSel:(SEL)selector;

@end


@interface NSDictionary (FKExtensions)

/// Return @{a:x, c:y} as @[@[a,x], @[c,y]]
- (NSArray *) fk_pairs;

/// Create new dictionary by performing block(key,value) on each key-value pair
- (NSDictionary *) fk_map:(FKKeyValueEnumerationBlock)block;

/// Create a new dictionary by merging `other` with self, overwriting values for
/// existing keys
- (NSDictionary *) fk_dictionaryByMerging:(NSDictionary *)other;

@end
