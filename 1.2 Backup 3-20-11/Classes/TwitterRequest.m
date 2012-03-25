//
//  TwitterRequest.m
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "TwitterRequest.h"


@implementation TwitterRequest

@synthesize username;
@synthesize password;
//@synthesize receivedData;
@synthesize delegate, twitPicEngine;

/*-(void)friends_timeline:(id)requestDelegate requestSelector:(SEL)requestSelector
{
	//set the delegate and selector
	self.delegate = requestDelegate;
	self.callback = requestSelector;
	//URL of the Twitter Request we want to send
	NSURL *url = [NSURL URLWithString:@"http://twitter.com/statuses/friends_timeline.xml"];
	[self request:url];
}*/
	
-(id)init
{
	/*clm = [[CLLocationManager alloc] init];
	clm.purpose = @"Monarch requires your location for use of Foursquare services";
	if ([clm locationServicesEnabled]) {
		[clm startUpdatingLocation];
	}*/
	[super init];
	return self;
}

-(void)statuses_update:(NSString *)status images:(NSArray *)images requestDelegate:(id)requestDelegate
{
	self.delegate = requestDelegate;

	if ([images count] > 0) {
		/*theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://twitpic.com/api/uploadAndPost"]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:30.0];
		NSString *stringBoundary = @"0xKhTmjy9WNdArY---This_Is_ThE_BoUnDaRyy---pqo";
		NSMutableData *postBody = [NSMutableData data];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
				
		// encode username
		[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[username dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		
		// encode password
		[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		
		// encode message
		[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"message\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[status dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		
		// encode media
		[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[@"Content-Disposition: form-data; name=\"media\"; filename=\"image.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
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
		[theRequest setHTTPBody:postBody];*/
		
		MonarchAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		
		twitPicEngine = [GSTwitPicEngine twitpicEngineWithDelegate:[appDelegate detailViewController]];
		[twitPicEngine setAccessToken:[[[VariableStore sharedInstance] twitterEngine] _accessToken]];
		[twitPicEngine uploadPicture:[images objectAtIndex:0] withMessage:status]; 
	}
	else {
//		theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://twitter.com/statuses/update.xml"]];
//		requestBody = [NSString stringWithFormat:@"status=%@", status];
//		[theRequest setHTTPMethod:@"POST"];
//		[theRequest setHTTPBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
//		[theRequest setValue:@"application/x-www-form-urlencoded"					 forHTTPHeaderField:@"Content-Type"];
//		[theRequest setValue:[NSString stringWithFormat:@"%d", [requestBody length]] forHTTPHeaderField:@"Content-Length"];
//		[self request];
		if (status.length > 140) {
			TwitlongerRequest *tlReq = [[TwitlongerRequest alloc] init];
			tlReq.delegate = [(MonarchAppDelegate *)[[UIApplication sharedApplication] delegate] detailViewController];
			[tlReq uploadStatus:status username:username];
		} else {
			NSLog(@"Sending to twitter (no image)");
			NSString *accessKey = [[NSUserDefaults standardUserDefaults] objectForKey:
								   [NSString stringWithFormat:@"MonarchTwitterAccessKey%@", username]];
			NSString *accessSecret = [[NSUserDefaults standardUserDefaults] objectForKey:
									  [NSString stringWithFormat:@"MonarchTwitterAccessSecret%@", username]];
			[VariableStore sharedInstance].twitterEngine._accessToken = [[OAToken alloc] initWithKey:accessKey secret:accessSecret];
			[[VariableStore sharedInstance].twitterEngine sendUpdate:status];
			[VariableStore sharedInstance].twitterEngine.delegate = self.delegate;
			[[VariableStore sharedInstance].currentName release];
		}
	}
}
/*
-(void)request
{
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest
													delegate:self];
	
	if(theConnection) {
		//receivedData=[[NSMutableData data] retain];
	} else {
		//inform user download could not be made
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	//NSLog(@"challenged %@",[challenge proposedCredential] );
	
	if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential=[NSURLCredential credentialWithUser:[self username]
                                                 password:[self password]
                                              persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential
               forAuthenticationChallenge:challenge];
		
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        sendDidFail = YES;
		NSLog(@"Invalid Username or Password");
    }
}
 
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
// append the new data to the receivedData
// receivedData is declared as a method instance elsewhere
//[receivedData appendData:data];
}
 
*/
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connection didReceiveResponse:%d", [(NSHTTPURLResponse *)response statusCode]);
	if ([(NSHTTPURLResponse *)response statusCode] != 200) {	//did not succeed
		sendDidFail = YES;
	}
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	[delegate addToSentList:TWITTER username:username succeeded:NO];
	sendDidFail = NO;
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    //[receivedData release];
	
	[theRequest release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"twitter connection did finish loading");
	[delegate addToSentList:TWITTER username:username succeeded:!sendDidFail];
	sendDidFail = NO;
	
	// release the connection, and the data object
	[theConnection release];
    //[receivedData release];
	[theRequest release];
}

- (void)twitpicDidFinishUpload:(NSString *)response {

}

- (void)twitpicDidFailUpload:(NSString *)error {
	
}

-(void) dealloc {
	[username release];
	[password release];
	[delegate release];
	[super dealloc];
}

@end
