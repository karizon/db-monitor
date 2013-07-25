//
//  MysqlStatus.h
//  DB Monitor
//
//  Created by Geoff Harrison on 5/28/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MysqlConnection;

@interface MysqlStatus : NSObject

@property(weak) MysqlConnection *connection;

@property(readonly) NSUInteger threadsConnected;
@property(readonly) NSUInteger innodbDataReads;
@property(readonly) NSUInteger innodbDataWrites;
@property(readonly) NSUInteger innodbPagesTotal;
@property(readonly) NSUInteger innodbPagesFree;
@property(readonly) NSUInteger slowQueries;

+ (MysqlStatus *)statusForConnection:(MysqlConnection *)connection;

@end
