//
//  MySQLHost.h
//  DB Monitor
//
//  Created by mandrake on 5/9/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pool;

@interface MySQLHost : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * alias;
@property (nonatomic, retain) NSString * hostname;
@property (nonatomic, retain) NSNumber * slave;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) Pool *pool;

@end
