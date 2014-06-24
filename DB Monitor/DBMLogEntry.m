//
//  DBMLogEntry.m
//  DB Monitor
//
//  Created by mandrake on 4/27/13.
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

#import "DBMLogEntry.h"

@implementation DBMLogEntry

@synthesize eventHost;
@synthesize eventString;
@synthesize eventTime;
@synthesize processID;
@synthesize updated;
@synthesize duration;
@synthesize dead;
@synthesize displayTimeout;
@synthesize activeInfo;


- (id) initWithHost:(MySQLHost *)host processID:(NSString *)pid {
    self = [super init];
    if (self) {
        eventHost = host;
        eventString = nil;
        eventTime = [NSDate date];
        processID = pid;
        query = nil;
        updated = NO;
        dead = NO;
        duration = 0;
        displayTimeout = nil;
        activeInfo = 0;
        slaveStatus = nil;
    }
    return self;
}

- (id) initWithHost:(MySQLHost *)host {
    return [self initWithHost:host processID:nil];
}

- (id)init {
    return [self initWithHost:nil processID:nil];
}

- (void) dealloc {
    eventHost = nil;
    eventString = nil;
    eventTime = nil;
    processID = nil;
    query = nil;
    updated = NO;
    dead = NO;
    duration = 0;
    displayTimeout = nil;
    activeInfo = 0;
    slaveStatus = nil;
}


- (NSString *) getQueryValue:(NSString *) key {
    return [NSString stringWithFormat:@"%@",[query objectForKey:key]];
}

- (NSData *) getQueryData:(NSString *) key {
    return [query objectForKey:key];
}


- (void) setQuery:(NSDictionary *)newQuery {
    query = newQuery;
}

- (void) setSlaveStatus:(MysqlSlaveStatus *)newStatus {
    slaveStatus = newStatus;
}

- (MysqlSlaveStatus *) slaveStatus {
    return slaveStatus;
}

@end
