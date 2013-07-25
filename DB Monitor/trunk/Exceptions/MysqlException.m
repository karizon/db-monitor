//
//  MysqlException.m
//  mysql_connector
//
//  Created by Karl Kraft on 6/19/09.
//  Copyright 2009-2012 Karl Kraft. All rights reserved.
//

#import "MysqlException.h"
#import "MysqlConnection.h"


@implementation MysqlException
+ (void)raiseConnection:(MysqlConnection *)aConnection withFormat:(NSString *)format,...
{
  NSDictionary *userInfo = nil;
  if (aConnection) {
    userInfo=@{@"MysqlConnection": aConnection};
  }
  
  va_list arguments;
  va_start(arguments, format);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
  NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arguments];
#pragma clang diagnostic pop
  va_end(arguments);
  
  MysqlException *exception = [[self alloc] initWithName:NSStringFromClass([self class])
                                                  reason:formattedString
                                                userInfo:userInfo];
  [exception raise];
  exit(0);
}

@end
