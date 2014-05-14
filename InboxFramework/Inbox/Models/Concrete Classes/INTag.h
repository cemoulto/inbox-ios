//
//  INLabel.h
//  BigSur
//
//  Created by Ben Gotow on 4/30/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelObject.h"

static NSString * INTagIDUnread = @"unread";
static NSString * INTagIDArchive = @"archive";
static NSString * INTagIDInbox = @"inbox";

@interface INTag : INModelObject

- (NSString*)name;

@end