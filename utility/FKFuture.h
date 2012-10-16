//
//  Future.h
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

#import <Foundation/Foundation.h>

#if __has_feature(objc_arc)

@class FKFuture;

typedef FKFuture *(^FKFutureFunction)(FKFuture *argument);

typedef FKFuture *(^FKFutureWithResult)(id result);
typedef FKFuture *(^FKFutureWithError)(NSError *error);

// -----------------------------------------------------------------------------

@interface FKWeak : NSObject

@property (nonatomic, weak) id object;

+ (FKWeak *)ref:(id)object;
- (id)initWithObject:(id)object;

@end

// -----------------------------------------------------------------------------

FKFuture *fk_null(); // [FKFuture futureWithResult:[NSNull null]]
FKFuture *fk_result(id result); // [FKFuture futureWithResult:result]
FKFuture *fk_fail(NSString *messageOrNil); // [FKFuture futureWithError:]
FKFuture *fk_error(NSError *error); // [FKFuture futureWithError:error]

FKFuture *fk_whenAll(NSArray *futures);
// FKFuture *fk_whenAny(NSArray *futures);

// -----------------------------------------------------------------------------

@interface NSArray (FKFutureExtensions)

- (FKFuture *)fk_whenAll;
// - (FKFuture *)fk_whenAny;

@end

// -----------------------------------------------------------------------------

@protocol FKFutureDelegate
- (void)futureWasCancelled:(NSString *)label;
@end

// -----------------------------------------------------------------------------

@interface FKFuture : NSObject

+ (FKFuture *)futureWithResult:(id)result;

+ (FKFuture *)futureWithError:(NSError *)error;

+ (FKFuture *)futureWithAll:(NSArray *)futures; // => will contain array of ids

// Will contain array of id and index.
// (E.g. @[@"result", @4] means that the 5th future has value @"result".)
//+ (FKFuture *)futureWithAny:(NSArray *)futures;

+ (FKFuture *)futureByCallingBlock:(FKFutureFunction)block
                           withArg:(FKFuture*)future;

+ (FKFuture *)futureByCallingBlock:(FKFutureFunction)block
                           withArg:(FKFuture*)future
                             queue:(dispatch_queue_t)queue; // default is NULL

+ (FKFuture *)futureWithDelegate:(id<FKFutureDelegate>)delegate
                           label:(id)label;

- (void)deliver:(FKFuture *)computedFuture;

@property (atomic, readonly) BOOL ready; // whether there's a result or an error
@property (atomic, readonly) id result;
@property (atomic, readonly) NSError *error;

@property (nonatomic) BOOL asap;
@property (nonatomic, readonly) dispatch_queue_t queue;

@property (nonatomic, readonly, copy) FKFuture *(^then)(FKFutureFunction function);
@property (nonatomic, readonly, copy) FKFuture *(^withResult)(FKFutureWithResult function);
@property (nonatomic, readonly, copy) FKFuture *(^withError)(FKFutureWithError function);

@property (nonatomic, readonly, copy) FKFuture *(^thenInMain)(FKFutureFunction function);
@property (nonatomic, readonly, copy) FKFuture *(^withResultInMain)(FKFutureWithResult function);
@property (nonatomic, readonly, copy) FKFuture *(^withErrorInMain)(FKFutureWithError function);

@property (nonatomic, readonly, copy) FKFuture *(^thenInQueue)(dispatch_queue_t queue,
                                                               FKFutureFunction function);
@property (nonatomic, readonly, copy) FKFuture *(^withResultInQueue)(dispatch_queue_t queue,
                                                                     FKFutureWithResult function);
@property (nonatomic, readonly, copy) FKFuture *(^withErrorInQueue)(dispatch_queue_t queue,
                                                                    FKFutureWithError function);

- (void)wait;
//- (void)waitFor:(NSTimeInterval)duration;
//- (void)waitUntil:(NSDate *)date;

@end

#endif // __has_feature(objc_arc)
