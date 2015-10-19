# PIMultiObserver

Combine multiple observations to trigger a single action


## Overview

This Objective C frameworks allows combining multiple key-value observations, and calling a single notification callback with the result of the combined observations.


## Usage

Example apps are included with this project. Here are the main use cases:

### Creating A Multi Observer Controller

The controller is the object that manages multi-observations. To create:

    #import <PIMultiObserver/PIMultiObserver.h>
    
    ...
    
    PIMultiObserver *multiObserver = [[PIMultiObserver alloc] init];
    
Upon *dealloc*, the controller will remove all observations.


### observeAnd: Observing The AND Combination Of Many Properties

The method *observeAnd* takes a list of properties (objects and key paths) to observe, and a notification block. The block will be called whenever any of the properties change, with a Boolean parameter which is the AND combination of the current value of all observed properties:

    - (void)observeAnd:(NSArray *)objectsAndKeyPaths block:(PIMONotificationBlock)block;

The example app *Checklist* is using this method to observe a set of rocket launch subsystems (think Apollo 13), in order to enable a "launch" button, when all subsystems are ready, but disable the button otherwise:

    [self.multiObserver observeAnd:@[
        self, @"booster",
        self, @"retro",
        self, @"fido",
        self, @"guidance",
        self, @"surgeon"] block:^(BOOL allSystemsGo) {
            self.launchButton.hidden = !allSystemsGo;
        }];


### observeAllYes: Observing All Properties To Become YES

The method *observeAllYes* takes a list of properties to observe and a notification block. The block is *only* called whenever all observed properties change to YES:

    - (void)observerAllYes:(NSArray *)objectsAndKeyPaths block:(PIMONotificationBlock)block;
    
The example app *Checklist* is using this method to log an "All systems go!" message whenever all launch subsystems become ready:

    [self.multiObserver observeAllYes:@[
        self, @"booster",
        self, @"retro",
        self, @"fido",
        self, @"guidance",
        self, @"surgeon"] block:^(BOOL combinedValue) {
            NSLog(@"All systems go!");
        }];


## Implementation Details

* Multi-observations are implemented using Cocoa key-value observations

* Upon *dealloc* the controller will remove all observations

* Notification blocks are always called on the main thread


## Installation

TBD


## License

PIMultiObserver is released under the MIT License. See LICENSE file for more details.


