//
//  DBMDocument.h
//  DB Monitor
//
//  Created by mandrake on 4/8/13.
//  Copyright (c) 2013 mandrake. All rights reserved.
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
