//
//  DBMLogEntry.h
//  DB Monitor
//
//  Created by mandrake on 4/27/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MySQLHost;
@class MysqlSlaveStatus;

@interface DBMLogEntry : NSObject {
    NSDictionary *query;
    MysqlSlaveStatus *slaveStatus;
}

@property (nonatomic) MySQLHost * eventHost;
@property (nonatomic) NSString * eventString;
@property (nonatomic) NSDate *eventTime;
@property (nonatomic) NSString *processID;
@property (nonatomic) BOOL updated;
@property (nonatomic) BOOL dead;
@property (nonatomic) int duration;
@property (nonatomic) NSDate *displayTimeout;
@property (nonatomic) BOOL activeInfo;


- (id) initWithHost:(MySQLHost *)host;
- (id) initWithHost:(MySQLHost *)host processID:(NSString *)pid;

- (NSString *) getQueryValue:(NSString *) key;
- (NSData *) getQueryData:(NSString *) key;

- (void) setQuery:(NSDictionary *) newQuery;
- (void) setSlaveStatus:(MysqlSlaveStatus *) newStatus;
- (MysqlSlaveStatus *) slaveStatus;

@end
