//
//  BloggerRequest.h
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountInfo.h"

@interface BloggerRequest : NSObject <UIAlertViewDelegate> {
	id				delegate;
	NSString		*username;
	NSString		*password;
	NSMutableURLRequest	*theRequest;
	NSURLConnection *theConnection;
	UIAlertView		*captchaReqAlert;
	
	NSMutableData	*receivedData;
	NSMutableString	*dataString;
	NSString		*requestBody;
	NSMutableString *imgTags;
	
	NSString *lastStatus;
	NSString *lastTitle;
	NSString *lastBlogID;
	
	NSUInteger		tagsReceived;
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

- (void)request;
- (void)finishStatusUpdate;
- (void)authenticateWithUsername:(NSString *)un password:(NSString *)pw delegate:(id)authDelegate;
- (void)statuses_update:(NSString *)status title:(NSString *)title blogID:(NSString *)blogID delegate:(id)sendDelegate;

@end
