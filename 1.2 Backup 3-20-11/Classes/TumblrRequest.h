//
//  TumblrRequest.h
//  Monarch
//
//  Created by Joseph Constan on 6/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VariableStore.h"

@interface TumblrRequest : NSObject {
	NSString		*username;
	NSString		*password;
	NSMutableURLRequest	*theRequest;
	NSURLConnection *theConnection;
	id				delegate;
	
	BOOL			sendDidFail;
	BOOL			isPost;
	NSMutableString		*requestBody;
}

@property(nonatomic, retain) NSString		*username;
@property(nonatomic, retain) NSString		*password;
@property(nonatomic, retain) id				delegate;

-(void)request;

-(void)statuses_update:(NSString *)status title:(NSString *)title image:(UIImage *)image delegate:(id)requestDelegate;

@end
