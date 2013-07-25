//
//  MysqlSlaveStatus.h
//  mysql_connector
//
//  Created by Karl Kraft on 5/5/13.
//  Copyright 2013 Karl Kraft. All rights reserved.
//

@class MysqlConnection;

@interface MysqlSlaveStatus : NSObject

+ (MysqlSlaveStatus *)statusForConnection:(MysqlConnection *)connection;

@property(weak) MysqlConnection *connection;

@property(readonly) NSString *ioState;

// Master
@property(readonly) NSUInteger masterServerId;
@property(readonly) NSString *masterHost;
@property(readonly) NSString *masterUser;
@property(readonly) unsigned short masterPort;
@property(readonly) NSUInteger connectRetry;
@property(readonly) NSString *masterLogFile;
@property(readonly) NSUInteger masterLogPosition;
@property(readonly) NSString *relayLogFile;
@property(readonly) NSUInteger relayLogPosition;

// threads
@property(readonly) NSString *slaveIOState;
@property(readonly) BOOL slaveIORunning;
@property(readonly) BOOL slaveSQLRunning;
@property(readonly) NSString *slaveSQLError;
@property(readonly) NSString *slaveIOError;

// lag
@property(readonly) NSUInteger masterLogExecPosition;
@property(readonly) NSInteger secondsBehindMaster;

@end
