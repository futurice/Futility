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

- (instancetype) fk_map:(FKUnaryOperatorBlock)block
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self)
    {
        id o = block(obj);
        [ret addObject:(o ?: NSNull.null)];
    }
    return ret;
}

- (instancetype) fk_mapWithIndex:(FKIndexedEnumerationBlock)block
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    for (NSUInteger i = 0; i < self.count; i++)
    {
        id obj = self[i];
        id o = block(obj, i);
        [ret addObject:(o ?: NSNull.null)];
    }
    return ret;
}

- (instancetype) fk_parallelMap:(FKUnaryOperatorBlock)block onQueue:(dispatch_queue_t)queue
{
    NSUInteger count = self.count;
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++)
    {
        [ret addObject:NSNull.null];
    }
    
    dispatch_queue_t collectionQueue = dispatch_queue_create("com.Futurice.Futility.parallel-map-collection",
                                                             DISPATCH_QUEUE_SERIAL);
    dispatch_apply(count, queue, ^(size_t i) {
        id o = block(self[i]);
        dispatch_sync(collectionQueue, ^{
            ret[i] = o ?: NSNull.null;
        });
    });
    
    return ret;
}

- (instancetype) fk_parallelMap:(FKUnaryOperatorBlock)block
{
    return [self
            fk_parallelMap:block
            onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
}

- (instancetype) fk_filter:(FKObjectToBoolBlock)block
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self)
    {
        if (block(obj))
            [ret addObject:obj];
    }
    return ret;
}

- (id) fk_reduce:(FKBinaryOperatorBlock)block
{
    if (self.count == 0)
        return nil;
    id ret = self.firstObject;
    for (NSUInteger i = 1; i < self.count; i++)
    {
        ret = block(ret, self[i]);
    }
    return ret;
}

- (id) fk_first:(FKObjectToBoolBlock)block
{
    for (id obj in self)
    {
        if (block(obj))
            return obj;
    }
    return nil;
}

- (BOOL) fk_contains:(FKObjectToBoolBlock)block
{
    for (id obj in self)
    {
        if (block(obj))
            return YES;
    }
    return NO;
}

- (NSUInteger) fk_indexOfFirst:(FKObjectToBoolBlock)block
{
    for (NSUInteger i = 0; i < self.count; i++)
    {
        if (block(self[i]))
            return i;
    }
    return NSNotFound;
}

- (instancetype) fk_flattened
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

- (instancetype) fk_arrayWithoutDuplicates
{
    return [[NSOrderedSet orderedSetWithArray:self] array];
}

- (instancetype) fk_arrayWithoutNulls
{
    return [self fk_filter:^BOOL(id obj) {
        return ![obj isEqual:NSNull.null];
    }];
}

- (instancetype) fk_arrayWithoutEmpties
{
    return [self fk_filter:^BOOL(id obj) {
        return ([obj respondsToSelector:@selector(length)] && 0 < [obj length]);
    }];
}

- (instancetype) fk_arrayWithoutObject:(id)obj
{
    NSMutableArray *ret = self.mutableCopy;
    [ret removeObject:obj];
    return ret;
}

- (instancetype) fk_arrayWithoutObjects:(NSArray *)objs
{
    NSMutableArray *ret = self.mutableCopy;
    for (id obj in objs)
    {
        [ret removeObject:obj];
    }
    return ret;
}


- (NSDictionary *) fk_asDictionary
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (NSArray *obj in self)
    {
        if (![obj respondsToSelector:@selector(count)]
            || obj.count == 0
            || ![obj.firstObject conformsToProtocol:@protocol(NSCopying)]
            )
            continue;
        ret[obj.firstObject] = (1 < obj.count) ? obj[1] : NSNull.null;
    }
    return ret;
}

#pragma mark - Selector variants

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (instancetype) fk_mapSel:(SEL)selector
{
    // We could use -[NSArray valueForKey:] here but that would crash
    // as soon as one of the objects wasn't KVC-compliant for the given key.
    //
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self)
    {
        id o = [obj respondsToSelector:selector] ? [obj performSelector:selector] : nil;
        [array addObject:(o ?: NSNull.null)];
    }
    return array;
}

- (instancetype) fk_filterSel:(SEL)selector
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self)
    {
        if (([obj respondsToSelector:selector] && [obj performSelector:selector]) || NO)
            [array addObject:obj];
    }
    return array;
}

#pragma clang diagnostic pop

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

- (instancetype) fk_map:(FKKeyValueEnumerationBlock)block
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (id<NSCopying> key in self)
    {
        NSArray *mapped = block(key, self[key]);
        if (![mapped isKindOfClass:NSArray.class]
            || mapped.count < 2
            || ![mapped[0] conformsToProtocol:@protocol(NSCopying)]
            )
            continue;
        ret[mapped[0]] = mapped[1];
    }
    return ret;
}

- (instancetype) fk_dictionaryByMerging:(NSDictionary *)other
{
    NSMutableDictionary *ret = self.mutableCopy;
    [ret addEntriesFromDictionary:other];
    return ret;
}

@end
