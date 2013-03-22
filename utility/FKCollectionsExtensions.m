//
//  NSArray+FKExtensions.m
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

#import "FKCollectionsExtensions.h"

@implementation NSArray (FKExtensions)

- (NSArray *) fk_map:(FKArrayEnumerationBlock)block
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self)
    {
        id o = block(obj);
        [ret addObject:(o == nil ? [NSNull null] : o)];
    }
    return ret;
}

- (NSArray *) fk_filter:(FKArrayMatchBlock)block
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self)
    {
        if (block(obj))
            [ret addObject:obj];
    }
    return ret;
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

- (BOOL) fk_contains:(FKArrayMatchBlock)block
{
    for (id obj in self)
    {
        if (block(obj))
            return YES;
    }
    return NO;
}

- (NSArray *) fk_arrayWithoutDuplicates
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self)
    {
        if (![ret containsObject:obj])
            [ret addObject:obj];
    }
    return ret;
}
- (NSArray *) fk_arrayWithoutNulls
{
    return [self fk_filter:^BOOL(id obj) {
        return (![obj isEqual:NSNull.null]);
    }];
}

- (NSDictionary *) fk_asDictionary
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (NSArray *obj in self)
    {
        if (![obj respondsToSelector:@selector(count)]
            || obj.count == 0
            || ![obj[0] conformsToProtocol:@protocol(NSCopying)]
            )
            continue;
        ret[obj[0]] = (1 < obj.count) ? obj[1] : NSNull.null;
    }
    return ret;
}

@end


@implementation NSDictionary (FKExtensions)

- (NSArray *) fk_pairs
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    for (id key in self)
    {
        [ret addObject:@[key, self[key]]];
    }
    return ret;
}

- (NSDictionary *) fk_dictionaryByMerging:(NSDictionary *)other
{
    NSMutableDictionary *ret = self.mutableCopy;
    [ret addEntriesFromDictionary:other];
    return ret;
}

@end
