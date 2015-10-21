//
//  ViewController.m
//  Checklist
//
//  Created by Akos Polster on 18/10/15.
//  Copyright © 2015 Akos Polster. All rights reserved.
//

#import "ViewController.h"
#import <PIMultiObserver/PIMultiObserver.h>

@interface ViewController ()
@property PIMultiObserver *multiObserver;
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

    self.multiObserver = [[PIMultiObserver alloc] init];
    
    // Enable the "Launch" button if all subsystems are go, disable otherwise
    [self.multiObserver observeAnd:@[
        [PIObserver observerOf:self keyPath:@"booster"],
        [PIObserver observerOf:self keyPath:@"retro"],
        [PIObserver observerOf:self keyPath:@"fido"],
        [PIObserver observerOf:self keyPath:@"guidance"],
        [PIObserver observerOf:self keyPath:@"surgeon"]] block:^(BOOL combinedValue) {
            self.launchButton.hidden = !combinedValue;
        }];
    
    // Log every "all systems go" events
    [self.multiObserver observeAllYes:@[
        [PIObserver observerOf:self keyPath:@"booster"],
        [PIObserver observerOf:self keyPath:@"retro"],
        [PIObserver observerOf:self keyPath:@"fido"],
        [PIObserver observerOf:self keyPath:@"guidance"],
        [PIObserver observerOf:self keyPath:@"surgeon"]] block:^(BOOL combinedValue) {
            NSLog(@"All systems go!");
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
