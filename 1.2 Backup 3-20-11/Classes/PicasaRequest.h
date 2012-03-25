//
//  PicasaRequest.h
//  Monarch
//
//  Created by Joseph Constan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VariableStore.h"


@interface PicasaRequest : NSObject {
	id				delegate;
	NSString		*username;
	NSString		*password;
	NSMutableURLRequest	*theRequest;
	NSURLConnection *theConnection;
	UIAlertView	*captchaReqAlert;
	NSMutableData	*receivedData;
	NSMutableString	*dataString;
	NSString		*requestBody;
	
	NSString *lastStatus;
	NSString *lastTitle;
	NSString *lastBlogID;
	
	BOOL			isGettingList;
	BOOL			sendDidFail;
	BOOL			authenticating;
	BOOL			didReceiveList;
	BOOL			renewedToken;
}

@property(nonatomic, retain) NSString		*username;
@property(nonatomic, retain) NSString		*password;
@property(nonatomic, retain) id				delegate;
@property(nonatomic, retain) UIAlertView *captchaReqAlert;
@property(nonatomic, retain) NSMutableString *dataString;
@property(nonatomic, retain) NSMutableData	*receivedData;

-(void)request;

-(void)authenticateWithUsername:(NSString *)un password:(NSString *)pw delegate:(id)authDelegate;
-(void)statuses_update:(NSString *)status title:(NSString *)title images:(NSArray *)images albumID:(NSString *)albumID delegate:(id)sendDelegate;

@end
