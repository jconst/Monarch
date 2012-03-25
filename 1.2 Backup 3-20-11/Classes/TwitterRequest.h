//
//  TwitterRequest.h
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VariableStore.h"
#import "GSTwitPicEngine.h"

@class GSTwitPicEngine;

@interface TwitterRequest : NSObject {
	NSString		*username;
	NSString		*password;
	NSMutableURLRequest	*theRequest;
	NSURLConnection *theConnection;
	id				delegate;
	
	BOOL			sendDidFail;
	BOOL			isPost;
	NSString		*requestBody;
	GSTwitPicEngine *twitPicEngine;
}

@property(nonatomic, retain) NSString		*username;
@property(nonatomic, retain) NSString		*password;
@property(nonatomic, retain) id				delegate;
@property(nonatomic, retain) GSTwitPicEngine *twitPicEngine;

//-(void)friends_timeline:(id)requestDelegate requestSelector:(SEL)requestSelector;
//-(void)request;

-(void)statuses_update:(NSString *)status images:(NSArray *)images requestDelegate:(id)requestDelegate;
- (void)twitpicDidFinishUpload:(NSString *)response;
- (void)twitpicDidFailUpload:(NSString *)error;

@end
