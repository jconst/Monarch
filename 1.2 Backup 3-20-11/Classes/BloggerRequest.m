//
//  BloggerRequest.m
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BloggerRequest.h"
#import "ASIFormDataRequest.h"

@implementation BloggerRequest

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

-(void)statuses_update:(NSString *)status title:(NSString *)title blogID:(NSString *)blogID delegate:(id)sendDelegate
{	
	self.delegate = sendDelegate;
	imgTags = [[NSMutableString alloc] initWithString:@""];
	
	lastStatus = [[NSString alloc] initWithString:status];
	if (title) lastTitle = [[NSString alloc] initWithString:title];
	else lastTitle = [[NSString alloc] initWithString:@""];
	lastBlogID = [[NSString alloc] initWithString:blogID];
	
	if ([[[VariableStore sharedInstance] images] count] > 0) {
		for (int i = 0; i < [[[VariableStore sharedInstance] images] count]; i++) {
			
			ImgurRequest *imgurReq = [[ImgurRequest alloc] init];
			imgurReq.delegate = self;
			UIImage *image = [[[VariableStore sharedInstance] images] objectAtIndex:i];
			if (image.size.width > 400) {
				image = [image imageByScalingProportionallyToSize:CGSizeMake(400, ((400 / image.size.width) * image.size.height))];
			}
			[imgurReq getTagForImage:image];
		}
	} else {
		[self finishStatusUpdate];
	}
}

- (void)finishStatusUpdate {
	//finish the request now that we've got all the img tags (or never had any to acquire)
	
	theRequest = [[NSMutableURLRequest alloc] init];
	requestBody = [NSString stringWithFormat:@"<entry xmlns='http://www.w3.org/2005/Atom'><title type='text'>%@</title><content type='xhtml'><div xmlns=\"http://www.w3.org/1999/xhtml\"><p>%@</p>%@</div></content></entry>",
				   lastTitle, [lastStatus stringByReplacingOccurrencesOfString:@"\n" withString:@"</p><p>"], imgTags];
	NSLog(@"requestBody: %@", requestBody);
	
	[theRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.blogger.com/feeds/%@/posts/default", lastBlogID]]];
	[theRequest setHTTPMethod:@"POST"];
	
	NSString *authString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"BLOGAUTH%@", username]]];
	authString = [authString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[theRequest setValue:authString forHTTPHeaderField:@"Authorization"];
	
	
	
	[theRequest setValue:@"application/atom+xml" forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPBody:[requestBody 
							 dataUsingEncoding:NSASCIIStringEncoding 
							 allowLossyConversion:YES]];
	[theRequest setValue:[NSString stringWithFormat:@"%d", 
						  [requestBody length]] 
	  forHTTPHeaderField:@"Content-Length"];
	
	[self request];
}

- (void)imgurRequest:(ImgurRequest *)imgurReq didReturnTag:(NSString *)tag {
	NSLog(@"requestFinished:%@", tag);
	
	if (tag.length > 0) {
		[imgTags appendFormat:@"<p>%@</p>", tag];
		tagsReceived++;
	} else {
		if ([delegate respondsToSelector:@selector(addToSentList:username:succeeded:)]) {
			[delegate addToSentList:BLOGGER username:username succeeded:NO];
		}
	}
	[imgurReq release];
	if (tagsReceived >= [[[VariableStore sharedInstance] images] count]) {
		[self finishStatusUpdate];
	}
}

-(void)getBlogList
{
	NSLog(@"getBlogList");
	isGettingList = YES;
	
	theRequest = [[NSMutableURLRequest alloc] init];
	[theRequest setURL:[NSURL URLWithString:@"http://www.blogger.com/feeds/default/blogs"]];
	[theRequest setHTTPMethod:@"GET"];
	
	NSString *authString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"BLOGAUTH%@", username]]];
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
	requestBody = [NSString stringWithFormat:@"Email=%@&Passwd=%@&service=blogger&accountType=HOSTED_OR_GOOGLE&source=DCDev-MonarchForiPad-1", un, pw];
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
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSUInteger statCode = [(NSHTTPURLResponse *)response statusCode];
	NSLog(@"connection didReceiveResponse:%d, %@", statCode, [(NSHTTPURLResponse *)response allHeaderFields]);
	if (isGettingList && statCode == 200) {
		isGettingList = NO;
		didReceiveList = YES;
	}
	if (statCode == 401 && renewedToken == NO) {	//auth token expired
		renewedToken = YES;
		[self authenticateWithUsername:username password:password delegate:delegate];
	}
	else if (statCode == 200 && renewedToken == YES) {
		[self statuses_update:lastStatus title:lastTitle blogID:lastBlogID delegate:delegate];
		renewedToken = NO;
	}	
	else if (statCode != 200) {
		if (statCode == 201) NSLog(@"stat 201 rec");
		[delegate addToSentList:BLOGGER username:username succeeded:(statCode == 201)];
	}

    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    //[receivedData setLength:0];
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
						 forKey:[NSString stringWithFormat:@"BLOGAUTH%@", username]];
			
			[self getBlogList];
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
		[delegate addToSentList:BLOGGER username:username succeeded:NO];
	}
	else if ([error code] == -1009) {
		UIAlertView *noInternetAlert = [[UIAlertView alloc] 
										initWithTitle:@"No Internet Connection" 
										message:@"You require an internet connection via WiFi or cellular network to connect to Blogger." 
										delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noInternetAlert show];
	}
	[connection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
	NSLog(@"ConnectionDidFinishLoading");
	NSLog(@"receivedData = %@", receivedData);
	if (didReceiveList) {
		[delegate performSelector:@selector(parseBlogList:) withObject:(receivedData)];
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
