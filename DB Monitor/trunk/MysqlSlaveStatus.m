//
//  MysqlSlaveStatus.m
//  mysql_connector
//
//  Created by Karl Kraft on 5/5/13.
//  Copyright 2013 Karl Kraft. All rights reserved.
//

#import "MysqlSlaveStatus.h"
#import "MysqlConnection.h"
#import "MysqlException.h"

#import "mysql.h"

@implementation MysqlSlaveStatus


// things that aren't properties yet.

//Field 9 is Relay_Master_Log_File
//Field 12 is Replicate_Do_DB
//Field 13 is Replicate_Ignore_DB
//Field 14 is Replicate_Do_Table
//Field 15 is Replicate_Ignore_Table
//Field 16 is Replicate_Wild_Do_Table
//Field 17 is Replicate_Wild_Ignore_Table
//Field 18 is Last_Errno
//Field 19 is Last_Error
//Field 20 is Skip_Counter
//Field 21 is Exec_Master_Log_Pos
//Field 22 is Relay_Log_Space
//Field 23 is Until_Condition
//Field 24 is Until_Log_File
//Field 25 is Until_Log_Pos
//Field 26 is Master_SSL_Allowed
//Field 27 is Master_SSL_CA_File
//Field 28 is Master_SSL_CA_Path
//Field 29 is Master_SSL_Cert
//Field 30 is Master_SSL_Cipher
//Field 31 is Master_SSL_Key
//Field 33 is Master_SSL_Verify_Server_Cert
//Field 34 is Last_IO_Errno
//Field 35 is Last_IO_Error
//Field 36 is Last_SQL_Errno
//Field 37 is Last_SQL_Error
//Field 38 is Replicate_Ignore_Server_Ids

- (id) init {
    self = [super init];
    if(self) {
        _masterServerId = 0;
        _masterHost = nil;
        _masterUser = nil;
        _masterPort = 0;
        _masterLogFile = nil;
        _masterLogPosition = 0;
        _relayLogFile = nil;
        _relayLogPosition = 0;
        _connectRetry = 0;
        _slaveIOState = nil;
        _slaveIORunning = NO;
        _slaveSQLRunning = NO;
        _slaveSQLError = nil;
        _masterLogPosition = 0;
        _secondsBehindMaster=-1;
    }
    
    return self;
}

- (void)fetchStatus {
    @synchronized(_connection) {
        if(mysql_query(_connection.connection, "show slave status")) {
            [MysqlException raiseConnection:_connection
                                 withFormat:@"Could not show slave status Error #%d:%s"
             ,mysql_errno(_connection.connection),
             mysql_error(_connection.connection)];
        }
        
        MYSQL_RES *result=mysql_store_result(_connection.connection);
        if(result) {
            unsigned int num_fields = mysql_num_fields(result);
            MYSQL_FIELD *fields= mysql_fetch_fields(result);
            MYSQL_ROW row=mysql_fetch_row(result);
            if(row) {
                for(unsigned int i = 0; i < num_fields; i++)   {
                    const char *fieldName=fields[i].name;
                    // printf("Field %u is %s %s\n", i, fieldName,row[i]);
                    if (!strcmp(fieldName,"Master_Server_Id")) {
                        _masterServerId=row[i] ? (NSUInteger)atoi(row[i]):0;
                    } else if (!strcmp(fieldName,"Master_Host")) {
                        _masterHost = [NSString stringWithFormat:@"%s",row[i]];
                    } else if (!strcmp(fieldName,"Master_User")) {
                        _masterUser = [NSString stringWithFormat:@"%s",row[i]];
                    } else if (!strcmp(fieldName,"Master_Port")) {
                        _masterPort=(unsigned short) (row[i] ? atoi(row[i]):0);
                    } else if (!strcmp(fieldName,"Connect_Retry")) {
                        _connectRetry=row[i] ? (NSUInteger)atoi(row[i]):0;
                    } else if (!strcmp(fieldName,"Master_Log_File")) {
                        _masterLogFile= [NSString stringWithFormat:@"%s",row[i]];
                    } else if (!strcmp(fieldName,"Read_Master_Log_Pos")) {
                        _masterLogPosition=row[i] ? (NSUInteger)atoi(row[i]):0;
                    } else if (!strcmp(fieldName,"Relay_Log_File")) {
                        _relayLogFile= [NSString stringWithFormat:@"%s",row[i]];
                    } else if (!strcmp(fieldName,"Relay_Log_Pos")) {
                        _relayLogPosition=row[i] ? (NSUInteger)atoi(row[i]):0;
                    } else if (!strcmp(fieldName,"Slave_IO_State")) {
                        _slaveIOState= [NSString stringWithFormat:@"%s",row[i]];
                    } else if (!strcmp(fieldName,"Slave_IO_Running")) {
                        _slaveIORunning=NO;
                        if (row[i] && !strcmp(row[i], "Yes")) {
                            _slaveIORunning=YES;
                        };
                    } else if (!strcmp(fieldName,"Slave_SQL_Running")) {
                        _slaveSQLRunning=NO;
                        if (row[i] && !strcmp(row[i], "Yes")) {
                            _slaveSQLRunning=YES;
                        };
                    } else if (!strcmp(fieldName,"Exec_Master_Log_Pos")) {
                        _masterLogExecPosition=row[i] ? (NSUInteger)atoi(row[i]):0;
                    } else if (!strcmp(fieldName,"Seconds_Behind_Master")) {
                        _secondsBehindMaster=row[i] ? atoi(row[i]):-1;
                    } else if (!strcmp(fieldName,"Last_SQL_Error")) {
                        _slaveSQLError = [NSString stringWithFormat:@"%s",row[i]];
                    } else if (!strcmp(fieldName,"Last_IO_Error")) {
                        _slaveIOError = [NSString stringWithFormat:@"%s",row[i]];
                    }
                }
                mysql_free_result(result);
            }
        }
    }

}

+ (MysqlSlaveStatus *)statusForConnection:(MysqlConnection *)connection {
    MysqlSlaveStatus *newObject = [[self alloc] init];
    newObject.connection=connection;
    [newObject fetchStatus];
    return newObject;
}

@end
