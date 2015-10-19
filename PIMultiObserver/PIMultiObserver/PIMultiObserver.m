//
//  PIMultiObserver.m
//  PIMultiObserver
//
//  Created by Akos Polster on 19/10/15.
//  Copyright © 2015 Akos Polster. All rights reserved.
//

#import "PIMultiObserver.h"

static void * const PIMOContext = (void *)&PIMOContext;

@interface PIMultiObserver ()
@property NSMutableDictionary *observations;
@end

@implementation PIMultiObserver

- (instancetype)init {
    self = [super init];
    if (self) {
        self.observations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)observeAnd:(NSArray *)objectsAndPaths block:(PIMONotificationBlock)block {
    for (NSInteger i = 0; i < objectsAndPaths.count; i += 2) {
        NSObject *object = objectsAndPaths[i];
        NSString *path = objectsAndPaths[i + 1];
        NSDictionary *key = @{@"o": object, @"p": path};
        NSDictionary *value = @{@"op": objectsAndPaths, @"b": block};
        NSMutableArray *currentValues = self.observations[key];
        if (!currentValues) {
            NSLog(@"First observer for %@ %@", object, path);
            [object addObserver:self forKeyPath:path options:0 context:PIMOContext];
            self.observations[key] = [NSMutableArray arrayWithObject:value];
        } else {
            [currentValues addObject:value];
        }
        [self evalObserveAnd:value]; // Initial evaluation
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context != PIMOContext) {
        return;
    }
    NSLog(@"observeValueForKeyPath: %@ of object %@", keyPath, object);
    NSDictionary *key = @{@"o": object, @"p": keyPath};
    for (NSDictionary *observation in self.observations[key]) {
        [self evalObserveAnd:observation];
    }
}

- (void)evalObserveAnd:(NSDictionary *)observation {
    NSLog(@"evalObserveAnd: Evaluating observation %@", observation);
    NSArray *objectsAndPaths = observation[@"op"];
    BOOL combinedResult = YES;
    for (NSInteger i = 0; i < objectsAndPaths.count; i += 2) {
        NSObject *object = objectsAndPaths[i];
        NSString *keyPath = objectsAndPaths[i + 1];
        BOOL result = [[object valueForKeyPath:keyPath] boolValue];
        NSLog(@" %@ %@: %@", object, keyPath, result? @"yes": @"no");
        combinedResult &= result;
    }
    PIMONotificationBlock block = observation[@"b"];
    dispatch_async(dispatch_get_main_queue(), ^{
        block(combinedResult);
    });
}

- (void)dealloc {
    for (NSDictionary *key in self.observations.allKeys) {
        NSObject *object = key[@"o"];
        NSString *keyPath = key[@"p"];
        @try {
            [object removeObserver:self forKeyPath:keyPath context:PIMOContext];
        }
        @catch (NSException *exception) {
            NSLog(@"PIMultiObserver:dealloc: Internal error removing observer from %@, key path %@: %@", object, keyPath, exception);
        }
    }
}

@end
