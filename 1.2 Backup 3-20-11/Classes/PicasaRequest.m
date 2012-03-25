//
//  PicasaRequest.m
//  Monarch
//
//  Created by Joseph Constan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PicasaRequest.h"


@implementation PicasaRequest

@synthesize username;
@synthesize password;
@synthesize delegate;
@synthesize captchaReqAlert, dataString, receivedData;


-(id)init
{
	authenticating = NO;
	isGettingList = NO;
	[super init];
	receivedData = [[NSMutableData alloc] init];
	return self;
}

-(void)statuses_update:(NSString *)status title:(NSString *)title images:(NSArray *)images albumID:(NSString *)albumID delegate:(id)sendDelegate
{	
	self.delegate = sendDelegate;
	NSString *strippedAlbumID = [[albumID componentsSeparatedByString:@"albumid/"] objectAtIndex:1];
	if ([albumID length] > 0) {
		theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://picasaweb.google.com/data/feed/api/user/default/albumid/%@", strippedAlbumID]]
												  cachePolicy:NSURLRequestUseProtocolCachePolicy
											  timeoutInterval:30.0];
	} else {
		theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://picasaweb.google.com/data/feed/api/user/default/albumid/default"]
												  cachePolicy:NSURLRequestUseProtocolCachePolicy
											  timeoutInterval:30.0];
	}
	NSString *stringBoundary = @"0xKhTm9jyQNdArY---This_Is_ThE_BoUnDaRyy---pqo";
	NSMutableData *postBody = [NSMutableData data];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:[NSString stringWithFormat:@"multipart/related; boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
	
	// encode metadata
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Type: application/atom+xml\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:
	@"<entry xmlns='http://www.w3.org/2005/Atom'><title>%@.jpg</title><summary>%@</summary><category scheme=\"http://schemas.google.com/g/2005#kind\" term=\"http://schemas.google.com/photos/2007#photo\"/></entry>",
						   title, status] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	// encode media
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: image/png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	// get the image data from the array directly into NSData object
	NSData *imageData = UIImagePNGRepresentation([images objectAtIndex:0]);
	
	// add it to body
	[postBody appendData:imageData];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	// final boundary
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// set body
	[theRequest setHTTPBody:postBody];

	NSString *authString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"PICASAAUTH%@", username]]];
	authString = [authString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[theRequest setValue:authString forHTTPHeaderField:@"Authorization"];
	
	lastStatus = [[NSString alloc] initWithString:status];
	if (title) lastTitle = [[NSString alloc] initWithString:title];
	lastBlogID = [[NSString alloc] initWithString:albumID];
	
	[theRequest setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-Length"];
		
	[self request];
}

-(void)getAlbumList
{
	NSLog(@"getBlogList");
	isGettingList = YES;
	
	theRequest = [[NSMutableURLRequest alloc] init];
	[theRequest setURL:[NSURL URLWithString:@"http://picasaweb.google.com/data/feed/api/user/default"]];
	[theRequest setHTTPMethod:@"GET"];
	
	NSString *authString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"PICASAAUTH%@", username]]];
	authString = [authString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[theRequest setValue:authString forHTTPHeaderField:@"Authorization"];
	
	[self request];
}

-(void)authenticateWithUsername:(NSString *)un password:(NSString *)pw delegate:(id)authDelegate
{
	authenticating = YES;
	theRequest = [[NSMutableURLRequest alloc] init];
	
	[theRequest setURL:[NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"]];
	
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"application/x-www-form-urlencoded"
	  forHTTPHeaderField:@"Content-Type"];
	requestBody = [NSString stringWithFormat:@"Email=%@&Passwd=%@&service=lh2&accountType=HOSTED_OR_GOOGLE&source=DCDev-MonarchForiPad-1", un, pw];
	[theRequest setHTTPBody:[requestBody 
							 dataUsingEncoding:NSASCIIStringEncoding 
							 allowLossyConversion:YES]];
	[theRequest setValue:[NSString stringWithFormat:@"%d", 
						  [requestBody length]]
	  forHTTPHeaderField:@"Content-Length"];
	username = un;
	password = pw;
	self.delegate = authDelegate;
	[self request];
}

-(void)request
{
	[theRequest setValue:@"2" forHTTPHeaderField:@"GData-Version"];
	
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest
													delegate:self];
	if(!theConnection) {
		NSLog(@"!theConnection");
	}
	[theRequest release];
}
/*
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"challenged %@",[challenge proposedCredential] );
	
	if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential=[NSURLCredential credentialWithUser:[self username]
                                                 password:[self password]
                                              persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential
               forAuthenticationChallenge:challenge];
		
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        // inform the user that the user name and password
        // in the preferences are incorrect
		NSLog(@"Invalid Username or Password");
    }
}*/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSUInteger statCode = [(NSHTTPURLResponse *)response statusCode];
	NSLog(@"connection didReceiveResponse:%d, %@", statCode, [(NSHTTPURLResponse *)response allHeaderFields]);
	if (isGettingList && statCode == 200) {
		isGettingList = NO;
		didReceiveList = YES;
	}
	else if (statCode == 401 && renewedToken == NO) {	//auth token expired
		renewedToken = YES;
		[self authenticateWithUsername:username password:password delegate:delegate];
	}
	else if (statCode == 200 && renewedToken == YES) {	//successfully renewed token, resend message
		[self statuses_update:lastStatus title:lastTitle images:[[VariableStore sharedInstance] images] albumID:lastBlogID delegate:delegate];
		renewedToken = NO;
	}	
	else if (statCode != 200 && [delegate respondsToSelector:@selector(addToSentList:username:succeeded:)]) {	//request is not for token renewal
		[delegate addToSentList:PICASA username:username succeeded:(statCode == 201)];					//succeeded or not based on if statCode == 201
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {	
	if (authenticating) {
		NSString *tempString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		dataString = [[NSMutableString alloc] initWithCapacity:[tempString length]];
		[dataString setString:tempString];
		[tempString release];
		
		if ([(NSString *)dataString rangeOfString:@"Auth="].location == NSNotFound) {	//Authentication failed
			NSLog(@"%@",dataString);
			
			if ([(NSString *)dataString rangeOfString:@"Error=BadAuthentication"].location != NSNotFound) {
				//user entered incorrect username / password
				UIAlertView *badAuthAlert = [[UIAlertView alloc] initWithTitle:@"Bad Authentication" 
																	   message:@"The username or password you entered is incorrect. Try re-entering your account information."
																	  delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
				
				[badAuthAlert show];
				[badAuthAlert release];
			}
			else if ([(NSString *)dataString rangeOfString:@"Error=CaptchaRequired"].location != NSNotFound) {
				//handle captcha request
				captchaReqAlert = [[UIAlertView alloc] initWithTitle:@"Captcha Required" 
															 message:@"Google's login service is requesting you answer a Captcha form. Press \"Go\" to be redirected to their form or \"Cancel\" to try re-entering your account information"
															delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go", nil];
				NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:2];
				[dataArray setArray:[(NSString *)dataString componentsSeparatedByString:@"CaptchaUrl="]];
				[dataString setString:[dataArray objectAtIndex:1]];
				[dataArray setArray:[(NSString *)dataString componentsSeparatedByString:@"Error="]];
				[dataString setString:[dataArray objectAtIndex:0]];
				
				[captchaReqAlert show];
				[captchaReqAlert release];
				[dataArray release];
			}
		} else {
			[[NSUserDefaults standardUserDefaults] setObject:[[(NSString *)dataString componentsSeparatedByString:@"Auth="] objectAtIndex:1] 
													  forKey:[NSString stringWithFormat:@"PICASAAUTH%@", username]];
			
			[self getAlbumList];
		}
		authenticating = NO;
	}
	else if (didReceiveList) {
		NSLog(@"appending data");
		[receivedData appendData:data];
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"alertView: ClickedButtonatindex");
	if (alertView == captchaReqAlert && buttonIndex == 1) { //user pressed go
		NSLog(@"%@", dataString);
		[dataString setString:[NSString stringWithFormat:@"http://www.google.com/accounts/%@", dataString]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:(NSString *)dataString]];
	}
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{		
    NSLog(@"Connection failed! Error - %d %@",
          [error code],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	if ([delegate respondsToSelector:@selector(addToSentList:username:succeeded:)]) {
		[delegate addToSentList:PICASA username:username succeeded:NO];
	}
	else if ([error code] == -1009) {
		UIAlertView *noInternetAlert = [[UIAlertView alloc] 
										initWithTitle:@"No Internet Connection" 
											  message:@"You require an internet connection via WiFi or cellular network to connect to Picasa." 
											 delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noInternetAlert show];
	}
	[connection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
	NSLog(@"ConnectionDidFinishLoading");
	if (didReceiveList) {
		[delegate performSelector:@selector(parseAlbumList:forUsername:) withObject:receivedData withObject:username];
		didReceiveList = NO;
		[receivedData setData:nil];
	}
	[connection release];
}

-(void) dealloc {
	//[username release];
	//[password release];
	[delegate release];
	[receivedData release];
	
	[lastStatus release];
	[lastTitle release];
	[lastBlogID release];
	
	[super dealloc];
}

@end