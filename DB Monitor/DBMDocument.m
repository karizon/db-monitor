//
//  DBMDocument.m
//  DB Monitor
//
//  Created by mandrake on 4/8/13.
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

#import "DBMDocument.h"
#import "General.h"
#import "Pool.h"
#import "MySQLHost.h"
#import "MysqlConnection.h"
#import "MysqlException.h"
#import "MysqlServer.h"
#import "MysqlFetch.h"
#import "MysqlInsert.h"
#import "MysqlStatus.h"
#import "MysqlSlaveStatus.h"
#import "MysqlKill.h"
#import "DBMLogEntry.h"
#import "DBMDetailEntry.h"

@implementation DBMDocument

- (id)init {
    self = [super init];
    if (self) {
        @synchronized(checkQueue) {
            checkQueue = [[NSOperationQueue alloc] init];
        }
        @synchronized(dataList) {
            dataList = [[NSMutableArray alloc] init];
            logSortDescriptors = nil;
        }
        @synchronized(detailList) {
            detailList = [[NSMutableArray alloc] init];
            statusSortDescriptors = nil;
        }
    }
    return self;
}

- (NSString *)windowNibName {
    return @"DBMDocument";
}

- (void) detectChangedSlider:(NSSlider *) slider {
    
    sliderValue = [[NSNumber numberWithFloat:[trackTimer floatValue]] intValue];
    NSString *sliderVal = [NSString stringWithFormat:@"%d Seconds", sliderValue];
    if(sliderValue == 300) {
        sliderVal = @"∞ Seconds";
        sliderValue = -1;
    }
    [secondsDisplay setStringValue:sliderVal];
}

- (void) changeMainDisplay:(NSView *)view {
    if([mainDisplay contentView] != view) {
        [mainDisplay setContentView:view];
    }
}

- (void) detectChangedView:(NSPopUpButton *) button {
    if([button indexOfSelectedItem] == 1) {
        [self changeMainDisplay:detailDisplay];
    } else {
        [self changeMainDisplay:logDisplay];
    }
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    
    [mainDisplay setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self changeMainDisplay:logDisplay];
    [viewSelector setAction:@selector(detectChangedView:)];
    
    // Now that the window is opened, set up watchers
    [self reloadDataWatchers];
    
    // And log display starts with no selection
    [details setContentView:noView];
    [details setTranslatesAutoresizingMaskIntoConstraints:NO];
    [statusDetails setTranslatesAutoresizingMaskIntoConstraints:NO];
    [killButton setEnabled:NO];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"General"];
    NSError *error = nil;
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSArray *fetchedArray = [moc executeFetchRequest:request error:&error];
    if(fetchedArray == nil) {
        NSLog(@"Error while fetching!\n%@",([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        exit(1);
    }
    General *conf = nil;
    for (General *confRow in fetchedArray) {
        conf = confRow;
    }
    if(!conf) {
        conf = [NSEntityDescription
                insertNewObjectForEntityForName:@"General"
                inManagedObjectContext:moc];
        [conf setTrackEnabled:[NSNumber numberWithInt:1]];
        [conf setTrackTimer:[NSNumber numberWithFloat:60.0]];
    }
    
    // set the default timer attach our monitor to the slider
    [trackTimer setAction:@selector(detectChangedSlider:)];
    [trackTimer setFloatValue:[[conf trackTimer] floatValue]];
    sliderValue = [[NSNumber numberWithFloat:[trackTimer floatValue]] intValue];
    NSString *sliderVal = [NSString stringWithFormat:@"%d Seconds", sliderValue];
    if(sliderValue == 300) {
        sliderVal = @"∞ Seconds";
        sliderValue = -1;
    }
    [secondsDisplay setStringValue:sliderVal];

}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (MysqlConnection *) connectToHost: (MySQLHost *)aHost {
    MysqlConnection *connection = nil;
    @try {
        MysqlServer *server = [[MysqlServer alloc] init];
        [server setHost:[aHost hostname]];
        [server setUser:[[aHost pool] username]];
        [server setPassword:[[aHost pool] password]];
        [server setPort:(unsigned int)[[aHost port] integerValue]];
        [server setSchema:@"mysql"];
        connection = [MysqlConnection connectToServer:server];
    }
    
    @catch (MysqlException *e) {
        NSLog(@"Problem connecting");
    }
    
    return connection;
}

- (void) refreshSlavePanel: (MysqlSlaveStatus *) status {
    @synchronized(dataList) {
        if([mainDisplay contentView] == logDisplay) {
            if([details contentView] != replView) {
                [details setContentView:replView];
                [killButton setEnabled:NO];
            }
        } else {
            if([statusDetails contentView] != replView) {
                [statusDetails setContentView:replView];
            }
        }
        if([status masterLogFile]) {
            [replicationIOState setStringValue:[status slaveIOState]];
            [replicationMasterHost setStringValue:[status masterHost]];
            [replicationMasterLog setStringValue:[status masterLogFile]];
            [replicationMasterPosition setStringValue:[NSString stringWithFormat:@"%lu",(unsigned long)[status masterLogPosition]]];
            [replicationRelayLog setStringValue:[status relayLogFile]];
            [replicationRelayPosition setStringValue:[NSString stringWithFormat:@"%lu",(unsigned long)[status relayLogPosition]]];
            [replicationRelayPosition setStringValue:[NSString stringWithFormat:@"%lu",(unsigned long)[status relayLogPosition]]];
            if([status slaveSQLRunning] && [status slaveIORunning]) {
                [replicationSlaveRunning setStringValue:@"Yes"];
            } else {
                [replicationSlaveRunning setStringValue:@"No"];
            }
            [replicationSecondsBehindMaster setStringValue:[NSString stringWithFormat:@"%d",(int)[status secondsBehindMaster ]]];
            NSString *newError = [NSString stringWithFormat:@"No Last SQL or I/O Error"];
            if(![[status slaveSQLError] isEqualToString:@""]) {
                newError = [status slaveSQLError];
            } else if(![[status slaveIOError] isEqualToString:@""]) {
                newError = [status slaveIOError];
            }
            if(![newError isEqualToString:[replicationError string]]) {
                [replicationError setString:newError];
            }
        } else {
            [replicationIOState setStringValue:@"Slave Unconfigured"];
            [replicationMasterHost setStringValue:@"Slave Unconfigured"];
            [replicationMasterLog setStringValue:@"Slave Unconfigured"];
            [replicationMasterPosition setStringValue:@"Slave Unconfigured"];
            [replicationRelayLog setStringValue:@"Slave Unconfigured"];
            [replicationRelayPosition setStringValue:@"Slave Unconfigured"];
            [replicationRelayPosition setStringValue:@"Slave Unconfigured"];
            [replicationSlaveRunning setStringValue:@"No"];
            [replicationSecondsBehindMaster setStringValue:@"Slave Unconfigured"];
            [replicationError setString:@"Slave Unconfigured"];
        }
        
    }
}

- (void) refreshMySQLQueryPanel: (DBMLogEntry *) entry {
    @synchronized(dataList) {
        if([details contentView] != queryView) {
            [details setContentView:queryView];
            [killButton setEnabled:YES];
        }
        [monitorProcess setStringValue:[entry getQueryValue:@"ID"]];
        [monitorHost setStringValue:[entry getQueryValue:@"HOST"]];
        [monitorCommand setStringValue:[entry getQueryValue:@"COMMAND"]];
        [monitorState setStringValue:[entry getQueryValue:@"STATE"]];
        [monitorUser setStringValue:[entry getQueryValue:@"USER"]];
        [monitorDatabase setStringValue:[entry getQueryValue:@"DB"]];
        [monitorTime setStringValue:[entry getQueryValue:@"TIME"]];
        [monitorExamine setStringValue:[entry getQueryValue:@"ROWS_EXAMINED"]];
        [monitorRead setStringValue:[entry getQueryValue:@"ROWS_READ"]];
        [monitorSent setStringValue:[entry getQueryValue:@"ROWS_SENT"]];
        NSString *queryString = [[NSString alloc] initWithData:[entry getQueryData:@"INFO"]
                                                      encoding:NSASCIIStringEncoding];
        if(![queryString isEqualToString:[monitorQuery string]]) {
            [monitorQuery setString:queryString];
        }
    }
}

- (NSBlockOperation *) generateRefreshOperation {
    __block NSBlockOperation *refreshBlock = [NSBlockOperation blockOperationWithBlock:^ {
        if(![refreshBlock isCancelled]) {
            usleep(250000);
            @synchronized(dataList) {
                DBMLogEntry *selectedEntry = nil;
                if([logView selectedRow] < [dataList count]) {
                    selectedEntry = [dataList objectAtIndex:[logView selectedRow]];
                }
                if(selectedEntry != currentLogEntry) {
                    if([dataList containsObject:currentLogEntry]) {
                        [logView selectRowIndexes:[NSIndexSet indexSetWithIndex:[dataList indexOfObject:currentLogEntry]] byExtendingSelection:NO];
                        selectedEntry = currentLogEntry;
                    } else {
                        selectedEntry = nil;
                        [logView deselectAll:nil];
                    }
                }

                NSMutableArray * deadHosts = [NSMutableArray array];
                for(DBMLogEntry *entry in dataList) {
                    if(([[[entry eventHost] active] integerValue] != 1) || ([[[[entry eventHost] pool ]active] integerValue] != 1)) {
                        [deadHosts addObject:[entry eventHost]];
                        [entry setDead:YES];
                        [entry setDisplayTimeout:nil];
                    }
                    if([entry displayTimeout] && (sliderValue >= 0)) {
                        if([[entry displayTimeout] timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970]) {
                            [entry setDisplayTimeout:nil];
                        }
                    }
                }
                for(MySQLHost *aHost in deadHosts) {
                    [self discardMySQLDead:aHost];
                }
                // Choose detail displays
                if([mainDisplay contentView] == logDisplay) {
                    if([[logView selectedRowIndexes] count] == 0) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                            if([details contentView] != noView) {
                                [details setContentView:noView];
                                [killButton setEnabled:NO];
                            }
                        }];
                    } else {
                        if(selectedEntry) {
                            if([[selectedEntry processID] isEqualToString:@"-1"]) {
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                    [self refreshSlavePanel:[selectedEntry slaveStatus]];
                                }];
                            } else {
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                    [self refreshMySQLQueryPanel:selectedEntry];
                                }];
                            }
                        }
                    }
                }
                if(logSortDescriptors) {
                    [dataList sortUsingDescriptors:logSortDescriptors];

                }
                [logView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                if(selectedEntry) {
                    BOOL found=0;
                    for(int i=0;i<[dataList count];i++) {
                        if([dataList objectAtIndex:i] == selectedEntry) {
                            [logView selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
                            found=YES;
                        }
                    }
                    if(!found) {
                        [logView selectRowIndexes:nil byExtendingSelection:NO];
                    }
                }
            }
            @synchronized(detailList) {
                DBMDetailEntry *selectedEntry = nil;
                if([detailView selectedRow] < [detailList count]) {
                    selectedEntry = [detailList objectAtIndex:[detailView selectedRow]];
                }
                if([mainDisplay contentView] == detailDisplay) {
                    if([[detailView selectedRowIndexes] count] == 0) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                            if([statusDetails contentView] != noView) {
                                [statusDetails setContentView:noView];
                            }
                        }];
                    } else {
                        if(selectedEntry) {
                            if([[[selectedEntry host] slave] integerValue]) {
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                    [self refreshSlavePanel:[selectedEntry slaveStatus]];
                                }];
                            } else {
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                    if([statusDetails contentView] != noView) {
                                        [statusDetails setContentView:noView];
                                    }
                                }];
                            }
                        }
                    }
                    if(statusSortDescriptors) {
                        [detailList sortUsingDescriptors:statusSortDescriptors];
                    }
                    [detailView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    if(selectedEntry) {
                        BOOL found=0;
                        for(int i=0;i<[detailList count];i++) {
                            if([detailList objectAtIndex:i] == selectedEntry) {
                                [detailView selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
                                found = YES;
                            }
                        }
                        if(!found) {
                            [detailView selectRowIndexes:nil byExtendingSelection:NO];
                        }
                    }
                }
            }
            @synchronized(checkQueue) {
                __block NSOperation *new_operation = [self generateRefreshOperation];
                [checkQueue addOperation:new_operation];
                new_operation = nil;
            }
            refreshBlock = nil;
        }
    }];
    
    return refreshBlock;
}



- (NSBlockOperation *) generateMySQLOperation:(MySQLHost *) aHost {
    __block NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^ {
        if(![operation isCancelled]) {
            // Make sure we mark which elements aren't updated
            [self clearUpdates:aHost];
            
            MysqlConnection *connection = [self connectToHost:aHost];
            if(connection) {
                [self updateMySQLQueries:connection host:aHost];
                if([[aHost slave] integerValue] != 0) {
                    [self updateMySQLSlaveStatus:connection host:aHost];
                }
                [self updateMySQLStatistics:connection host:aHost];
                [connection forceDisconnect];
            } else {
                NSLog(@"Failed to connect to host");
                [self updateMySQLFail:aHost];
            }
            [self discardMySQLDead:aHost];
            usleep(500000);
            if(![operation isCancelled]) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    @synchronized(checkQueue) {
                        __block NSOperation *new_operation = [self generateMySQLOperation:aHost];
                        [checkQueue addOperation:new_operation];
                        new_operation = nil;

                    }
                }];
            }
        }
        operation = nil;

    }];
    
    return operation;
}

- (void) reloadDataWatchers {
    
    // First we're going to purge everything in the operation Queue:
    [checkQueue cancelAllOperations];

    
    // Read through everything that was set in the config panel, and start spinning off threads.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pool"];
    NSError *error = nil;
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSArray *fetchedArray = [moc executeFetchRequest:request error:&error];
    if(fetchedArray == nil) {
        NSLog(@"Error while fetching!\n%@",([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        exit(1);
    }
    @synchronized(checkQueue) {
        __block NSBlockOperation *refreshLoop = [self generateRefreshOperation];
        [checkQueue addOperation:refreshLoop];
    }
    
    // In the first loop we will initialize the detailed list, since in the second we're spawning monitor threads and they will immediately start using them
    @synchronized(detailList) {
        [detailList removeAllObjects];
        for(Pool *aPool in fetchedArray) {
            for(MySQLHost *aHost in [aPool mysqlhosts]) {
                if(([[aPool active] integerValue] == 1) && ([[aHost active] integerValue] == 1)) {
                    DBMDetailEntry *newEntry = [[DBMDetailEntry alloc] init];
                    [newEntry setHost:aHost];
                    [detailList addObject:newEntry];
                }
            }
        }
    }

    // Now start spinning up monitor threads
    for(Pool *aPool in fetchedArray) {
        for(MySQLHost *aHost in [aPool mysqlhosts]) {
            if(([[aPool active] integerValue] == 1) && ([[aHost active] integerValue] == 1)) {
                // Sleep between each connection to give us a head start on spacing out updates
                usleep(5000);
                @synchronized(checkQueue) {
                    __block NSOperation *operation = [self generateMySQLOperation:aHost];
                    [checkQueue addOperation:operation];
                    operation = nil;
                }
            } else {
                [self clearUpdates:aHost];
                [self discardMySQLDead:aHost];
            }
        }
    }
}

#pragma mark Config Sheet

- (IBAction)openConfigSheet:(id)sender {
    [checkQueue cancelAllOperations];
    [NSApp beginSheet:configSheet modalForWindow:[mainDisplay window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    [checkQueue cancelAllOperations];
}

- (IBAction)endConfigSheet:(id)sender {
    [NSApp endSheet:configSheet];
    // Time to spawn the threads.
    [self reloadDataWatchers];
    [configSheet orderOut:configSheet];
}

#pragma mark process manipulation

- (void)killEnded: (NSAlert *)alert code:(NSInteger) choice context:(void *) v {
    if(choice == NSAlertDefaultReturn) {
        @synchronized(dataList) {
            DBMLogEntry *entry = (__bridge DBMLogEntry *) v;
            MysqlConnection *connection = [self connectToHost:[entry eventHost]];
            [MysqlKill killProcess:connection processID:[entry processID]];
        }
    }
}

- (IBAction)killProcess:(id)sender {
    @synchronized(dataList) {
        if([[logView selectedRowIndexes] count] < 1) {
            return;
        }
        DBMLogEntry *entry = [dataList objectAtIndex:[logView selectedRow]];
        if([[entry processID] isEqualToString:@"-1"]) {
            // Trying to kill replication lag.  ignore
            return;
        } else if([[entry processID] isEqualToString:@"-2"]) {
            // Trying to kill can't connect to host - remove from view
            [dataList removeObjectAtIndex:[logView selectedRow]];
        } else if([[entry processID] isEqualToString:@"Dead Process"]) {
            // This process is dead already - remove it from view
            [dataList removeObjectAtIndex:[logView selectedRow]];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Do you want to kill this process?"
                                                 defaultButton:@"Terminate"
                                               alternateButton:@"Cancel"
                                                   otherButton:nil
                                     informativeTextWithFormat:@"Process %@ will be killed",[entry processID]];
                [alert beginSheetModalForWindow:[logView window]
                                  modalDelegate:self
                                 didEndSelector:@selector(killEnded:code:context:)
                                    contextInfo:(__bridge void *)([dataList objectAtIndex:[logView selectedRow]])];
            }];
        }
    }
}

#pragma mark tableView cruft

- (NSInteger) numberOfRowsInTableView: (NSTableView *) tv {
    
    NSInteger result = 0;
    if(tv == logView) {
        @synchronized(dataList) {
            result = [dataList count];
        }
    } else {
        @synchronized(detailList) {
            result = [detailList count];
        }
    }
    return result;
}

- (void) tableViewSelectionIsChanging:(NSNotification *) aNotification {
    // NSLog(@"Changing element");
    @synchronized(dataList) {
        if([logView selectedRow] < [dataList count]) {
            currentLogEntry = [dataList objectAtIndex:[logView selectedRow]];
        } else {
            currentLogEntry = nil;
        }
    }
}

- (void) tableViewSelectionDidChange:(NSNotification *) aNotification {
    // NSLog(@"selected new element");
    @synchronized(dataList) {
        if([logView selectedRow] < [dataList count]) {
            currentLogEntry = [dataList objectAtIndex:[logView selectedRow]];
        } else {
            currentLogEntry = nil;
        }
    }
}

- (void) tableView:(NSTableView *)tv sortDescriptorsDidChange: (NSArray *)oldDescriptors {
    NSArray *newDescriptors = [tv sortDescriptors];
    if(tv == logView) {
        @synchronized(dataList) {
            DBMLogEntry *selectedEntry = nil;
            if([logView selectedRow] < [dataList count]) {
                selectedEntry = [dataList objectAtIndex:[logView selectedRow]];
            }
            [dataList sortUsingDescriptors:newDescriptors];
            logSortDescriptors = newDescriptors;
            if(selectedEntry) {
                BOOL found=0;
                for(int i=0;i<[dataList count];i++) {
                    if([dataList objectAtIndex:i] == selectedEntry) {
                        [logView selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
                        found = YES;
                    }
                }
                if(!found) {
                    [detailView selectRowIndexes:nil byExtendingSelection:NO];
                }
            }
        }
    } else {
        @synchronized(detailList) {
            DBMDetailEntry *selectedEntry = nil;
            if([detailView selectedRow] < [detailList count]) {
                selectedEntry = [detailList objectAtIndex:[detailView selectedRow]];
            }
            [detailList sortUsingDescriptors:newDescriptors];
            statusSortDescriptors = newDescriptors;
            if(selectedEntry) {
                BOOL found=0;
                for(int i=0;i<[detailList count];i++) {
                    if([detailList objectAtIndex:i] == selectedEntry) {
                        [detailView selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
                        found = YES;
                    }
                }
                if(!found) {
                    [detailView selectRowIndexes:nil byExtendingSelection:NO];
                }
            }
        }
    }
    [tv performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (id) tableView: (NSTableView *) tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if(tv == logView) {
        @synchronized(dataList) {
            if(row < [dataList count]) {
                DBMLogEntry *entry = [dataList objectAtIndex:row];
                if([[tableColumn identifier] isEqualToString:@"timestamp"]) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"HH:mm:ss"];
                    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[entry eventTime]]];
                } else if ([[tableColumn identifier] isEqualToString:@"duration"]) {
                    return [NSString stringWithFormat:@"%ld",(long)[entry duration]];
                } else if ([[tableColumn identifier] isEqualToString:@"hostname"]) {
                    if(![[entry eventHost] alias]) {
                        return [NSString stringWithFormat:@"%@",[[entry eventHost] hostname]];
                    } else {
                        return [NSString stringWithFormat:@"%@",[[entry eventHost] alias]];
                    }
                } else if ([[tableColumn identifier] isEqualToString:@"message"]) {
                    return [NSString stringWithFormat:@"%@",[entry eventString]];
                }
            }
        }
    } else {
        @synchronized(detailList) {
            if(row < [detailList count]) {
                DBMDetailEntry *entry = [detailList objectAtIndex:row];
                if([[tableColumn identifier] isEqualToString:@"host"]) {
                    // NSLog(@"Displaying a host name here");
                    if(![[entry host] alias]) {
                        return [NSString stringWithFormat:@"%@",[[entry host] hostname]];
                    } else {
                        return [NSString stringWithFormat:@"%@",[[entry host] alias]];
                    }
                } else if([[tableColumn identifier] isEqualToString:@"connections"]) {
                    return [NSString stringWithFormat:@"%lu",[entry connections]];
                } else if([[tableColumn identifier] isEqualToString:@"freepages"]) {
                    return [NSString stringWithFormat:@"%lu",[entry freePages]];
                } else if([[tableColumn identifier] isEqualToString:@"totalpages"]) {
                    return [NSString stringWithFormat:@"%lu",[entry totalPages]];
                } else if([[tableColumn identifier] isEqualToString:@"slowqueries"]) {
                    return [NSString stringWithFormat:@"%lu",[entry slowQueries]];
                } else if([[tableColumn identifier] isEqualToString:@"readspersec"]) {
                    return [NSString stringWithFormat:@"%.2f",[entry readsPerSecond]];
                } else if([[tableColumn identifier] isEqualToString:@"writespersec"]) {
                    return [NSString stringWithFormat:@"%.2f",[entry writesPerSecond]];
                } else if([[tableColumn identifier] isEqualToString:@"activequeries"]) {
                    return [NSString stringWithFormat:@"%lu",[entry activeQueries]];
                }
            }
        }
    }
    return nil;
}

- (void) tableView: (NSTableView *) tv willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)col row:(int)row {
    if(tv == logView) {
        if(row == [logView selectedRow]) {
            [cell setTextColor:[NSColor whiteColor]];
        } else {
            @synchronized(dataList) {
                if(row < [dataList count]) {
                    DBMLogEntry *entry = [dataList objectAtIndex:row];
                    if([entry dead] == YES) {
                        [cell setTextColor:[NSColor grayColor]];
                    } else if([entry displayTimeout] > 0) {
                        [cell setTextColor:[NSColor redColor]];
                    } else if([entry duration] < 0) {
                        [cell setTextColor:[NSColor redColor]];
                    } else {
                        [cell setTextColor:[NSColor blackColor]];
                    }
                }
            }
        }

    }
}

#pragma mark MySQL Updates

- (void) clearUpdates:(MySQLHost *) aHost {
    @synchronized(dataList) {
        for(DBMLogEntry *entry in dataList) {
            MySQLHost *logHost = [entry eventHost];
            if([logHost hostname] == [aHost hostname]) {
                [entry setUpdated:NO];
            }
        }
        
    }
}

- (void) updateMySQLQueries: (MysqlConnection *) connection host:(MySQLHost *) aHost {
    NSString *query = [NSString stringWithFormat:@"select * from INFORMATION_SCHEMA.PROCESSLIST where Command!='Sleep' and Command!='Binlog Dump' and User!='system user'"];
    MysqlFetch *slowFetch;
    @try {
         slowFetch = [MysqlFetch fetchWithCommand:query
                                                onConnection:connection];
    }
    @catch (MysqlException *e) {
        NSLog(@"Server has gone away!  skipping");
        return;
    }
    
    // First we have to update active queries.  hackery :/
    @synchronized(detailList) {
        for(DBMDetailEntry *entry in detailList) {
            if([[[entry host] hostname] isEqualToString:[aHost hostname]]) {
                [entry setActiveQueries:[slowFetch.results count] - 1];
            }
        }
    }
    if((unsigned long)[slowFetch.results count] > 0) {
        for (NSDictionary *queryRow in slowFetch.results) {
            if([queryRow objectForKey:@"INFO"] != [NSNull null]) {
                if([[queryRow objectForKey:@"TIME"] intValue] >  (long)[[[aHost pool] monitorTimer] integerValue]) {
                    NSData *queryData = [queryRow objectForKey:@"INFO"];
                    NSString *queryString = [[[NSString alloc] initWithData:queryData
                                                                   encoding:NSASCIIStringEncoding]
                                             stringByReplacingOccurrencesOfString:@"\r\n"
                                             withString:@" "];
                    NSString *logString = [NSString stringWithFormat:@"%@ - %@",[queryRow objectForKey:@"HOST"], queryString];
                    
                    DBMLogEntry *currentEntry = nil;
                    @synchronized(dataList) {
                        NSString *processID = [NSString stringWithFormat:@"%@",[queryRow objectForKey:@"ID"]];
                        for(DBMLogEntry *entry in dataList) {
                            MySQLHost *logHost = [entry eventHost];
                            if([logHost hostname] == [aHost hostname]) {
                                if([[entry processID] isEqualToString:processID]) {
                                    currentEntry = entry;
                                }
                            }
                        }
                        if(!currentEntry) {
                            currentEntry = [[DBMLogEntry alloc] initWithHost:aHost processID:processID];
                            [dataList addObject:currentEntry];
                        }
                        
                        [currentEntry setUpdated:YES];
                        [currentEntry setEventString:logString];
                        [currentEntry setDuration:[[queryRow objectForKey:@"TIME"] intValue]];
                        if([currentEntry duration] == 2147483647) {
                            // For some reason MariaDB messes this up.  Really is a 1, but comes out as crazyint.  Fix in display
                            [currentEntry setDuration:1];
                        }
                        if([currentEntry duration] >= [[[aHost pool] triggerTimer] integerValue]) {
                            [currentEntry setDisplayTimeout:[NSDate dateWithTimeIntervalSinceNow:sliderValue]];
                        } else {
                            [currentEntry setDisplayTimeout:nil];
                        }
                        [currentEntry setQuery:queryRow];
                    }
                }
            }
        }
    }
}

- (void) updateMySQLSlaveStatus: (MysqlConnection *) connection host:(MySQLHost *) aHost {
    MysqlSlaveStatus *slaveStatus = nil;
    @try {
        slaveStatus = [MysqlSlaveStatus statusForConnection:connection];
    }
    @catch (MysqlException *e) {
        NSLog(@"Connection failed while pulling slave status - aborting");
        return;
    }
    
    if(([slaveStatus secondsBehindMaster] > 1) || ([slaveStatus slaveSQLRunning] == NO) || ([slaveStatus slaveIORunning] == NO)) {
        DBMLogEntry *currentEntry = nil;
        @synchronized(dataList) {
            for(DBMLogEntry *entry in dataList) {
                MySQLHost *logHost = [entry eventHost];
                if([logHost hostname] == [aHost hostname]) {
                    if([[entry processID] isEqualToString:@"-1"]) {
                        currentEntry = entry;
                    }
                }
            }
            if(!currentEntry) {
                currentEntry = [[DBMLogEntry alloc] initWithHost:aHost processID:@"-1"];
                [dataList addObject:currentEntry];
            }
            [currentEntry setUpdated:YES];
            [currentEntry setSlaveStatus:slaveStatus];
            if([slaveStatus secondsBehindMaster] > 1) {
                [currentEntry setEventString:@"Replication has fallen behind"];
                [currentEntry setDuration:(int)[slaveStatus secondsBehindMaster]];
            } else {
                [currentEntry setEventString:@"Replication is Broken!"];
                [currentEntry setDuration:[[NSDate date] timeIntervalSinceDate:[currentEntry eventTime]]];
            }
            if([currentEntry duration] >= [[[aHost pool] triggerTimer] integerValue]) {
                [currentEntry setDisplayTimeout:[NSDate dateWithTimeIntervalSinceNow:sliderValue]];
            }
        }
    }
    @synchronized(detailList) {
        for(DBMDetailEntry *entry in detailList) {
            if([[entry host] hostname] == [aHost hostname]) {
                [entry setSlaveStatus:slaveStatus];
            }
        }
    }
}

- (void) updateMySQLStatistics: (MysqlConnection *) connection host: (MySQLHost *) aHost {
    DBMDetailEntry *myEntry = nil;
    @synchronized(detailList) {
        for(DBMDetailEntry *entry in detailList) {
            if([[[entry host] hostname] isEqualToString:[aHost hostname]]) {
                myEntry = entry;
            }
        }
    }
    if([myEntry pollsLeftBeforeStatus] < 1) {
        MysqlStatus *serverStatus = nil;
        @try {
            serverStatus = [MysqlStatus statusForConnection:connection];
        }
        @catch (MysqlException *e) {
            NSLog(@"Connection failed while pulling status - aborting");
            return;

        }
        @synchronized(detailList) {
            [myEntry setConnections:[serverStatus threadsConnected]];
            [myEntry setFreePages:[serverStatus innodbPagesFree]];
            [myEntry setTotalPages:[serverStatus innodbPagesTotal]];
            [myEntry setSlowQueries:[serverStatus slowQueries]];
            [myEntry setLastReads:[myEntry currentReads]];
            [myEntry setLastWrites:[myEntry currentWrites]];
            [myEntry setCurrentReads:[serverStatus innodbDataReads]];
            [myEntry setCurrentWrites:[serverStatus innodbDataWrites]];
            [myEntry setLastQueryTime:[myEntry currentQueryTime]];
            [myEntry setCurrentQueryTime:[NSDate date]];
            [myEntry setPollsLeftBeforeStatus:2];
            [myEntry setReadsPerSecond:(([myEntry currentReads] - [myEntry lastReads]) / [myEntry timeSinceLastUpdate])];
            [myEntry setWritesPerSecond:(([myEntry currentWrites] - [myEntry lastWrites]) / [myEntry timeSinceLastUpdate])];
        }
    } else {
        @synchronized(detailList) {
            [myEntry setPollsLeftBeforeStatus:[myEntry pollsLeftBeforeStatus] - 1];
        }
    }
}

- (void) updateMySQLFail: (MySQLHost *) aHost {
    DBMLogEntry *currentEntry = nil;
    @synchronized(dataList) {
        for(DBMLogEntry *entry in dataList) {
            MySQLHost *logHost = [entry eventHost];
            if([logHost hostname] == [aHost hostname]) {
                if([[entry processID] isEqualToString:@"-2"]) {
                    currentEntry = entry;
                }
            }
        }
        if(!currentEntry) {
            currentEntry = [[DBMLogEntry alloc] initWithHost:aHost processID:@"-2"];
            [currentEntry setEventString:@"Could not connect to host!"];
            [dataList addObject:currentEntry];
        }
        [currentEntry setUpdated:YES];
        [currentEntry setDuration:[[NSDate date] timeIntervalSinceDate:[currentEntry eventTime]]];
    }
}

- (void) discardMySQLDead: (MySQLHost *) aHost {
    NSMutableArray * discards = [NSMutableArray array];
    @synchronized(dataList) {
        for(DBMLogEntry *entry in dataList) {
            MySQLHost *logHost = [entry eventHost];
            if([logHost hostname] == [aHost hostname]) {
                if([entry updated] == NO) {
                    if(![entry displayTimeout]) {
                        [discards addObject:entry];
                    } else if ([trackQuery integerValue] == 0) {
                        [discards addObject:entry];
                    } else {
                        [entry setDead:YES];
                        [entry setProcessID:@"Dead Process"];
                    }
                }
            }
        }
        for(DBMLogEntry *entry in discards) {
            [dataList removeObject:entry];
        }
    }
}

#pragma mark help!

- (IBAction) openHelpPanel: (id)sender {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"index.html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [[NSWorkspace sharedWorkspace] openURL:url];
}
@end