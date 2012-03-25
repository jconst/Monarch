//
//  LinkedinRequest.m
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "LinkedinRequest.h"


@implementation LinkedinRequest

//@synthesize receivedData;
@synthesize delegate, pin, requestToken, accessToken, username;


-(void)statuses_update:(NSString *)status delegate:(id)requestDelegate
{
	self.delegate = requestDelegate;
	NSString *bodyString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><current-status>%@</current-status>", status];
	accessToken = [[OAToken alloc] initWithKey:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"MonarchLinkedinAccessKey%@", username]]
										secret:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"MonarchLinkedinAccessSecret%@", username]]];

	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"clOKFoyLyuPdpz15W78XEvpiVDVG1CD08UcA_tMFPvxd_vIw-ptOMEsSDU7QJrqq"
													 secret:@"ZhVy2tdkkUGmgnHv5-IEQaCUo0rbxAnxaluigYlSbCoffLjk9XEzGokHWPfeBfcY"];
	
	NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/current-status"];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																	consumer:consumer
																	   token:accessToken
																	   realm:nil
														   signatureProvider:nil];
	[request setHTTPMethod:@"PUT"];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%d", [bodyString length]] forHTTPHeaderField:@"Content-Length"];
	[request prepare];
	[request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];

	NSLog(@"%@", [request allHTTPHeaderFields]);
	sendDidFail = NO;
	NSURLConnection *updateConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	[updateConnection start];
	//[request autorelease];
}

-(void)getUserName
{
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"clOKFoyLyuPdpz15W78XEvpiVDVG1CD08UcA_tMFPvxd_vIw-ptOMEsSDU7QJrqq"
													 secret:@"ZhVy2tdkkUGmgnHv5-IEQaCUo0rbxAnxaluigYlSbCoffLjk9XEzGokHWPfeBfcY"] autorelease];
	
	NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~"];
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil] autorelease];
        
	[request prepare];
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(getUserName:didFinishWithData:)
                  didFailSelector:@selector(getUserName:didFailWithError:)];
}
	
-(void)getAccessToken
{
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"clOKFoyLyuPdpz15W78XEvpiVDVG1CD08UcA_tMFPvxd_vIw-ptOMEsSDU7QJrqq"
                                                    secret:@"ZhVy2tdkkUGmgnHv5-IEQaCUo0rbxAnxaluigYlSbCoffLjk9XEzGokHWPfeBfcY"] autorelease];
	
    NSURL *url = [NSURL URLWithString:@"https://api.linkedin.com/uas/oauth/accessToken"];
	
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
																	consumer:consumer
																	   token:requestToken 
																	   realm:nil   // our service provider doesn't specify a realm
														   signatureProvider:nil]  // use the default method, HMAC-SHA1
																	autorelease];
	
	[request setHTTPMethod:@"POST"];

	OARequestParameter *pinParam = [[OARequestParameter alloc] initWithName:@"oauth_verifier"
																	  value:pin];
	
    NSArray *params = [NSArray arrayWithObject:pinParam];
    [request setParameters:params];
		
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
}

-(void)getRequestToken
{
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"clOKFoyLyuPdpz15W78XEvpiVDVG1CD08UcA_tMFPvxd_vIw-ptOMEsSDU7QJrqq"
                                                    secret:@"ZhVy2tdkkUGmgnHv5-IEQaCUo0rbxAnxaluigYlSbCoffLjk9XEzGokHWPfeBfcY"] autorelease];
	
    NSURL *url = [NSURL URLWithString:@"https://api.linkedin.com/uas/oauth/requestToken"];
	
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]  // use the default method, HMAC-SHA1
																	autorelease];
	
    [request setHTTPMethod:@"POST"];
	
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

#pragma mark -
#pragma mark delegate methods

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSLog(@"requestTokenTicketDidFinishWithData:%@", [[[NSString alloc] initWithData:data
																		   encoding:NSUTF8StringEncoding] autorelease]);
	if (ticket.didSucceed) {
		NSString *responseBody = [[[NSString alloc] initWithData:data
														encoding:NSUTF8StringEncoding] autorelease];
		requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		[delegate setLinkedinRequestToken:requestToken];
		[delegate openLinkedinWebViewWithData:data];
	}
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Linkedin oauth request failed with error: %@", error);
	UIAlertView *accessFailedAlert = [[[UIAlertView alloc] initWithTitle:@"Token Request Failed" 
																 message:@"Couldn't reach the Linkedin API. Check your internet connection"
																delegate:nil
													   cancelButtonTitle:@"OK" 
													   otherButtonTitles:nil] autorelease];
	[accessFailedAlert show];
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSLog(@"accessTokenTicketDidFinishWithData:%@", [[[NSString alloc] initWithData:data
																		   encoding:NSUTF8StringEncoding] autorelease]);
	if (ticket.didSucceed) {
		NSLog(@"did succeed");
		NSString *responseBody = [[[NSString alloc] initWithData:data
														encoding:NSUTF8StringEncoding] autorelease];
		accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		//accessToken.pin = pin;
		[self getUserName];
	}
}

- (void) accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Linkedin oauth access token request failed with error: %@", error);
	UIAlertView *accessFailedAlert = [[[UIAlertView alloc] initWithTitle:@"Access Request Failed" 
																message:@"Monarch's request to access Linkedin failed. Try re-entering the pin code."
															   delegate:nil
													  cancelButtonTitle:@"OK" 
													  otherButtonTitles:nil] autorelease];
	[accessFailedAlert show];
	[requestToken release];
	[pin release];
}

- (void)getUserName:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSString *firstName = [[[[dataString componentsSeparatedByString:@"<first-name>"] objectAtIndex:1] 
											 componentsSeparatedByString:@"</first-name>"] objectAtIndex:0];
		NSString *lastName = [[[[dataString componentsSeparatedByString:@"<last-name>"] objectAtIndex:1] 
								componentsSeparatedByString:@"</last-name>"] objectAtIndex:0];
		NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
		
		AccountInfo *currentInfo = [[AccountInfo alloc] init];
		currentInfo.username = fullName;
		currentInfo.password = @"password";
		currentInfo.siteType = LINKEDIN;
		
		// save access token
		[[NSUserDefaults standardUserDefaults] setObject:accessToken.key forKey:[NSString stringWithFormat:@"MonarchLinkedinAccessKey%@", fullName]];
		[[NSUserDefaults standardUserDefaults] setObject:accessToken.secret forKey:[NSString stringWithFormat:@"MonarchLinkedinAccessSecret%@", fullName]];
		
		[[[VariableStore sharedInstance] accounts] addObject:currentInfo];
		[[[[[delegate navigationController] viewControllers] objectAtIndex:0] tableView] reloadData];
		
		[[delegate navigationController] popToRootViewControllerAnimated:YES];
		[dataString release];
	}
	[accessToken release];
	[requestToken release];
	[pin release];
}

- (void) getUserName:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Linkedin get username request failed with error: %@", error);
	UIAlertView *accessFailedAlert = [[[UIAlertView alloc] initWithTitle:@"Access Request Failed" 
																 message:@"Monarch's request to access Linkedin failed. Try re-entering the pin code."
																delegate:nil
													   cancelButtonTitle:@"OK" 
													   otherButtonTitles:nil] autorelease];
	[accessFailedAlert show];
	[accessToken release];
	[requestToken release];
	[pin release];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connection didReceiveResponse:%@, %d", response, [(NSHTTPURLResponse *)response statusCode]);
	if ([(NSHTTPURLResponse *)response statusCode] < 400) {
		sendDidFail = NO;
	} else {
		sendDidFail = YES;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	[delegate addToSentList:LINKEDIN username:username succeeded:NO];
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"linkedin connection did finish loading");
	[delegate addToSentList:LINKEDIN username:username succeeded:(!sendDidFail)];
}

-(void) dealloc {
	[super dealloc];
}

@end
