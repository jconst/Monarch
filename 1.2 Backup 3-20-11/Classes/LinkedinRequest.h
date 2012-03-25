//
//  LinkedinRequest.h
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VariableStore.h"

#define LinkedinAccessKey clOKFoyLyuPdpz15W78XEvpiVDVG1CD08UcA_tMFPvxd_vIw-ptOMEsSDU7QJrqq
#define LinkedinAccessSecret ZhVy2tdkkUGmgnHv5-IEQaCUo0rbxAnxaluigYlSbCoffLjk9XEzGokHWPfeBfcY


@interface LinkedinRequest : NSObject {
	id				delegate;
	NSString	*username;
	OAToken		*requestToken;
	OAToken		*accessToken;
	NSString		*pin;
	BOOL		sendDidFail;
}

@property (nonatomic, assign) id	delegate;
@property (nonatomic, retain) NSString *pin;
@property (nonatomic, retain) OAToken *requestToken;
@property (nonatomic, retain) OAToken *accessToken;
@property (nonatomic, retain) NSString	*username;

//-(void)friends_timeline:(id)requestDelegate requestSelector:(SEL)requestSelector;
- (void) statuses_update:(NSString *)status delegate:(id)requestDelegate;
- (void) getRequestToken;
- (void) getAccessToken;
- (void) getUserName;

//delegate methods
- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void) requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void) accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void) accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void) getUserName:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void) getUserName:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

@end
