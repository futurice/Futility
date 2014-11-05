//
//  NSArray+FKBinarySearch.m
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

#import "NSArray+FKBinarySearch.h"

@implementation NSArray (FKBinarySearch)
- (NSUInteger)indexOfFirstObjectGreaterUsingComparator:(FKBinarySearchComparatorBlock)comparator
{
    NSUInteger imin = 0;
    NSUInteger imax = [self count];

    // continue searching while [imin,imax) is not empty
    while (imax > imin)
    {
        NSUInteger imid = (imax + imin) / 2;

        NSComparisonResult result = comparator(self[imid]);

        // self[mid] compare o  == NSOrderedAscending <=> o > self[imid]
        if (result == NSOrderedAscending) {
            imin = imid + 1;
        } else if (result == NSOrderedSame) {
            imin = imid + 1;
        } else { // result == NSOrderedDescending
            imax = imid;
        }
    }

    return imin;
}

- (NSUInteger)indexOfLastObjectLessOrEqualUsingComparator:(FKBinarySearchComparatorBlock)comparator
{
    NSUInteger result = [self indexOfFirstObjectGreaterUsingComparator:comparator];
    return (result == 0) ? [self count] : result - 1;
}

- (NSUInteger)indexOfFirstObjectGreaterOrEqualUsingComparator:(FKBinarySearchComparatorBlock)comparator
{
    NSUInteger imin = 0;
    NSUInteger imax = [self count];

    // continue searching while [imin,imax) is not empty
    while (imax > imin)
    {
        NSUInteger imid = (imax + imin) / 2;

        NSComparisonResult result = comparator(self[imid]);

        // self[mid] compare o  == NSOrderedAscending <=> o > self[imid]
        if (result == NSOrderedAscending) {
            imin = imid + 1;
        } else if (result == NSOrderedSame) {
            imax = imid;
        } else { // result == NSOrderedDescending
            imax = imid;
        }
    }
    return imin;
}

- (NSUInteger)indexOfLastObjectLessUsingComparator:(FKBinarySearchComparatorBlock)comparator
{
    NSUInteger imin = 0;
    NSUInteger imax = [self count];

    // continue searching while [imin,imax) is not empty
    while (imax > imin)
    {
        NSUInteger imid = (imax + imin) / 2;

        NSComparisonResult result = comparator(self[imid]);

        // self[mid] compare o  == NSOrderedAscending <=> o > self[imid]
        if (result == NSOrderedAscending) {
            imin = imid + 1;
        } else if (result == NSOrderedSame) {
            imax = imid;
        } else { // result == NSOrderedDescending
            imax = imid;
        }
    }

    NSUInteger result = imin;
    return (result == 0) ? [self count] : result - 1;

}

@end
