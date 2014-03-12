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

typedef id(^FKArrayEnumerationBlock)(id obj);
typedef id(^FKArrayOperationBlock)(id x, id y);
typedef BOOL(^FKArrayMatchBlock)(id obj);

@interface NSArray (FKExtensions)

// Create new array by performing block(obj) on each item:
- (NSArray *) fk_map:(FKArrayEnumerationBlock)block;

// Create new array by removing items for which block(obj) returns NO:
- (NSArray *) fk_filter:(FKArrayMatchBlock)block;

// Return value obtained by performing block(x, y) for items left-to-right
// (i.e. for [1,2,3,4] we would get (((1 op 2) op 3) op 4) ):
- (id) fk_reduce:(FKArrayOperationBlock)block;

// Return first item for which block(obj) returns YES
- (id) fk_first:(FKArrayMatchBlock)block;

// Return whether array contains an item for which block(obj) returns YES
- (BOOL) fk_contains:(FKArrayMatchBlock)block;

// Return array by replacing all inner arrays with their contents
- (NSArray *) fk_flattened;

- (NSArray *) fk_arrayWithoutDuplicates;
- (NSArray *) fk_arrayWithoutNulls;
- (NSArray *) fk_arrayWithoutEmpties;

// Return @[@[a,x], @[c,y]] as @{a:x, c:y}
- (NSDictionary *) fk_asDictionary;

@end


@interface NSDictionary (FKExtensions)

// Return @{a:x, c:y} as @[@[a,x], @[c,y]]
- (NSArray *) fk_pairs;

- (NSDictionary *) fk_dictionaryByMerging:(NSDictionary *)other;

@end
