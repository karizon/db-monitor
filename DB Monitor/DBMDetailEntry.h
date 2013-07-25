//
//  DBMDetailEntry.h
//  DB Monitor
//
//  Created by mandrake on 5/25/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MySQLHost;
@class MysqlSlaveStatus;

@interface DBMDetailEntry : NSObject

@property (nonatomic) MySQLHost *host;
@property (nonatomic) unsigned long connections;
@property (nonatomic) unsigned long activeQueries;
@property (nonatomic) NSUInteger lastReads;
@property (nonatomic) NSUInteger currentReads;
@property (nonatomic) double readsPerSecond;
@property (nonatomic) NSUInteger lastWrites;
@property (nonatomic) NSUInteger currentWrites;
@property (nonatomic) double writesPerSecond;
@property (nonatomic) unsigned long freePages;
@property (nonatomic) unsigned long totalPages;
@property (nonatomic) unsigned long slowQueries;
@property (nonatomic) NSDate *lastQueryTime;
@property (nonatomic) NSDate *currentQueryTime;
@property (nonatomic) NSUInteger pollsLeftBeforeStatus;
@property (nonatomic) MysqlSlaveStatus *slaveStatus;


- (double) timeSinceLastUpdate;
@end
