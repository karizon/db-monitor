//
//  MySQLHost.h
//  DB Monitor
//
//  Created by mandrake on 5/9/13.
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
