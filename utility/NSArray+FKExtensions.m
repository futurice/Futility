//
//  NSArray+FKExtensions.m
//
/*
The MIT License

Copyright (c) 2012 Ali Rantakari

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

#import "NSArray+FKExtensions.h"

@implementation NSArray (FKExtensions)

- (NSArray *) fk_map:(FKArrayEnumerationBlock)block
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self)
    {
        id o = block(obj);
        [array addObject:(o == nil ? [NSNull null] : o)];
    }
    return array;
}

- (NSArray *) fk_filter:(FKArrayMatchBlock)block
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self)
    {
        if (block(obj))
            [array addObject:obj];
    }
    return array;
}

- (id) fk_reduce:(FKArrayOperationBlock)block
{
    id ret = [self objectAtIndex:0];
    if (self.count < 2)
        return ret;
    for (NSUInteger i = 1; i < self.count; i++)
    {
        ret = block(ret, [self objectAtIndex:i]);
    }
    return ret;
}

- (id) fk_first:(FKArrayMatchBlock)block
{
    for (id obj in self)
    {
        if (block(obj))
            return obj;
    }
    return nil;
}

- (NSArray *) fk_arrayWithoutDuplicates
{
    return [[NSSet setWithArray:self] allObjects];
}
- (NSArray *) fk_arrayWithoutNulls
{
    return [self fk_filter:^BOOL(id obj) {
        return (![obj isEqual:[NSNull null]]);
    }];
}


@end