//
//  MysqlServer+LocalConfig.h
//  mysql_connector
//
//  Created by Karl Kraft on 8/20/13.
//  Copyright 2013 Karl Kraft. All rights reserved.
//

#import "MysqlServer.h"

@interface MysqlServer (LocalConfig)
+ (MysqlServer *)serverNamed:(NSString *)name;

@end
