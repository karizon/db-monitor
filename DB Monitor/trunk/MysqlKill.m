//
//  MysqlKill.m
//  DB Monitor
//
//  Created by mandrake on 5/12/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
//

#import "MysqlKill.h"
#import "MysqlConnection.h"
#import "MysqlException.h"

#import "mysql.h"

@implementation MysqlKill



+ (void)killProcess:(MysqlConnection *)connection processID:(NSString *) processID {
    NSString *killString = [NSString stringWithFormat:@"kill %@", processID];
    @synchronized(connection) {
        if(mysql_query(connection.connection, [killString UTF8String])) {
            [MysqlException raiseConnection:connection
                                 withFormat:@"Could not show slave status Error #%d:%s"
             ,mysql_errno(connection.connection),
             mysql_error(connection.connection)];
        }
    }
}
@end
