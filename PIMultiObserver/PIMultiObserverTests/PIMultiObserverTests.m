//
//  PIMultiObserverTests.m
//  PIMultiObserverTests
//
//  Created by Akos Polster on 20/10/15.
//  Copyright © 2015 Akos Polster. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../PIMultiObserver.h"

@interface PIMultiObserverTests : XCTestCase
@property BOOL bool1;
@property BOOL bool2;
@property NSString *string1;
@end

@implementation PIMultiObserverTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

/// Test that
/// - "observeAnd" calls the notification block initially
/// - Then every time one an observed propery changes
/// - The notification block is called with the AND combination of the observed values
- (void)testObserveAnd {
    NSArray *expectations = @[
                              [self expectationWithDescription:@"Initial notification"],
                              [self expectationWithDescription:@"Second notification"]
                              ];
    self.bool1 = YES;
    self.bool2 = NO;
    __block int notificationCount = 0;
    __block NSMutableArray *results = [NSMutableArray array];
    PIMultiObserver *mo = [[PIMultiObserver alloc] init];
    [mo observeAnd:@[[PIObserver observerOf:self keyPath:@"bool1"],
                     [PIObserver observerOf:self keyPath:@"bool2"]]
             block:^(BOOL combinedValue) {
        [expectations[notificationCount] fulfill];
        [results addObject:@(combinedValue)];
        notificationCount++;
    }];
    
    self.bool2 = YES;
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssert(notificationCount == 2);
    XCTAssert([results[0] boolValue] == NO);
    XCTAssert([results[1] boolValue] == YES);
}

/// Test that "observeAllYes" only calls the notification block when all observed values are YES
- (void)testObserveAllYes {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Notification"];
    self.bool1 = YES;
    self.bool2 = NO;
    __block NSMutableArray *results = [NSMutableArray array];
    PIMultiObserver *mo = [[PIMultiObserver alloc] init];
    [mo observeAllYes:@[[PIObserver observerOf:self keyPath:@"bool1"],
                        [PIObserver observerOf:self keyPath:@"bool2"]]
             block:^(BOOL combinedValue) {
                 [expectation fulfill];
                 [results addObject:@(combinedValue)];
             }];
    
    self.bool1 = NO;
    self.bool2 = YES;
    self.bool1 = YES;
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssert(results.count == 1);
    XCTAssert([results[0] boolValue] == YES);
}

/// Test "observeAnd" using mappers
- (void)testObserveAndUsingMapper {
    NSArray *expectations = @[[self expectationWithDescription:@"Initial notification"],
                              [self expectationWithDescription:@"Second notification"]];
    self.bool1 = YES;
    self.string1 = @"bad";
    __block int notificationCount = 0;
    __block NSMutableArray *results = [NSMutableArray array];
    PIMultiObserver *mo = [[PIMultiObserver alloc] init];
    [mo observeAnd:@[[PIObserver observerOf:self keyPath:@"bool1"],
                     [PIObserver observerOf:self keyPath:@"string1" mapper:^BOOL(NSString *value) {return [value isEqualToString:@"good"];}]]
             block:^(BOOL combinedValue) {
                 [expectations[notificationCount] fulfill];
                 [results addObject:@(combinedValue)];
                 notificationCount++;
             }];
    
    self.string1 = @"good";
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssert(notificationCount == 2);
    XCTAssert([results[0] boolValue] == NO);
    XCTAssert([results[1] boolValue] == YES);
}

/// Test multiple multi-observations for the same property
- (void)testMultiMulti {
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"Notification1"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Notification2"];
    PIMultiObserver *mo = [[PIMultiObserver alloc] init];
    [mo observeAnd:@[[PIObserver observerOf:self keyPath:@"bool1"]] block:^(BOOL combinedValue) {
        [expectation1 fulfill];
    }];
    [mo observeAnd:@[[PIObserver observerOf:self keyPath:@"bool2"], [PIObserver observerOf:self keyPath:@"bool1"]] block:^(BOOL combinedValue) {
        [expectation2 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
