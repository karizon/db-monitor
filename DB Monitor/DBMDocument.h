//
//  DBMDocument.h
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

#import <Cocoa/Cocoa.h>
@class MysqlConnection;
@class MysqlSlaveStatus;
@class DBMLogEntry;
@class MySQLHost;

@interface DBMDocument : NSPersistentDocument {
    IBOutlet NSWindow *configSheet;
    
    IBOutlet NSTableView *logView;
    IBOutlet NSTableView *detailView;
    
    IBOutlet NSPopUpButton *viewSelector;
    
    IBOutlet NSTextField *monitorProcess;
    IBOutlet NSTextField *monitorHost;
    IBOutlet NSTextField *monitorCommand;
    IBOutlet NSTextField *monitorState;
    IBOutlet NSTextField *monitorUser;
    IBOutlet NSTextField *monitorDatabase;
    IBOutlet NSTextField *monitorTime;
    IBOutlet NSTextField *monitorExamine;
    IBOutlet NSTextField *monitorRead;
    IBOutlet NSTextField *monitorSent;
    IBOutlet NSTextView *monitorQuery;
    
    IBOutlet NSTextField *replicationIOState;
    IBOutlet NSTextField *replicationMasterHost;
    IBOutlet NSTextField *replicationMasterLog;
    IBOutlet NSTextField *replicationMasterPosition;
    IBOutlet NSTextField *replicationRelayLog;
    IBOutlet NSTextField *replicationRelayPosition;
    IBOutlet NSTextField *replicationSlaveRunning;
    IBOutlet NSTextField *replicationSecondsBehindMaster;
    IBOutlet NSTextView *replicationError;
    
    IBOutlet NSView *logDisplay;
    IBOutlet NSView *detailDisplay;
    IBOutlet NSBox *mainDisplay;
    
    IBOutlet NSView *replView;
    IBOutlet NSView *queryView;
    IBOutlet NSView *noView;
    IBOutlet NSBox *details;
    IBOutlet NSBox *statusDetails;
    
    IBOutlet NSButton *killButton;
    
    IBOutlet NSButton *trackQuery;
    IBOutlet NSSlider *trackTimer;
    IBOutlet NSTextField *secondsDisplay;
    
    int sliderValue;
    
    NSMutableArray *dataList;
    NSMutableArray *detailList;
    
    NSArray *statusSortDescriptors;
    NSArray *logSortDescriptors;
    
    DBMLogEntry *currentLogEntry;
    BOOL refreshPanel;
    
    NSOperationQueue *checkQueue;
}

- (void) changeMainDisplay:(NSView *) view;

- (MysqlConnection *) connectToHost: (MySQLHost *)aHost;

- (void) refreshSlavePanel: (MysqlSlaveStatus *) status;
- (void) refreshMySQLQueryPanel: (DBMLogEntry *) entry;

- (NSBlockOperation *) generateMySQLOperation:(MySQLHost *) aHost ;
- (NSBlockOperation *) generateRefreshOperation;

- (IBAction)openConfigSheet:(id)sender;
- (IBAction)endConfigSheet:(id)sender;

- (IBAction)killProcess:(id)sender;

- (void) reloadDataWatchers;

- (void) clearUpdates:(MySQLHost *) aHost;
- (void) updateMySQLQueries: (MysqlConnection *) connection host:(MySQLHost *) aHost;
- (void) updateMySQLSlaveStatus: (MysqlConnection *) connection host:(MySQLHost *) aHost;
- (void) updateMySQLStatistics: (MysqlConnection *) connection host: (MySQLHost *) aHost;
- (void) updateMySQLFail: (MySQLHost *) aHost;
- (void) discardMySQLDead: (MySQLHost *) aHost;

- (IBAction) openHelpPanel: (id)sender;

@end
