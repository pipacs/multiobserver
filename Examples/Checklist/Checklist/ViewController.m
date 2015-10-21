//
//  ViewController.m
//  Checklist
//
//  Created by Akos Polster on 18/10/15.
//  Copyright © 2015 Akos Polster. All rights reserved.
//

#import "ViewController.h"
#import <PIMultiObserver/PIMultiObserver.h>

static const float MinLaunchTemperature = 35;
static const float MaxLaunchTemperature = 99;

@interface ViewController ()
@property PIMultiObserver *multiObserver;
@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UISwitch *boosterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *retroSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fidoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *guidanceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *surgeonSwitch;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UISlider *tempSlider;
@property BOOL booster;
@property BOOL retro;
@property BOOL fido;
@property BOOL guidance;
@property BOOL surgeon;
@property float temp;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self handleControl:self.tempSlider];
    [self.boosterSwitch  addTarget:self action:@selector(handleControl:) forControlEvents:UIControlEventValueChanged];
    [self.retroSwitch    addTarget:self action:@selector(handleControl:) forControlEvents:UIControlEventValueChanged];
    [self.fidoSwitch     addTarget:self action:@selector(handleControl:) forControlEvents:UIControlEventValueChanged];
    [self.guidanceSwitch addTarget:self action:@selector(handleControl:) forControlEvents:UIControlEventValueChanged];
    [self.surgeonSwitch  addTarget:self action:@selector(handleControl:) forControlEvents:UIControlEventValueChanged];
    [self.tempSlider     addTarget:self action:@selector(handleControl:) forControlEvents:UIControlEventValueChanged];
    self.multiObserver = [[PIMultiObserver alloc] init];
    
    // Enable the "Launch" button if all systems are go, and temperature is not too cold. Disable otherwise
    [self.multiObserver observeAnd:@[
        [PIObserver observerOf:self keyPath:@"booster"],
        [PIObserver observerOf:self keyPath:@"retro"],
        [PIObserver observerOf:self keyPath:@"fido"],
        [PIObserver observerOf:self keyPath:@"guidance"],
        [PIObserver observerOf:self keyPath:@"surgeon"],
        [PIObserver observerOf:self keyPath:@"temp" mapper:^BOOL(NSNumber *t) {
            return t.floatValue >= MinLaunchTemperature && t.floatValue <= MaxLaunchTemperature;
        }]]
        block:^(BOOL combinedValue) {
            self.launchButton.hidden = !combinedValue;
        }];
    
    // Log every "all systems go" events
    [self.multiObserver observeAllYes:@[
        [PIObserver observerOf:self keyPath:@"booster"],
        [PIObserver observerOf:self keyPath:@"retro"],
        [PIObserver observerOf:self keyPath:@"fido"],
        [PIObserver observerOf:self keyPath:@"guidance"],
        [PIObserver observerOf:self keyPath:@"surgeon"]]
        block:^(BOOL combinedValue) {
            NSLog(@"All systems go!");
        }];
    
    // Log whenever neither BOOSTER nor GUIDANCE are ready
    [self.multiObserver observeAllYes:@[
        [PIObserver observerOf:self keyPath:@"booster" mapper:^BOOL(id value) {return ![value boolValue];}],
        [PIObserver observerOf:self keyPath:@"guidance" mapper:^BOOL(id value) {return ![value boolValue];}]]
        block:^(BOOL combinedValue) {
            NSLog(@"Neither BOOSTER nor GUIDANCE are ready");
        }];
}

- (void)handleControl:(id)sender {
    if      ([sender isEqual:self.boosterSwitch])  self.booster  = self.boosterSwitch.isOn;
    else if ([sender isEqual:self.retroSwitch])    self.retro    = self.retroSwitch.isOn;
    else if ([sender isEqual:self.fidoSwitch])     self.fido     = self.fidoSwitch.isOn;
    else if ([sender isEqual:self.guidanceSwitch]) self.guidance = self.guidanceSwitch.isOn;
    else if ([sender isEqual:self.surgeonSwitch])  self.surgeon  = self.surgeonSwitch.isOn;
    else if ([sender isEqual:self.tempSlider]) {
        self.temp = self.tempSlider.value;
        self.tempLabel.text = [NSString stringWithFormat:@"TEMP %.1f", self.temp];
    }
}

@end
