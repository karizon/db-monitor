//
//  DBMDetailEntry.m
//  DB Monitor
//
//  Created by mandrake on 5/25/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
//

#import "DBMDetailEntry.h"

@implementation DBMDetailEntry

@synthesize host;
@synthesize connections;
@synthesize activeQueries;
@synthesize lastReads;
@synthesize lastWrites;
@synthesize currentReads;
@synthesize currentWrites;
@synthesize readsPerSecond;
@synthesize writesPerSecond;
@synthesize freePages;
@synthesize totalPages;
@synthesize slowQueries;
@synthesize lastQueryTime;
@synthesize currentQueryTime;
@synthesize pollsLeftBeforeStatus;
@synthesize slaveStatus;

- (id) init {
    self = [super init];
    if(self) {
        host = nil;
        connections = 0;
        activeQueries = 0;
        readsPerSecond = 0;
        writesPerSecond = 0;
        lastReads = 0;
        lastWrites = 0;
        currentWrites = 0;
        currentReads = 0;
        freePages = 0;
        totalPages = 0;
        slowQueries = 0;
        lastQueryTime = nil;
        currentQueryTime = nil;
        slaveStatus = nil;
        pollsLeftBeforeStatus = 0;
    }
    return self;
}

- (double) timeSinceLastUpdate {
    if(lastQueryTime && currentQueryTime) {
        return [currentQueryTime timeIntervalSinceDate:lastQueryTime];
    }
    return 0.25;
}
@end
