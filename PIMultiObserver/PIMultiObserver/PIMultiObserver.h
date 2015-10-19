//
//  PIMultiObserver.h
//  PIMultiObserver
//
//  Created by Akos Polster on 19/10/15.
//  Copyright © 2015 Akos Polster. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Block to execute when the observation criteria met
///
/// @param combinedValue Combined Boolean value of the observed properties
typedef void (^PIMONotificationBlock)(BOOL combinedValue);

/// Controller to observe a series of objects and key paths
@interface PIMultiObserver : NSObject

/// Observe the combined AND value of a series of objects and paths
///
/// @param objectsAndPath List of objects and key paths, where even items are NSObjects, odd items are key path NSStrings
/// @param block Notification block to be called with the combined AND value of the observed properties, whenever any property changes
- (void)observeAnd:(NSArray *)objectsAndPaths block:(PIMONotificationBlock)block;

@end
