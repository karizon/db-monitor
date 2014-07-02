//
//  MysqlException.h
//  mysql_connector
//
//  Created by Karl Kraft on 6/19/09.
//  Copyright 2009-2013 Karl Kraft. All rights reserved.
//


@class MysqlConnection;

@interface MysqlException : NSException {

}

@property (assign) unsigned int errorNumber;

+ (void)raiseConnection:(MysqlConnection *)aConnection
             withFormat:(NSString *)format,...  __attribute__ ((noreturn));

@end

#ifdef MYSQL_LOGGING
#define MysqlLog(...) _reportDebug([ETErrorSpot spotWithFile:__FILE__ line:__LINE__],__PRETTY_FUNCTION__,__VA_ARGS__);
#else
#define MysqlLog(...)
#endif
