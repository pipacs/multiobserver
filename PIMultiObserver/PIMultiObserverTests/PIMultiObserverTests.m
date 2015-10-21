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
    [mo observeAnd:@[self, @"bool1", self, @"bool2"] block:^(BOOL combinedValue) {
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
    [mo observeAllYes:@[self, @"bool1", self, @"bool2"] block:^(BOOL combinedValue) {
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

@end
