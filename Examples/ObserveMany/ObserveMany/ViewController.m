//
//  ViewController.m
//  ObserveMany
//
//  Created by Akos Polster on 18/10/15.
//  Copyright © 2015 Akos Polster. All rights reserved.
//

#import "ViewController.h"

typedef void (^MONotificationBlock)(BOOL combinedValue);
static void * const MOContext = (void *)&MOContext;

@interface MultiObserver : NSObject
@property NSMutableDictionary *observations;
- (void)observeAnd:(NSArray *)objectsAndPaths block:(MONotificationBlock)block;
@end

@implementation MultiObserver

- (instancetype)init {
    self = [super init];
    if (self) {
        self.observations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)observeAnd:(NSArray *)objectsAndPaths block:(MONotificationBlock)block {
    for (NSInteger i = 0; i < objectsAndPaths.count; i += 2) {
        NSObject *object = objectsAndPaths[i];
        NSString *path = objectsAndPaths[i + 1];
        NSDictionary *key = @{@"o": object, @"p": path};
        NSDictionary *value = @{@"op": objectsAndPaths, @"b": block};
        NSMutableArray *currentValues = self.observations[key];
        if (!currentValues) {
            NSLog(@"First observer for %@ %@", object, path);
            [object addObserver:self forKeyPath:path options:0 context:MOContext];
            self.observations[key] = [NSMutableArray arrayWithObject:value];
        } else {
            [currentValues addObject:value];
        }
        [self evalObserveAnd:value]; // Initial evaluation
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context != MOContext) {
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
    MONotificationBlock block = observation[@"b"];
    dispatch_async(dispatch_get_main_queue(), ^{
        block(combinedResult);
    });
}

- (void)dealloc {
    for (NSDictionary *key in self.observations.allKeys) {
        NSObject *object = key[@"o"];
        NSString *keyPath = key[@"p"];
        @try {
            [object removeObserver:self forKeyPath:keyPath context:MOContext];
        }
        @catch (NSException *exception) {
            NSLog(@"Internal error removing observer from %@, key path %@: %@", object, keyPath, exception);
        }
    }
}

@end

@interface ViewController ()
@property MultiObserver *multiObserver;
@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UISwitch *boosterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *retroSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fidoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *guidanceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *surgeonSwitch;
@property BOOL booster;
@property BOOL retro;
@property BOOL fido;
@property BOOL guidance;
@property BOOL surgeon;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.boosterSwitch  addTarget:self action:@selector(handleSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.retroSwitch    addTarget:self action:@selector(handleSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.fidoSwitch     addTarget:self action:@selector(handleSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.guidanceSwitch addTarget:self action:@selector(handleSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.surgeonSwitch  addTarget:self action:@selector(handleSwitch:) forControlEvents:UIControlEventValueChanged];

    self.multiObserver = [[MultiObserver alloc] init];
    [self.multiObserver observeAnd:@[
        self, @"booster",
        self, @"retro",
        self, @"fido",
        self, @"guidance",
        self, @"surgeon"] block:^(BOOL combinedValue) {
            NSLog(@"MONotificationBlock: %@", combinedValue? @"yes": @"no");
            self.launchButton.hidden = !combinedValue;
        }];
}

- (void)handleSwitch:(id)sender {
    if      ([sender isEqual:self.boosterSwitch])  self.booster  = self.boosterSwitch.isOn;
    else if ([sender isEqual:self.retroSwitch])    self.retro    = self.retroSwitch.isOn;
    else if ([sender isEqual:self.fidoSwitch])     self.fido     = self.fidoSwitch.isOn;
    else if ([sender isEqual:self.guidanceSwitch]) self.guidance = self.guidanceSwitch.isOn;
    else if ([sender isEqual:self.surgeonSwitch])  self.surgeon  = self.surgeonSwitch.isOn;
}

@end
