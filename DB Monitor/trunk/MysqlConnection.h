//
//  MysqlConnection.h
//  mysql_connector
//
//  Created by Karl Kraft on 5/21/08.
//  Copyright 2008-2013 Karl Kraft. All rights reserved.
//


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpadded"

#import "mysql.h"
#pragma clang diagnostic pop


@class MysqlServer;

@interface MysqlConnection : NSObject {
  BOOL transactionsEnabled;
  MysqlServer *server;
}

@property(readonly) MYSQL *connection;
@property(readonly) BOOL transactionsEnabled;
@property(readonly)MysqlServer *server;

+ (MysqlConnection *)connectToServers:(NSArray *)arrayOfServers;
+ (MysqlConnection *)connectToServer:(MysqlServer *)server;

- (void)enableTransactions;
- (void)disableTransactions;
- (void)commitTransaction;
- (void)rollbackTransaction;

- (void)enableStrictSql;

- (void)enableTriggers;
- (void)disableTriggers;

- (void)startIdle;

- (void)forceDisconnect;


@end





