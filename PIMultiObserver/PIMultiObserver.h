//
//  PIMultiObserver.h
//  PIMultiObserver
//
//  Created by Akos Polster on 19/10/15.
//  Copyright © 2015 Akos Polster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PIObserver.h"

/// Block to execute when the observation criteria met
///
/// @param combinedValue Combined Boolean value of the observed properties
typedef void (^PIMONotificationBlock)(BOOL combinedValue);

/// Controller to observe a series of objects and key paths
@interface PIMultiObserver : NSObject

/// Observe the combined AND value of a series of observations
///
/// @param observers List of property observers
/// @param block Notification block to be called with the combined AND value of the observed properties, whenever any property changes
- (void)observeAnd:(nullable NSArray<PIObserver *> *)observers block:(nonnull PIMONotificationBlock)block;

/// Observe a series of observations, notify when they all evaluate to YES
///
/// @param observers List of property observers
/// @param block Notification block to be called when all observed properties evaluate to YES
- (void)observeAllYes:(nullable NSArray<PIObserver *> *)observers block:(nonnull PIMONotificationBlock)block;

@end
