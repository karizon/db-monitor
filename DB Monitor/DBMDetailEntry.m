//
//  DBMDetailEntry.m
//  DB Monitor
//
//  Created by mandrake on 5/25/13.
//    Copyright 2014 Geoff Harrison
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
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
