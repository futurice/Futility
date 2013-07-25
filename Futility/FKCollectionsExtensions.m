//
//  NSArray+FKExtensions.m
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

#import "FKCollectionsExtensions.h"

@implementation NSArray (FKExtensions)

- (NSArray *) fk_map:(FKArrayEnumerationBlock)block
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self)
    {
        id o = block(obj);
        [ret addObject:(o ?: NSNull.null)];
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
    if (self.count == 0)
        return nil;
    id ret = self[0];
    if (self.count < 2)
        return ret;
    for (NSUInteger i = 1; i < self.count; i++)
    {
        ret = block(ret, self[i]);
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

- (NSArray *) fk_flattened
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count * 2];
    for (id obj in self)
    {
        if ([obj isKindOfClass:NSArray.class])
            [ret addObjectsFromArray:[obj fk_flattened]];
        else
            [ret addObject:obj];
    }
    return ret;
}

- (NSArray *) fk_arrayWithoutDuplicates
{
    // This seems to be faster than using an NSMutableOrderedSet
    //
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
        return ![obj isEqual:NSNull.null];
    }];
}
- (NSArray *) fk_arrayWithoutEmpties
{
    return [self fk_filter:^BOOL(id obj) {
        return ([obj respondsToSelector:@selector(length)] && 0 < [obj length]);
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
