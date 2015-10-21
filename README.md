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
    

### Observing The AND Combination Of Properties

The method *observeAnd* takes a list of properties (objects and key paths) to observe, and a notification block. The block will be called whenever any of the properties change, with a Boolean parameter which is the AND combination of the current values of the observed properties:

    - (void)observeAnd:(NSArray *)objectsAndKeyPaths block:(PIMONotificationBlock)block;

The example app *Checklist* is using this method to observe a set of rocket launch systems (think Apollo 13), in order to enable a "launch" button, when all subsystems are ready, but disable the button otherwise:

    [self.multiObserver observeAnd:@[
        [PIObserver observerOf:self keyPath:@"booster"],
        [PIObserver observerOf:self keyPath@"retro"],
        [PIObserver observerOf:self keyPath@"fido"],
        [PIObserver observerOf:self keyPath@"guidance"],
        [PIObserver observerOf:self keyPath@"surgeon"]] 
        block:^(BOOL allSystemsGo) {
            self.launchButton.hidden = !allSystemsGo;
        }];


### Observing All Properties To Become YES

The method *observeAllYes* takes a list of properties to observe and a notification block. The block is *only* called whenever all observed properties change to YES:

    - (void)observerAllYes:(NSArray *)objectsAndKeyPaths block:(PIMONotificationBlock)block;
    
The example app *Checklist* is using this method to log an "All systems go!" message whenever all rocket launch systems become ready:

    [self.multiObserver observeAllYes:@[
        [PIObserver observerOf:self keyPath:@"booster"],
        [PIObserver observerOf:self keyPath@"retro"],
        [PIObserver observerOf:self keyPath@"fido"],
        [PIObserver observerOf:self keyPath@"guidance"],
        [PIObserver observerOf:self keyPath@"surgeon"]] 
        block:^(BOOL combinedValue) {
            NSLog(@"All systems go!");
        }];
        
        
### Mapping Properties To Booleans

Individual observations (created with *PIObserver*) can map their property values to Booleans using an optional mapper block. 

The example app *Checklist* is mapping its temperature property to YES/NO depending if the temperature is within the range allowed for launch:

    [self.multiObserver observeAnd:@[
        // ...
        [PIObserver observerOf:self keyPath:@"temp" mapper:^BOOL(NSNumber *t) {
            return t.floatValue >= MinLaunchTemp && t.floatValue <= MaxLaunchTemp;
        }]]
        block:^(BOOL combinedValue) {
            self.launchButton.hidden = !combinedValue;
        }];


## Implementation Details

* Multi-observations are implemented using Cocoa key-value observations

* After setting up a multi-observation, the notification block is called immediately, if the evaluation criteria is met

* Upon *dealloc* the controller removes all observations

* Notification blocks are always called on the main thread

* Mapper blocks are called on the same thread as the Cocoa KVO


## Installation

TBD


## License

PIMultiObserver is released under the MIT License. See LICENSE file for more details.
