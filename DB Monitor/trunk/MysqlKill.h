//
//  MysqlKill.h
//  DB Monitor
//
//  Created by mandrake on 5/12/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysqlConnection.h"

@interface MysqlKill : NSObject


+ (void)killProcess:(MysqlConnection *)connection processID:(NSString *) processID;
@end
