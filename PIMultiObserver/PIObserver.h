//
//  PIObserver.h
//  PIMultiObserver
//
//  Created by Akos Polster on 21/10/15.
//  Copyright © 2015 Akos Polster. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Block that maps a property value into a Boolean
typedef BOOL (^PIOMapper)(id _Nullable value);

/// Observes a property and optionally transforms it to a Boolean
@interface PIObserver : NSObject

/// Create an observer with a given object and key path
+ (nullable PIObserver *)observerOf:(nonnull NSObject *)object keyPath:(nonnull NSString *)keyPath;

/// Create an observer with a given object, key path and mapper
+ (nullable PIObserver *)observerOf:(nonnull NSObject *)object keyPath:(nonnull NSString *)keyPath mapper:(nullable PIOMapper)mapper;

/// Initialize with a given object, key path and mapper
- (nullable instancetype)initWithObject:(nonnull NSObject *)object keyPath:(nonnull NSString *)keyPath mapper:(nullable PIOMapper)mapper NS_DESIGNATED_INITIALIZER;

/// Bare-bones initialization is not allowed
- (nullable instancetype)init NS_UNAVAILABLE;

@property (readonly, nonnull) NSObject *object; ///< Observed object
@property (readonly, nonnull) NSString *keyPath; ///< Observed property's key path
@property (readonly, nullable) PIOMapper mapper; ///< Property value mapper

@end
