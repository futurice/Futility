//
//  NSArray+FKExtensions.h
//
/*
The MIT License

Copyright (c) 2012-2013 Ali Rantakari

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#import <Foundation/Foundation.h>

typedef id (^FKArrayEnumerationBlock)(id obj);
typedef id (^FKArrayOperationBlock)(id x, id y);
typedef BOOL (^FKArrayMatchBlock)(id obj);

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
