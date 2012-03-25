//
//  TwitlongerRequest.m
//  Monarch
//
//  Created by Joseph Constan on 3/15/11.
//  Copyright 2011 Timothy Rauh Jr. All rights reserved.
//

#import "TwitlongerRequest.h"


@implementation TwitlongerRequest

@synthesize delegate;

- (void)uploadStatus:(NSString *)status username:(NSString *)username {
	//send request with status to TwitLonger
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.twitlonger.com/api_post"]];
	[request setHTTPMethod:@"POST"];
	
	[request setHTTPBody:[[NSString stringWithFormat:@"application=monarchexpress&api_key=v5Mg8gVH5xpq1b1U&username=%@&message=%@",
						  [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
						  [status stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] dataUsingEncoding:NSUTF8StringEncoding]];
	[request addValue:[NSString stringWithFormat:@"%d", [[request HTTPBody] length]] forHTTPHeaderField:@"Content-Length"];
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	/*[request addValue:@"monarchexpress" forHTTPHeaderField:@"application"];
	[request addValue:@"v5Mg8gVH5xpq1b1U" forHTTPHeaderField:@"api_key"];
	[request addValue:username forHTTPHeaderField:@"username"];
	[request addValue:status forHTTPHeaderField:@"message"];*/

	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {	
	
	NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSLog(@"%@", response);

	if ([response rangeOfString:@"<content>"].location == NSNotFound) {
		[delegate addToSentList:TWITTER username:[[VariableStore sharedInstance] currentName] succeeded:NO];
	} else {
		NSString *content = [[[[response componentsSeparatedByString:@"<content>"] objectAtIndex:1] 
										 componentsSeparatedByString:@"</content>"] objectAtIndex:0];
		
		TwitterRequest *twitReq = [[TwitterRequest alloc] init];
		twitReq.username = [[VariableStore sharedInstance] currentName];
		twitReq.password = @"password";
		
		[twitReq statuses_update:content images:(NSArray *)[[VariableStore sharedInstance] images] requestDelegate:delegate];
		[twitReq release];
	}
	[response release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	//NSLog(@"didReceiveResponse: %@", [(NSHTTPURLResponse *)response statusCode]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"twitlonger connection didFinishLoading");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"connection failWithError: %@", error);
	[delegate addToSentList:TWITTER username:[[VariableStore sharedInstance] currentName] succeeded:NO];
}

@end
