//
//  VariableStore.m
//  Monarch
//
//  Created by Joseph Constan on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VariableStore.h"


@implementation VariableStore

@synthesize accounts, images, twitterEngine, currentName, clm;

static VariableStore *myInstance = nil;

+ (VariableStore *)sharedInstance
{
//	@synchronized(self)
	{	
		// check to see if an instance already exists
		if (nil == myInstance) {
			myInstance  = [[VariableStore alloc] init];
		}
		// return the instance of this class
		return myInstance;
	}
}
+(id)alloc
{
	//	@synchronized(self)
	{
		NSAssert(myInstance == nil, @"Attempted to allocate a second instance of a singleton.");
		myInstance = [super alloc];
		return myInstance;
	}
}
+(id)copy
{
	//  @synchronized(self)
	{
		NSAssert(myInstance == nil, @"Attempted to copy the singleton.");
		return myInstance;
	}
}
- (void)dealloc {
	[accounts release];
	[images release];
    [super dealloc];
}

@end