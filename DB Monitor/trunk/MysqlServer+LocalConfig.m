//
//  MysqlServer+LocalConfig.m
//  mysql_connector
//
//  Created by Karl Kraft on 8/20/13.
//  Copyright 2013 Karl Kraft. All rights reserved.
//

#import "MysqlServer+LocalConfig.h"
#import "IniFile.h"

@implementation MysqlServer (LocalConfig)

+ (MysqlServer *)serverNamed:(NSString *)name
{
  MysqlServer *server = [[MysqlServer alloc] init];
  IniFile *f = [IniFile fileWithPath:[NSString stringWithFormat:@"%@/.mysql_servers",NSHomeDirectory()]];

  NSString *s =[f valueForKey:@"server" inSection:name];
  if (s) server.host=s;

  s=[f valueForKey:@"schema" inSection:name];
  if (s) server.schema=s;

  s=[f valueForKey:@"username" inSection:name];
  if (s) server.user=s;

  s=[f valueForKey:@"password" inSection:name];
  if (s) server.password=s;

  return server;
}

@end
