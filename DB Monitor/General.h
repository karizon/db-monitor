//
//  General.h
//  DB Monitor
//
//  Created by Geoff Harrison on 5/31/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface General : NSManagedObject

@property (nonatomic, retain) NSNumber * trackEnabled;
@property (nonatomic, retain) NSNumber * trackTimer;

@end
