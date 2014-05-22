//
//  INDeleteDraftChange.m
//  InboxFramework
//
//  Created by Ben Gotow on 5/20/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INDeleteDraftChange.h"
#import "INThread+Private.h"


@implementation INDeleteDraftChange

- (BOOL)canCancelPendingChange:(INModelChange*)other
{
    if ([[other model] isEqual: self.model] && [other isKindOfClass: [INSaveDraftChange class]])
        return YES;
    if ([[other model] isEqual: self.model] && [other isKindOfClass: [INSendDraftChange class]])
        return YES;
    if ([[other model] isEqual: self.model] && [other isKindOfClass: [INDeleteDraftChange class]])
        return YES;
    return NO;
}

- (BOOL)canStartAfterChange:(INModelChange*)other
{
	// If the other operation is sending the draft, it's too late!
	// Gotta tell the user the draft couldn't be deleted.
    if ([[other model] isEqual: self.model] && [other isKindOfClass: [INSendDraftChange class]])
        return NO;
    return YES;
}

- (NSURLRequest *)buildAPIRequest
{
    NSAssert(self.model, @"INDeleteDraftChange asked to buildRequest with no model!");
	NSAssert([self.model namespaceID], @"INDeleteDraftChange asked to buildRequest with no namespace!");
	
    NSError * error = nil;
    NSString * url = [[NSURL URLWithString:[self.model resourceAPIPath] relativeToURL:[INAPIManager shared].baseURL] absoluteString];
	return [[[INAPIManager shared] requestSerializer] requestWithMethod:@"DELETE" URLString:url parameters:nil error:&error];
}

- (void)applyLocally
{
    INDraft * draft = (INDraft *)[self model];
	[[INDatabaseManager shared] unpersistModel: draft];

    INThread * thread = [draft thread];
    if (thread) {
        [thread removeDraftID: [draft ID]];
        [[INDatabaseManager shared] persistModel: thread];
    }
}

- (void)applyRemotelyWithCallback:(CallbackBlock)callback
{
    // If we're deleting a draft that was never synced to the server,
    // there's no need for an API call. Just return.
    if ([self.model isUnsynced])
        callback(self, YES);
    else
        [super applyRemotelyWithCallback: callback];
}

- (void)rollbackLocally
{
	// re-persist the message to the database
    INDraft * draft = (INDraft *)[self model];
    [[INDatabaseManager shared] persistModel: draft];
    
    INThread * thread = [draft thread];
    if (thread) {
        [thread addDraftID: [draft ID]];
        [[INDatabaseManager shared] persistModel: thread];
    }
}


@end
