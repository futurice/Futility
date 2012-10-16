//
//  FKFutureTests.m
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

#import <SenTestingKit/SenTestingKit.h>

#import "FKFuture.h"

// -----------------------------------------------------------------------------

@interface FKDealloc : NSObject
@property (nonatomic, readonly) id label;
@property (nonatomic, readonly) NSMutableArray *target;
- (id)initWithLabel:(id)label target:(NSMutableArray *)target;
@end

@implementation FKDealloc
- (id)initWithLabel:(id)label target:(NSMutableArray *)target
{
    if ((self = [super init])) {
        _label = label;
        _target = target;
    }
    return self;
}
- (void)dealloc
{
    [self.target addObject:self.label];
}
@end

// -----------------------------------------------------------------------------

@interface FKFutureTestDelegate : NSObject <FKFutureDelegate>
@property (atomic) NSMutableArray *cancelledLabels;
@property (atomic, readonly) NSUInteger cancelledCount;
@end

@implementation FKFutureTestDelegate

- (id)init
{
    if (!(self = [super init])) return nil;
    self.cancelledLabels = [NSMutableArray array];
    return self;
}

- (void)futureWasCancelled:(id)label
{
    @synchronized(self) {
        [self.cancelledLabels addObject:label];
    }
}

- (NSUInteger)cancelledCount
{
    return self.cancelledLabels.count;
}

@end

// -----------------------------------------------------------------------------

@interface FKFutureTests : SenTestCase
// No publicly used interface.
@end

@implementation FKFutureTests

- (void)testDealloc
{
    NSMutableArray *tracker = [NSMutableArray array];
    FKDealloc *object = [[FKDealloc alloc] initWithLabel:@1 target:tracker];

    STAssertEqualObjects(tracker, @[], @"");

    object = nil;
    
    STAssertEqualObjects(tracker, @[@1], @"");
    
    FKWeak *weak = nil;
    
    @autoreleasepool {
        object = [[FKDealloc alloc] initWithLabel:@2 target:tracker];
        weak = [FKWeak ref:object];
        
        STAssertEquals(weak.object, object, @"");
        STAssertEqualObjects(tracker, @[@1], @"");
        
        object = nil;
    }
    
    NSLog(@"weak.object: %@", weak.object);
    STAssertNil(weak.object, @"");
    STAssertEqualObjects(tracker, (@[@1, @2]), @"");
}

- (void)testNull
{
    FKFuture *future = fk_null();
    STAssertEqualObjects(future.result, [NSNull null], @"has null result");
    STAssertNil(future.error, @"has no error");
    STAssertTrue(future.ready, @"immediately ready after construction");
}

- (void)testWithResult
{
    NSArray *result = @[@YES, @"two", @3];
    FKFuture *future = fk_result(result);
    STAssertTrue(future.ready, @"is ready immediately after construction");
    STAssertEqualObjects(future.result, result, @"has given result");
    STAssertNil(future.error, @"has no error");
}

- (void)testFail1
{
    FKFuture *future = fk_fail(@"bad");
    STAssertTrue(future.ready, @"is ready immediately after construction");
    STAssertNil(future.result, @"has no result");
    STAssertEqualObjects(future.error.domain, @"FKFuture",
                         @"preset error domain");
    STAssertEqualObjects(future.error.userInfo[@"message"], @"bad",
                         @"given error message");
}

- (void)testFail2
{
    FKFuture *future = fk_fail(nil);
    STAssertTrue(future.ready, @"is ready immediately after construction");
    STAssertNil(future.result, @"has no result");
    STAssertEqualObjects(future.error.domain, @"FKFuture",
                         @"preset error domain");
    STAssertNil(future.error.userInfo[@"message"], @"no error message given");
}

- (void)testWithError
{
    NSError *error = [NSError errorWithDomain:@"FKFutureTests" code:-1 userInfo:nil];
    FKFuture *future = fk_error(error);
    STAssertTrue(future.ready, @"is ready immediately after construction");
    STAssertNil(future.result, @"has no result");
    STAssertEqualObjects(future.error, error, @"has given error");
}

- (void)testThen
{
    FKFutureWithResult (^find)(id) = ^(id object) {
        return ^(NSArray *array) {
            NSUInteger index = [array indexOfObject:object];
            NSLog(@"find => %d", index);
            return index != NSNotFound ? fk_result(@(index)) : fk_fail(@"oops");
        };
    };

    FKFutureWithResult describe = ^(id obj) {
        NSString *result = [obj description];
        NSLog(@"describe => %@", result);
        return fk_result(result);
    };

    FKFuture *input = fk_result(@[@2.0, @"2", @2]);
    FKFuture *future1 = input.withResult(find(@"2"));
    FKFuture *future2 = input.withResult(find(@3));
    FKFuture *future3 = future2.withResult(describe);
    FKFuture *future4 = input.withResult(find(@"2")).withResult(describe);

    [future1 wait];
    STAssertTrue(future1.ready, @"Ready after wait");
    STAssertEqualObjects(future1.result, @1, @"Finds object at index 1");
    STAssertNil(future1.error, @"No error");

    [future3 wait];
    STAssertTrue(future2.ready, @"Ready having waited for dependent future");
    STAssertNil(future2.result, @"No result");
    STAssertNotNil(future2.error, @"Does not find @3");
    STAssertEqualObjects(future2.error.userInfo[@"message"], @"oops", @"");

    STAssertTrue(future3.ready, @"Ready after wait");
    STAssertNil(future3.result, @"No result");
    STAssertNotNil(future3.error, @"Inherits error from future2");
    STAssertEqualObjects(future3.error.userInfo[@"message"], @"oops", @"");

    [future4 wait];
    STAssertTrue(future4.ready, @"Ready after wait");
    STAssertEqualObjects(future4.result, @"1", @"Previous result as string");
    STAssertNil(future4.error, @"No error");
}

- (void)testCancellation
{
    FKFutureWithResult (^sleep)(NSTimeInterval) = ^(NSTimeInterval interval) {
        return ^(id object) {
            [NSThread sleepForTimeInterval:interval];
            return fk_result(object);
        };
    };
    FKFutureFunction failTheTest = ^(FKFuture *ignored) {
        STFail(@"this block should not get called because of cancellation");
        return fk_fail(@"this block should've never been called");
    };

    FKFuture *input = fk_result(@123);
    FKFuture *future1, *future2, *future3;

    STAssertTrue(input.ready, @"Constructed as ready");

    @autoreleasepool {
        future1 = input.withResult(sleep(0.01));
        future2 = future1.then(failTheTest);
        future3 = future1.then(sleep(0.02));

        future2 = nil;
    }

    STAssertFalse(future1.ready, @"0.01 seconds should not have yet elapsed");
    STAssertFalse(future3.ready, @"0.03 seconds should not have yet elapsed");
    
    [future3 wait];
    
    STAssertTrue(future1.ready, @"Ready after wait");
    STAssertTrue(future3.ready, @"Ready after wait");
}

- (void)testAll1
{
    FKFuture *input = fk_result(@"That that is is that that is not is not is that it it is");
    FKFuture *length = input.withResult(^(NSString *string) {
        [NSThread sleepForTimeInterval:0.03];
        return fk_result(@(string.length));
    });
    FKFuture *firstWord = input.withResult(^(NSString *string) {
        [NSThread sleepForTimeInterval:0.01];
        return fk_result([string componentsSeparatedByString:@" "][0]);
    });
    FKFuture *wordCounts = input.withResult(^(NSString *string) {
        [NSThread sleepForTimeInterval:0.01];
        NSArray *words = [string componentsSeparatedByString:@" "];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSString *word in words) {
            dict[word] = @([dict[word] unsignedIntegerValue] + 1);
        }
        return fk_result(dict);
    });
    
    STAssertFalse(length.ready, @"Still sleeping");
    STAssertFalse(firstWord.ready, @"Still sleeping");
    STAssertFalse(wordCounts.ready, @"Still sleeping");
    
    FKFuture *wordThings = @[firstWord, wordCounts].fk_whenAll;

    STAssertFalse(wordThings.ready, @"Both inputs are sleeping, so am I");

    [wordThings wait];

    STAssertFalse(length.ready, @"Still sleeping");
    STAssertTrue(firstWord.ready, @"Ready having waited for dependent future");
    STAssertTrue(wordCounts.ready, @"Ready having waited for dependent future");
    STAssertTrue(wordThings.ready, @"Ready after wait");
    
    NSArray *result = wordThings.result;
    
    STAssertEqualObjects(result, (@[
        @"That",
        @{
            @"That": @1,
            @"that": @4,
            @"is": @6,
            @"it": @2,
            @"not": @2
        }
    ]), @"Contains results from both futures");
}

- (void)testManualDelivery
{
    FKFuture *future1 = [FKFuture futureWithDelegate:nil label:nil];
    FKFuture *future2 = [FKFuture futureWithDelegate:nil label:nil];
    FKFuture *future3 = future2.withResult(^(NSString *s) {
        return fk_result(@(s.length));
    });
    
    STAssertFalse(future1.ready, @"not ready before manual delivery");
    STAssertFalse(future2.ready, @"not ready before manual delivery");

    [future2 deliver:fk_result(@"foo")];
    
    STAssertFalse(future1.ready, @"not ready before manual delivery");
    STAssertTrue(future2.ready, @"ready after manual delivery");
    STAssertEqualObjects(future2.result, @"foo", @"");
    
    [future1 deliver:fk_fail(@"doh!")];
    
    STAssertTrue(future1.ready, @"ready after manual delivery");
    STAssertEqualObjects(future1.error.userInfo[@"message"], @"doh!", @"");
    
    [future3 wait];
    
    STAssertEqualObjects(future3.result, @3, @"");
}

- (void)testDelegation
{
    FKFutureTestDelegate *delegate = [[FKFutureTestDelegate alloc] init];

    STAssertEquals(delegate.cancelledCount, 0U, @"");
    
    @autoreleasepool {
        FKFuture *future = [FKFuture futureWithDelegate:delegate label:@"1"];
        future = nil;
    }
    
    STAssertEquals(delegate.cancelledCount, 1U, @"");

    @autoreleasepool {
        FKFuture *future = [FKFuture futureWithDelegate:delegate label:@"2"];
        [future deliver:fk_result(@123)];
        STAssertEqualObjects(future.result, @123, @"");
    }

    STAssertEquals(delegate.cancelledCount, 1U, @"");

    @autoreleasepool {
        FKFuture *future = [FKFuture futureWithDelegate:delegate label:@"3"];
        future = nil;
    }
    
    STAssertEqualObjects(delegate.cancelledLabels, (@[@"1", @"3"]), @"");
}

@end
