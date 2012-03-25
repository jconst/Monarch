//
//  FoursquareRequest.m
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "FoursquareRequest.h"


@implementation FoursquareRequest

@synthesize username;
@synthesize password;
@synthesize receivedData;
@synthesize delegate;
@synthesize clm;
		
-(void)statuses_update:(NSString *)status delegate:(id)requestDelegate requestSelector:(SEL)requestSelector
{
	// set the delegate and status
	NSLog(@"sending update");
	lastStatus = status;
	self.delegate = requestDelegate;
	
	isPost = YES;
	sendDidFail = NO;
	NSURL *url;
	if (![[NSUserDefaults standardUserDefaults] integerForKey:@"MonarchFoursquarePostType"]) {	//post type not set
		[[NSUserDefaults standardUserDefaults] setInteger:SHOUTNOLOC forKey:@"MonarchFoursquarePostType"];
	}
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"MonarchFoursquareVenueID"] &&		//no venue selected
		([[NSUserDefaults standardUserDefaults] integerForKey:@"MonarchFoursquarePostType"] != 1 || //when there should be
		[[NSUserDefaults standardUserDefaults] integerForKey:@"MonarchFoursquarePostType"] != 2)) {	
			[[NSUserDefaults standardUserDefaults] setInteger:SHOUTNOLOC forKey:@"MonarchFoursquarePostType"];
	}
	switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"MonarchFoursquarePostType"]) {
		case SHOUTNOLOC:
			url = [NSURL URLWithString:@"http://api.foursquare.com/v1/checkin.json"];
			requestBody = [NSString stringWithFormat:@"shout=%@", lastStatus];
			break;
		case VENUECHECKIN:
			url = [NSURL URLWithString:@"http://api.foursquare.com/v1/checkin.json"];
			requestBody = [NSString stringWithFormat:@"shout=%@&vid=%@", 
							lastStatus, [[NSUserDefaults standardUserDefaults] objectForKey:@"MonarchFoursquareVenueID"]];
			break;
		case VENUETIP:
			url = [NSURL URLWithString:@"http://api.foursquare.com/v1/addtip.json"];
			requestBody = [NSString stringWithFormat:@"vid=%@&text=%@&type=tip", [[NSUserDefaults standardUserDefaults] objectForKey:@"MonarchFoursquareVenueID"], lastStatus];
			break;
		case VENUETODO:
			url = [NSURL URLWithString:@"http://api.foursquare.com/v1/addtip.json"];
			requestBody = [NSString stringWithFormat:@"vid=%@&text=%@&type=todo", [[NSUserDefaults standardUserDefaults] objectForKey:@"MonarchFoursquareVenueID"], lastStatus];
			break;
		default:
			NSLog(@"Unexpected value for MonarchFoursquarePostType");
			break;
	}
	[self request:url];
}

-(void)request:(NSURL *)url
{
	NSString *authString = [[[NSString alloc] init] autorelease];
	NSData *authData = [[[NSData alloc] init] autorelease];
	theRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	
	authString = [NSString stringWithFormat:@"%@:%@", username, password];
	authData = [authString dataUsingEncoding:NSASCIIStringEncoding];
	authString = [authData base64EncodedString];
	
	if(isPost)
	{
		[theRequest setHTTPMethod:@"POST"];
		[theRequest setValue:@"application/x-www-form-urlencoded"
		  forHTTPHeaderField:@"Content-Type"];
		[theRequest setHTTPBody:[requestBody 
					dataUsingEncoding:NSASCIIStringEncoding 
					allowLossyConversion:NO]];
		[theRequest setValue:[NSString stringWithFormat:@"%d", 
					[requestBody length] ] 
					forHTTPHeaderField:@"Content-Length"];
		isPost = NO;
	}
	[theRequest setValue:@"Monarch-iPad:1.0" forHTTPHeaderField:@"User-Agent"];
	[theRequest setValue:[NSString stringWithFormat:@"Basic %@", authString]
	  forHTTPHeaderField:@"Authorization"];
	
	NSLog(@"%@, body = %@, headers = %@", theRequest, [[[NSString alloc] initWithData:[theRequest HTTPBody] encoding:NSUTF8StringEncoding] autorelease], [theRequest allHTTPHeaderFields]);
	
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest
													delegate:self];
	
	if(theConnection) {
		receivedData=[[NSMutableData data] retain];
	} else {
		NSLog(@"!theConnection");
	}
}

/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[[NSUserDefaults standardUserDefaults] setInteger:SHOUTNOLOC forKey:@"MonarchFoursquarePostType"];
		[self statuses_update:lastStatus delegate:delegate requestSelector:nil];
	}
	[alertView removeFromSuperview];
	[alertView release];
}*/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connection didReceiveResponse:%d", [(NSHTTPURLResponse *)response statusCode]);
	if ([(NSHTTPURLResponse *)response statusCode] != 200) {	//did not succeed
		sendDidFail = YES;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	// append the new data to the receivedData
    [receivedData appendData:data];
	NSLog(@"%@", data);
	NSString *ds = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if ([ds rangeOfString:@"authentication failed"].location != NSNotFound) {
		NSLog(@"Foursquare Authentication Failed");
		sendDidFail = YES;
	}
	[ds release];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	[delegate addToSentList:FOURSQUARE username:username succeeded:NO];
	sendDidFail = NO;
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
	[theRequest release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[delegate addToSentList:FOURSQUARE username:username succeeded:!sendDidFail];
	sendDidFail = NO;
	
	// release the connection, and the data object
	[theConnection release];
    [receivedData release];
	[theRequest release];
}

-(void) dealloc {
	[username release];
	[password release];
	[delegate release];
	[super dealloc];
}

@end
