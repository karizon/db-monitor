//
//  DBMDetailEntry.h
//  DB Monitor
//
//  Created by mandrake on 5/25/13.
//    Copyright 2014 Geoff Harrison
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//

#import <Foundation/Foundation.h>
@class MySQLHost;
@class MysqlSlaveStatus;

@interface DBMDetailEntry : NSObject

@property (nonatomic) MySQLHost *host;
@property (nonatomic) unsigned long connections;
@property (nonatomic) unsigned long activeQueries;
@property (nonatomic) NSUInteger lastReads;
@property (nonatomic) NSUInteger currentReads;
@property (nonatomic) double readsPerSecond;
@property (nonatomic) NSUInteger lastWrites;
@property (nonatomic) NSUInteger currentWrites;
@property (nonatomic) double writesPerSecond;
@property (nonatomic) unsigned long freePages;
@property (nonatomic) unsigned long totalPages;
@property (nonatomic) unsigned long slowQueries;
@property (nonatomic) NSDate *lastQueryTime;
@property (nonatomic) NSDate *currentQueryTime;
@property (nonatomic) NSUInteger pollsLeftBeforeStatus;
@property (nonatomic) MysqlSlaveStatus *slaveStatus;


- (double) timeSinceLastUpdate;
@end
