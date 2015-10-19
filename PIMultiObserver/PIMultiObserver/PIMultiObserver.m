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

- (void)observeAnd:(NSArray *)objectsAndKeyPaths block:(PIMONotificationBlock)block {
    [self addMultiObserver:objectsAndKeyPaths evaluator:@selector(evalAnd:) block:block];
}

- (void)observeAllYes:(NSArray *)objectsAndKeyPaths block:(PIMONotificationBlock)block {
    [self addMultiObserver:objectsAndKeyPaths evaluator:@selector(evalAllYes:) block:block];
}

- (void)addMultiObserver:(NSArray *)objectsAndPaths evaluator:(SEL)evaluator block:(PIMONotificationBlock)block {
    // For every object/key path, append a new observation to self.observations
    NSDictionary *value = @{@"op": objectsAndPaths, @"b": block, @"e": NSStringFromSelector(evaluator)};
    for (NSInteger i = 0; i < objectsAndPaths.count; i += 2) {
        NSObject *object = objectsAndPaths[i];
        NSString *path = objectsAndPaths[i + 1];
        NSDictionary *key = @{@"o": object, @"p": path};
        NSMutableArray *currentValues = self.observations[key];
        if (!currentValues) {
            [object addObserver:self forKeyPath:path options:0 context:PIMOContext];
            self.observations[key] = [NSMutableArray arrayWithObject:value];
        } else {
            [currentValues addObject:value];
        }
    }
    
    // Perform initial evaluation
    [self invokeEvaluator:evaluator forObservation:value];
}

- (void)invokeEvaluator:(SEL)evaluator forObservation:(NSDictionary *)observation {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:evaluator]];
    invocation.target = self;
    invocation.selector = evaluator;
    [invocation setArgument:&observation atIndex:2];
    [invocation invoke];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context != PIMOContext) {
        return;
    }
    NSDictionary *key = @{@"o": object, @"p": keyPath};
    for (NSDictionary *observation in self.observations[key]) {
        SEL evaluator = NSSelectorFromString(observation[@"e"]);
        [self invokeEvaluator:evaluator forObservation:observation];
    }
}

- (void)evalAnd:(NSDictionary *)observation {
    NSArray *objectsAndPaths = observation[@"op"];
    BOOL combinedResult = YES;
    for (NSInteger i = 0; i < objectsAndPaths.count; i += 2) {
        NSObject *object = objectsAndPaths[i];
        NSString *keyPath = objectsAndPaths[i + 1];
        BOOL result = [[object valueForKeyPath:keyPath] boolValue];
        combinedResult &= result;
    }
    PIMONotificationBlock block = observation[@"b"];
    dispatch_async(dispatch_get_main_queue(), ^{
        block(combinedResult);
    });
}

- (void)evalAllYes:(NSDictionary *)observation {
    NSArray *objectsAndPaths = observation[@"op"];
    BOOL combinedResult = YES;
    for (NSInteger i = 0; i < objectsAndPaths.count; i += 2) {
        NSObject *object = objectsAndPaths[i];
        NSString *keyPath = objectsAndPaths[i + 1];
        BOOL result = [[object valueForKeyPath:keyPath] boolValue];
        combinedResult &= result;
    }
    if (combinedResult) {
        PIMONotificationBlock block = observation[@"b"];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(combinedResult);
        });
    }
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
