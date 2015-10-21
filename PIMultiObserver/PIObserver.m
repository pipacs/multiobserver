//
//  PIObserver.m
//  PIMultiObserver
//
//  Created by Akos Polster on 21/10/15.
//  Copyright © 2015 Akos Polster. All rights reserved.
//

#import "PIObserver.h"

@interface PIObserver ()
@property (readwrite) NSObject *object;
@property (readwrite) NSString *keyPath;
@property (readwrite) PIOMapper mapper;
@end

@implementation PIObserver

+ (PIObserver *)observerOf:(NSObject *)object keyPath:(NSString *)keyPath {
    return [PIObserver observerOf:object keyPath:keyPath mapper:nil];
}

+ (PIObserver *)observerOf:(NSObject *)object keyPath:(NSString *)keyPath mapper:(PIOMapper)mapper {
    return [[PIObserver alloc] initWithObject:object keyPath:keyPath mapper:mapper];
}

- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath mapper:(PIOMapper)mapper {
    self = [super init];
    if (self) {
        self.object = object;
        self.keyPath = keyPath;
        self.mapper = mapper;
    }
    return self;
}

@end
