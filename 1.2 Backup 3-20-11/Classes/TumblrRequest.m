//
//  TumblrRequest.m
//  Monarch
//
//  Created by Joseph Constan on 6/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TumblrRequest.h"


@implementation TumblrRequest

@synthesize username;
@synthesize password;
@synthesize delegate;


-(void)statuses_update:(NSString *)status title:(NSString *)title image:(UIImage *)image delegate:(id)requestDelegate
{
	NSLog(@"statuses_update");
	isPost = YES;
	// set the delegate and selector
	self.delegate = requestDelegate;
	// URL of the twitter request we intend to send
	if (!image) {
		requestBody = [[NSMutableString alloc] initWithFormat:@"email=%@&password=%@&body=%@",
					   [username     stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					   [password     stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					   [status			stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
		if (title) {
			[requestBody appendFormat:@"&title=%@", [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
		[requestBody appendString:@"&type=regular"];
	}
	else {
		isPost = NO;
		NSLog(@"has image");
		if ([UIImagePNGRepresentation(image) length] < 10000000) {
			theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.tumblr.com/api/write"]];
			
			NSString *stringBoundary = @"0xKhTmjy9WNdArY---This_Is_ThE_BoUnDaRyy---xbG";
			NSMutableData *postBody = [NSMutableData data];
			[theRequest setHTTPMethod:@"POST"];
			[theRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
			
			// encode username
			[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[username dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			
			// encode password
			[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			
			// encode message
			if ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] == @"" || 
					[status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] == @"") {
				[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
				[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"caption\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
				if ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] == @"" && 
					[status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] != @"") {	//title empty, status not
					[postBody appendData:[status dataUsingEncoding:NSUTF8StringEncoding]];
				}	
				else if ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] != @"" &&	//status empty, title not
						 [status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] == @"") {
					[postBody appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
				}
				else {
					[postBody appendData:[[NSString stringWithFormat:@"%@ - %@", title, status] dataUsingEncoding:NSUTF8StringEncoding]];
				}
				[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			}
			
			// encode media
			[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-Disposition: form-data; name=\"data\"; filename=\"image.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-Type: image/png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			
			// get the image data from the array directly into NSData object
			NSData *imageData = UIImagePNGRepresentation(image);
			
			// add it to body
			[postBody appendData:imageData];
			[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			
			// set post type to photo
			[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"type\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"photo" dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			
			// final boundary
			[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			
			// set body
			[theRequest setHTTPBody:postBody];
		}
		else {
			UIAlertView *largeImageAlert = [[UIAlertView alloc] initWithTitle:@"Image Too Large" message:@"Cannot send update - The image you attached is larger than 10 MB."
																	 delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[largeImageAlert dismissWithClickedButtonIndex:0 animated:YES];
			[largeImageAlert show];
			[largeImageAlert release];
		}
	}
	[self request];
}

-(void)request
{	
	if(isPost)
	{
		theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.tumblr.com/api/write"]];

		[theRequest setHTTPMethod:@"POST"];
		[theRequest setValue:@"application/x-www-form-urlencoded"
		  forHTTPHeaderField:@"Content-Type"];
		[theRequest setHTTPBody:[requestBody 
								 dataUsingEncoding:NSUTF8StringEncoding 
								 allowLossyConversion:YES]];
		[theRequest setValue:[NSString stringWithFormat:@"%d", 
							  [requestBody length] ] 
		  forHTTPHeaderField:@"Content-Length"];
	}
	
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest
													delegate:self];
	
	if(!theConnection) {
		//inform user post could not be made
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
        // inform the user that the user name and password
        // in the preferences are incorrect
		NSLog(@"Invalid Username or Password");
    }
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connection didReceiveResponse:%d - %@", [(NSHTTPURLResponse *)response statusCode], [(NSHTTPURLResponse *)response allHeaderFields]);
	if ([(NSHTTPURLResponse *)response statusCode] >= 200 && 
		[(NSHTTPURLResponse *)response statusCode] < 400) {	//did not succeed
		[delegate addToSentList:TUMBLR username:username succeeded:!sendDidFail];
	} else {
		sendDidFail = YES;
	}

}
/*
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	// append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    //[receivedData appendData:data];
}*/

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	[delegate addToSentList:TUMBLR username:username succeeded:NO];
	sendDidFail = NO;
    // release the connection, and the data object
    [connection release];
	[theRequest release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{	
	if (sendDidFail == YES) {
		[delegate addToSentList:TUMBLR username:username succeeded:NO];
	}
	sendDidFail = NO;
	// release the connection, and the data object
	[theConnection release];
	[theRequest release];
}

-(void) dealloc {
	[username release];
	[password release];
	[delegate release];
	[requestBody release];
	[super dealloc];
}

@end