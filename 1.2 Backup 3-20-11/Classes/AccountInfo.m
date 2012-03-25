//
//  AccountInfo.m
//  Monarch
//
//  Created by Joseph Constan on 5/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountInfo.h"


@implementation AccountInfo

@synthesize username, password, siteType, selected, blogName, blogID;

- (id)init
{
    self = [super init];
   
	if (self) {
		selected = YES;
		username = nil;
		password = nil;
		siteType = 0;
	}
    return self;
}

- (void)dealloc
{
	[username release];
	[password release];
	[blogID release];
	[blogName release];
	[super dealloc];
}
@end
