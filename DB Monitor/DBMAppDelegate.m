//
//  DBMAppDelegate.m
//  DB Monitor
//
//  Created by Geoff Harrison on 7/2/14.
//  Copyright (c) 2014 mandrake. All rights reserved.
//

#import "DBMAppDelegate.h"

@implementation DBMAppDelegate


- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    NSURL *lastURL=[[[NSDocumentController sharedDocumentController] recentDocumentURLs] objectAtIndex:0];
    if (lastURL!=nil)
    {
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:lastURL display:YES error:nil];
        return NO;
    }
    
    return YES;
}


@end
