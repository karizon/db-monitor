//
//  MysqlStatus.m
//  DB Monitor
//
//  Created by Geoff Harrison on 5/28/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
//

#import "MysqlStatus.h"
#import "MysqlConnection.h"
#import "MysqlException.h"

#import "mysql.h"

@implementation MysqlStatus

- (void)fetchStatus
{
    @synchronized(_connection) {
        if(mysql_query(_connection.connection, "show status where Variable_name='Innodb_data_reads' or Variable_name='Threads_connected' or Variable_name='Innodb_data_writes' or Variable_name='Innodb_buffer_pool_pages_total' or Variable_name='Innodb_buffer_pool_pages_free' or Variable_name='Slow_queries';")) {
            [MysqlException raiseConnection:_connection
                                 withFormat:@"Could not show status Error #%d:%s"
             ,mysql_errno(_connection.connection),
             mysql_error(_connection.connection)];
        }
        
        MYSQL_RES *result=mysql_store_result(_connection.connection);
        MYSQL_ROW row;
        while((row=mysql_fetch_row(result))) {
            // printf("Field %s - %s\n", row[0], row[1]);
            if(!strcmp(row[0],"Threads_connected")) {
                _threadsConnected=row[1] ? (NSUInteger)atoi(row[1]):0;
            } else if(!strcmp(row[0],"Innodb_data_reads")) {
                _innodbDataReads=row[1] ? (NSUInteger)atoi(row[1]):0;
            } else if(!strcmp(row[0],"Innodb_data_writes")) {
                _innodbDataWrites=row[1] ? (NSUInteger)atoi(row[1]):0;
            } else if(!strcmp(row[0],"Innodb_buffer_pool_pages_total")) {
                _innodbPagesTotal=row[1] ? (NSUInteger)atoi(row[1]):0;
            } else if(!strcmp(row[0],"Innodb_buffer_pool_pages_free")) {
                _innodbPagesFree=row[1] ? (NSUInteger)atoi(row[1]):0;
            } else if(!strcmp(row[0],"Slow_queries")) {
                _slowQueries=row[1] ? (NSUInteger)atoi(row[1]):0;
            }
        }
        mysql_free_result(result);
    }
    
}

+ (MysqlStatus *)statusForConnection:(MysqlConnection *)connection
{
    MysqlStatus *newObject = [[self alloc] init];
    newObject.connection=connection;
    [newObject fetchStatus];
    return newObject;
}
@end
