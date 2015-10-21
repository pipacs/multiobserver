//
//  PIMultiObserver.m
//  PIMultiObserver
//
//  Created by Akos Polster on 19/10/15.
//  Copyright © 2015 Akos Polster. All rights reserved.
//

#import "PIMultiObserver.h"

static void * const Context = (void *)&Context; ///< Context of our Cocoa observers

// Keys to observation dictionaries
static NSString * const KeyObservers = @"ob";
static NSString * const KeyBlock = @"b";
static NSString * const KeyEvaluator = @"e";

// Keys to property dictionaries
static NSString * const KeyObject = @"o";
static NSString * const KeyKeyPath = @"p";

@interface PIMultiObserver ()
@property NSMutableDictionary *observations;
@end

@implementation PIMultiObserver

#pragma mark - Public API

- (instancetype)init {
    self = [super init];
    if (self) {
        self.observations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    /// Remove Cocoa observers
    for (NSDictionary *key in self.observations.allKeys) {
        NSObject *object = key[KeyObject];
        NSString *keyPath = key[KeyKeyPath];
        @try {
            [object removeObserver:self forKeyPath:keyPath context:Context];
        }
        @catch (NSException *exception) {
            NSLog(@"PIMultiObserver:dealloc: Internal error removing observer from %@, key path %@: %@", object, keyPath, exception);
        }
    }
}

- (void)observeAnd:(NSArray *)objectsAndKeyPaths block:(PIMONotificationBlock)block {
    [self addMultiObserver:objectsAndKeyPaths evaluator:@selector(evalAnd:) block:block];
}

- (void)observeAllYes:(NSArray *)objectsAndKeyPaths block:(PIMONotificationBlock)block {
    [self addMultiObserver:objectsAndKeyPaths evaluator:@selector(evalAllYes:) block:block];
}

#pragma mark - Internal

/// Set up an observation with the given properties, evaluator and notification block
- (void)addMultiObserver:(NSArray<PIObserver *> *)observers evaluator:(SEL)evaluator block:(PIMONotificationBlock)block {
    // Create an "observation", which is just a dictionary containing the method parameters
    NSDictionary *observation = @{KeyObservers: observers, KeyBlock: block, KeyEvaluator: NSStringFromSelector(evaluator)};

    // For every property in objectsAndKeyPaths, append the new observation to self.observations[property]
    for (PIObserver *observer in observers) {
        NSDictionary *property = @{KeyObject: observer.object, KeyKeyPath: observer.keyPath};
        NSMutableArray *currentObservations = self.observations[property];
        if (!currentObservations) {
            // First observation for the property: Register Cocoa observer
            [observer.object addObserver:self forKeyPath:observer.keyPath options:0 context:Context];
            self.observations[property] = [NSMutableArray arrayWithObject:observation];
        } else {
            [currentObservations addObject:observation];
        }
    }
    
    // Perform initial evaluation
    [self invokeEvaluator:evaluator forObservation:observation];
}

/// Invoke the evaluator with the observation as parameter
- (void)invokeEvaluator:(SEL)evaluator forObservation:(NSDictionary *)observation {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:evaluator]];
    invocation.target = self;
    invocation.selector = evaluator;
    [invocation setArgument:&observation atIndex:2];
    [invocation invoke];
}

/// KVO delegate callback
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context != Context) {
        return;
    }
    NSDictionary *key = @{KeyObject: object, KeyKeyPath: keyPath};
    for (NSDictionary *observation in self.observations[key]) {
        SEL evaluator = NSSelectorFromString(observation[KeyEvaluator]);
        [self invokeEvaluator:evaluator forObservation:observation];
    }
}

/// Call the notification block with the combined AND value of all properties in the observation
- (void)evalAnd:(NSDictionary *)observation {
    NSArray<PIObserver *> *observers = observation[KeyObservers];
    BOOL combinedResult = YES;
    for (PIObserver *observer in observers) {
        combinedResult &= [self evalObserver:observer];
    }
    PIMONotificationBlock block = observation[KeyBlock];
    dispatch_async(dispatch_get_main_queue(), ^{
        block(combinedResult);
    });
}

/// Take the combined AND value of all properties in the observation; if YES, call the notification block
- (void)evalAllYes:(NSDictionary *)observation {
    NSArray<PIObserver *> *observers = observation[KeyObservers];
    BOOL combinedResult = YES;
    for (PIObserver *observer in observers) {
        combinedResult &= [self evalObserver:observer];
        if (!combinedResult) {
            break;
        }
    }
    if (combinedResult) {
        PIMONotificationBlock block = observation[KeyBlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(combinedResult);
        });
    }
}

/// Evaluate an observed property into a Boolean
- (BOOL)evalObserver:(PIObserver *)observer {
    NSObject *object = observer.object;
    NSString *keyPath = observer.keyPath;
    id value = [object valueForKeyPath:keyPath];
    if (observer.mapper) {
        return observer.mapper(value);
    } else {
        return [value boolValue];
    }
}

@end
