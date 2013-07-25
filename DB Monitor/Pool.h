//
//  Pool.h
//  DB Monitor
//
//  Created by mandrake on 5/9/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MySQLHost;

@interface Pool : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * monitorTimer;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * triggerTimer;
@property (nonatomic, retain) NSString * hostType;
@property (nonatomic, retain) NSSet *mysqlhosts;
@end

@interface Pool (CoreDataGeneratedAccessors)

- (void)addMysqlhostsObject:(MySQLHost *)value;
- (void)removeMysqlhostsObject:(MySQLHost *)value;
- (void)addMysqlhosts:(NSSet *)values;
- (void)removeMysqlhosts:(NSSet *)values;

@end
