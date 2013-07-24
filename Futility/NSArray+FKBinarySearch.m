//
//  NSArray+FKBinarySearch.m
//  Futility
//
//  Created by Oleg Grenrus on 9/15/12.
//  Copyright (c) 2012 Futurice. All rights reserved.
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

        NSComparisonResult result = comparator([self objectAtIndex:imid]);

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

        NSComparisonResult result = comparator([self objectAtIndex:imid]);

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

        NSComparisonResult result = comparator([self objectAtIndex:imid]);

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
