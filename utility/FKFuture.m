//
//  Future.m
//  ARC only
//  iOS 5.1+, Xcode 4.5
//
/*
The MIT License

Copyright (c) 2012 Pyry Jahkola

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

#if __has_feature(objc_arc)

#import "FKFuture.h"



// --- Helper code -------------------------------------------------------------




// -----------------------------------------------------------------------------

FKFuture *fk_null()
{
    return [FKFuture futureWithResult:[NSNull null]];
}

FKFuture *fk_result(id result)
{
    return [FKFuture futureWithResult:result];
}

FKFuture *fk_fail(NSString *message)
{
    return fk_error([NSError
        errorWithDomain:@"FKFuture"
        code:-1
        userInfo:message ? @{@"message": message} : nil]);
}

FKFuture *fk_error(NSError *error)
{
    return [FKFuture futureWithError:error];
}

FKFuture *fk_whenAll(NSArray *futures)
{
    return [FKFuture futureWithAll:futures];
}

//FKFuture *fk_whenAny(NSArray *futures)
//{
//    return [FKFuture futureWithAny:futures];
//}



// -----------------------------------------------------------------------------

@implementation NSArray (FKFutureExtensions)

- (FKFuture *)fk_whenAll
{
    return fk_whenAll(self);
}

//- (FKFuture *)fk_whenAny
//{
//    return fk_whenAny(self);
//}

@end



// -----------------------------------------------------------------------------

@interface FKWeak ()
{
    __weak id _object;
}
@end

@implementation FKWeak

+ (FKWeak *)ref:(id)object
{
    return [[FKWeak alloc] initWithObject:object];
}

- (id)initWithObject:(id)object
{
    if ((self = [super init])) {
        _object = object;
    }
    return self;
}

- (id)object
{
    return _object;
}

@end



// -----------------------------------------------------------------------------

@interface FKFutureQueue : NSObject
{
    NSMutableArray *_futures;
    NSMutableArray *_futuresWithPriority;
}

- (void)enqueueFuture:(FKFuture *)future;
- (void)computeOne;

@end


static void fk_futureDispatch(FKFuture *future);



// =============================================================================


@interface FKFuture ()

@property (nonatomic, readonly) NSUInteger asapCount; // this count gets incremented by every ASAP output

@property (nonatomic, readwrite) dispatch_queue_t queue;
@property (nonatomic, readonly) FKFuture *(^function)(FKFuture *future);

@property (nonatomic, readonly) NSArray *inputs;
@property (nonatomic, readonly) NSUInteger blockingInputCount;

@property (nonatomic, readonly) NSMutableArray *outputs; // FKWeak-wrapped FKFutures, or nil

@end



// =============================================================================


FKFuture *fk_futureAll(NSArray *futures) {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:futures.count];
    for (FKFuture *future in futures) {
        if (future.error) return future;
        [result addObject:future.result];
    }
    return fk_result(result);
}

FKFuture *fk_futureAny(NSArray *futures) {
    for (FKFuture *future in futures) {
        if (future.result) return fk_result(@[future.result]);
    }
    return fk_fail(@"no future with result");
}

@implementation FKFuture

- (id)init
{
    if ((self = [super init])) {
        _outputs = [NSMutableArray array];
    }
    return self;
}

- (id)initWithResult:(id)result
{
    if ((self = [super init])) {
        _result = result;
    }
    return self;
}

- (id)initWithError:(NSError *)error
{
    if ((self = [super init])) {
        _error = error;
    }
    return self;
}

- (id)initWithBlock:(FKFutureFunction)function
          arguments:(NSArray *)arguments
              queue:(dispatch_queue_t)queue
{
    NSAssert(function, @"block cannot be nil");
    NSAssert(arguments.count > 0, @"arguments array cannot be empty");
    for (FKFuture *argument in arguments) {
        NSAssert([argument isKindOfClass:[FKFuture class]],
                 @"arguments must have type FKFuture");
    }

    if ((self = [super init])) {
        if (queue) {
            _queue = queue;
        } else {
            for (FKFuture *argument in arguments) {
                if (argument->_queue) {
                    _queue = argument->_queue;
                    break;
                }
            }
        }
        if (_queue) dispatch_retain(_queue);

        _inputs = arguments;
        _outputs = [NSMutableArray array];
        _function = function;
        _blockingInputCount = _inputs.count;
        for (FKFuture *input in _inputs) {
            if (![input addOutput:self]) {
                [self inputDidCompute:input];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    if (_queue) dispatch_release(_queue);
}



// -----------------------------------------------------------------------------

- (BOOL)addOutput:(FKFuture *)output
{
    @synchronized(self) {
        if (_outputs) {
            [_outputs addObject:[FKWeak ref:output]];
            return YES;
        } else {
            return NO;
        }
    }
}

- (void)compute
{
    NSArray *inputs = nil;
    @synchronized(self) {
        inputs = _inputs;
        _inputs = nil;
    }
    NSAssert(inputs, @"already computed");
    FKFuture *result = _function(fk_futureAll(inputs));

    if (result.result) {
        [self deliverResult:result.result];
    } else {
        [self deliverError:result.error];
    }
}

- (void)inputDidCompute:(FKFuture *)argument
{
    @synchronized(self) {
        NSAssert(_blockingInputCount > 0, @"invalid call: arguments were already computed");
        NSAssert(argument.ready, @"invalid call: argument is not ready");
        _blockingInputCount--;
    }
    
    // TODO: different handling for futures expecting *any* input to have result

    if (argument.error || _blockingInputCount == 0) {
        dispatch_queue_t queue = self.queue;

        // TODO: use FKFutureQueue instead of directly queuing

        __weak FKFuture *weakSelf = self;
        dispatch_async(queue, ^{ [weakSelf compute]; });
    }
}



// -----------------------------------------------------------------------------

- (BOOL)ready
{
    @synchronized(self) {
        return _result || _error;
    }
}

- (dispatch_queue_t)queue
{
    return _queue ?
        _queue : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)setAsap:(BOOL)asap
{
    if (_asap == asap) return;
    
    _asap = asap;
    // TODO: prioritize the scheduling of inputs
    // TODO: prioritize own scheduling
}


// -----------------------------------------------------------------------------

+ (FKFuture *)futureWithResult:(id)result
{
    if (result) {
        return [[FKFuture alloc] initWithResult:result];
    } else {
        return [FKFuture futureWithError:[NSError
            errorWithDomain:@"FKFuture" code:-1 userInfo:nil]];
    }
}

+ (FKFuture *)futureWithError:(NSError *)error
{
    if (!error) {
        error = [NSError errorWithDomain:@"FKFuture" code:-1 userInfo:nil];
    }
    return [[FKFuture alloc] initWithError:error];
}

+ (FKFuture *)futureWithAll:(NSArray *)futures
{
    return [[FKFuture alloc]
        initWithBlock:^(FKFuture *future) { return future; }
        arguments:futures
        queue:NULL];
}

//+ (FKFuture *)futureWithAny:(NSArray *)futures
//{
//    for (id obj in futures) {
//        NSAssert(obj && [obj isKindOfClass:[FKFuture class]],
//                 @"the array contains non-futures");
//    }
//    
//    FKFuture *future = [[FKFuture alloc] init];
//    // arg ???
//    
//    return nil; // TODO
//}

+ (FKFuture *)futureByCallingBlock:(FKFutureFunction)block
                           withArg:(FKFuture *)arg
{
    return [FKFuture futureByCallingBlock:block
                     withArg:arg
                     queue:arg.queue];
}

+ (FKFuture *)futureByCallingBlock:(FKFutureFunction)block
                           withArg:(FKFuture *)arg
                             queue:(dispatch_queue_t)queue
{
    return [[FKFuture alloc]
        initWithBlock:^(FKFuture *future) {
            return block(future.result ? fk_result(future.result[0]) : future);
        }
        arguments:@[arg]
        queue:queue];
}

+ (FKFuture *)futureWithManualDelivery
{
    return [[FKFuture alloc] init]; // everything default-initialized
}

- (void)deliverResult:(id)result
{
    if (!result) {
        NSAssert(NO, @"result cannot be nil");
        return;
    }
    @synchronized(self) {
        if (_result || _error) {
            NSAssert(NO, @"cannot deliver result to a future which is ready");
            return;
        } else if (_inputs) {
            NSAssert(NO, @"cannot deliver result to a scheduled future");
            return;
        } else {
            _result = result;
        }
    }
    [self notifyOutputs];
}

- (void)deliverError:(id)error
{
    if (!error) {
        NSAssert(NO, @"error cannot be nil");
        return;
    } else if (![error isKindOfClass:[NSError class]]) {
        NSAssert(NO, @"error must be kind of class NSError");
        return;
    }
    @synchronized(self) {
        if (_result || _error) {
            NSAssert(NO, @"cannot deliver error to a future which is ready");
            return;
        } else if (_inputs) {
            NSAssert(NO, @"cannot deliver error to a scheduled future");
            return;
        } else {
            _error = error;
        }
    }
    [self notifyOutputs];
}

- (void)notifyOutputs
{
    NSAssert(self.ready, @"");
    NSArray *outputs = nil;
    @synchronized(self) {
        outputs = _outputs;
        _outputs = nil;
    }
    for (FKWeak *ref in outputs) {
        [[ref object] inputDidCompute:self];
    }
}

- (FKFuture *(^)(FKFutureFunction))then
{
    __strong FKFuture *future = self;
    return ^(FKFutureFunction block) {
        return [FKFuture futureByCallingBlock:block withArg:future];
    };
}

- (FKFuture *(^)(FKFutureWithResult))withResult
{
    __strong FKFuture *future = self;
    return ^(FKFutureWithResult block) {
        return [FKFuture
            futureByCallingBlock:^(FKFuture *future) {
                return future.result ? block(future.result) : future;
            }
            withArg:future];
    };
}

- (FKFuture *(^)(FKFutureWithError))withError
{
    __strong FKFuture *future = self;
    return ^(FKFutureWithError block) {
        return [FKFuture
            futureByCallingBlock:^(FKFuture *future) {
                return future.error ? block(future.error) : fk_fail(nil);
            }
            withArg:future];
    };
}

- (FKFuture *(^)(FKFutureFunction))thenInMain
{
    __strong FKFuture *future = self;
    return ^(FKFutureFunction block) {
        return [FKFuture
            futureByCallingBlock:block
            withArg:future
            queue:dispatch_get_main_queue()];
    };
}

- (FKFuture *(^)(FKFutureWithResult))withResultInMain
{
    __strong FKFuture *future = self;
    return ^(FKFutureWithResult block) {
        return [FKFuture
            futureByCallingBlock:^(FKFuture *future) {
                return future.result ? block(future.result) : future;
            }
            withArg:future
            queue:dispatch_get_main_queue()];
    };
}

- (FKFuture *(^)(FKFutureWithError))withErrorInMain
{
    __strong FKFuture *future = self;
    return ^(FKFutureWithError block) {
        return [FKFuture
            futureByCallingBlock:^(FKFuture *future) {
                return future.error ? block(future.error) : fk_fail(nil);
            }
            withArg:future
            queue:dispatch_get_main_queue()];
    };
}

- (FKFuture *(^)(dispatch_queue_t, FKFutureFunction))thenInQueue
{
    __strong FKFuture *future = self;
    return ^(dispatch_queue_t queue, FKFutureFunction block) {
        return [FKFuture futureByCallingBlock:block withArg:future queue:queue];
    };
}

- (FKFuture *(^)(dispatch_queue_t, FKFutureWithResult))withResultInQueue
{
    __strong FKFuture *future = self;
    return ^(dispatch_queue_t queue, FKFutureWithResult block) {
        return [FKFuture
            futureByCallingBlock:^(FKFuture *future) {
                return future.result ? block(future.result) : future;
            }
            withArg:future
            queue:queue];
    };
}

- (FKFuture *(^)(dispatch_queue_t, FKFutureWithError))withErrorInQueue
{
    __strong FKFuture *future = self;
    return ^(dispatch_queue_t queue, FKFutureWithError block) {
        return [FKFuture
            futureByCallingBlock:^(FKFuture *future) {
                return future.error ? block(future.error) : fk_fail(nil);
            }
            withArg:future
            queue:queue];
    };
}

- (void)wait
{
    if (self.ready) return; // nothing to wait for

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    self.then(^(id _) {
        dispatch_group_leave(group);
        return fk_null();
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_release(group);
}

@end



// -----------------------------------------------------------------------------

@implementation FKFutureQueue

- (void)enqueueFuture:(FKFuture *)future
{
    @synchronized(self) {
        [_futures addObject:future];
        @synchronized(future) {
            [_futuresWithPriority addObject:future];
        }
    }
}

- (void)computeOne
{
    FKFuture *future = nil;
    @synchronized(self) {
        if (_futuresWithPriority.count) {
            future = _futuresWithPriority[0];
            [_futuresWithPriority removeObjectAtIndex:0];
            [_futures removeObjectIdenticalTo:future];
        } else if (_futures.count) {
            future = _futures[0];
            [_futures removeObjectAtIndex:0];
        } else {
            NSAssert(false, @"no queued future to compute!");
        }
    }
    [future compute];
}

@end


void fk_futureDispatch(FKFuture *future)
{
    
}

#endif // __has_feature(objc_arc)
