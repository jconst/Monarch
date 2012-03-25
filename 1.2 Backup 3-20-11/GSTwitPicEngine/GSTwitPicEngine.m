//
//  GSTwitPicEngine.m
//  TwitPic Uploader
//
//  Created by Gurpartap Singh on 19/06/10.
//  Copyright 2010 Gurpartap Singh. All rights reserved.
//

#import "GSTwitPicEngine.h"

#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"

#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OAPlaintextSignatureProvider.h"
#import "VariableStore.h"


@implementation GSTwitPicEngine

@synthesize _queue;

+ (GSTwitPicEngine *)twitpicEngineWithDelegate:(NSObject *)theDelegate {
  return [[[self alloc] initWithDelegate:theDelegate] autorelease];
}


- (GSTwitPicEngine *)initWithDelegate:(NSObject *)delegate {
  if (self = [super init]) {
    _delegate = delegate;
    _queue = [[ASINetworkQueue alloc] init];
    [_queue setMaxConcurrentOperationCount:1];
    [_queue setShouldCancelAllRequestsOnFailure:NO];
    [_queue setDelegate:self];
    [_queue setRequestDidFinishSelector:@selector(requestFinished:)];
    [_queue setRequestDidFailSelector:@selector(requestFailed:)];
    // [_queue setQueueDidFinishSelector:@selector(queueFinished:)];
  }
  
  return self;
}


- (void)dealloc {
  _delegate = nil;
  [_queue release];
  [super dealloc];
}


#pragma mark -
#pragma mark Instance methods

- (BOOL)_isValidDelegateForSelector:(SEL)selector {
	return ((_delegate != nil) && [_delegate respondsToSelector:selector]);
}


- (void)uploadPicture:(UIImage *)picture {
  [self uploadPicture:picture withMessage:@""];
}


- (void)uploadPicture:(UIImage *)picture withMessage:(NSString *)message {
  if ([TWITPIC_API_VERSION isEqualToString:@"1"]) {
    // TwitPic OAuth.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitpic.com/1/upload.%@", TWITPIC_API_FORMAT]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	  request.isTwitterRequest = YES;
	  
    [request addPostValue:@"96da45e865a6c36c7d347b4402516e85" forKey:@"key"];
    [request addPostValue:@"XbUEQq5mLNCrZNZU0coCOA" forKey:@"consumer_token"];
    [request addPostValue:@"N7S3JxRWSg1eefJHvN8lt7bZUGJ3cn68x4yuN9RN7c" forKey:@"consumer_secret"];
    [request addPostValue:[_accessToken key] forKey:@"oauth_token"];
    [request addPostValue:[_accessToken secret] forKey:@"oauth_secret"];
    [request addPostValue:message forKey:@"message"];
    [request addData:UIImageJPEGRepresentation(picture, 0.8) forKey:@"media"];
    
    request.requestMethod = @"POST";
    
    [_queue addOperation:request];
    [_queue go];
  }
  else {
    // Twitter OAuth Echo.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitpic.com/2/upload.%@", TWITPIC_API_FORMAT]];
    
	//use a dummy OARequest to generate the necesssary header
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"XbUEQq5mLNCrZNZU0coCOA" 
													 secret:@"N7S3JxRWSg1eefJHvN8lt7bZUGJ3cn68x4yuN9RN7c"] autorelease];
        
	  NSString *accessKey = [[NSUserDefaults standardUserDefaults] objectForKey:
							 [NSString stringWithFormat:@"MonarchTwitterAccessKey%@", 
							  [[VariableStore sharedInstance] currentName]]];
	  NSString *accessSecret = [[NSUserDefaults standardUserDefaults] objectForKey:
								[NSString stringWithFormat:@"MonarchTwitterAccessSecret%@", 
								 [[VariableStore sharedInstance] currentName]]];
	  _accessToken = [[OAToken alloc] initWithKey:accessKey secret:accessSecret];
	  [VariableStore sharedInstance].twitterEngine._accessToken = [[OAToken alloc] initWithKey:accessKey secret:accessSecret];
	  [VariableStore sharedInstance].twitterEngine.delegate = [[[UIApplication sharedApplication] delegate] detailViewController];
	  
	  OAMutableURLRequest *theRequest = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/account/verify_credentials.json"]
																		 consumer:consumer 
																			token:_accessToken 
																			realm:@"http://api.twitter.com/"
																signatureProvider:nil] autorelease];
	  [theRequest setHTTPMethod:@"GET"];

	  [theRequest prepare];
	  NSLog(@"headers: %@", [theRequest allHTTPHeaderFields]);
    NSString *oauthHeaders = [[theRequest allHTTPHeaderFields] valueForKey:@"Authorization"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	  request.isTwitterRequest = YES;

    [request setUserInfo:[NSDictionary dictionaryWithObject:message forKey:@"message"]];
    
    [request addRequestHeader:@"X-Verify-Credentials-Authorization" value:oauthHeaders];
    [request addRequestHeader:@"X-Auth-Service-Provider" value:@"https://api.twitter.com/1/account/verify_credentials.json"];
	  
    [request addPostValue:@"96da45e865a6c36c7d347b4402516e85" forKey:@"key"];
    [request addPostValue:message forKey:@"message"];
	[request addData:UIImagePNGRepresentation(picture) forKey:@"media"];
    	  
    request.requestMethod = @"POST";
    
	  NSLog(@"parameters: %@", [request postBody]);
    NSLog(@"requestHeaders: %@", [request requestHeaders]);
    
    [_queue addOperation:request];
    [_queue go];
	  
	/*OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																	 consumer:consumer
																		token:_accessToken
																		realm:@"http://api.twitter.com/"
															signatureProvider:nil];
	  
	  NSString *stringBoundary = @"0xKhTmjy9WNdArY---This_Is_ThE_BoUnDaRyy---pqo";
	  NSMutableData *postBody = [NSMutableData data];
	  [request setHTTPMethod:@"POST"];
	  [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
	  
	  // encode key
	  [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	  [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"key\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	  [postBody appendData:[@"96da45e865a6c36c7d347b4402516e85" dataUsingEncoding:NSUTF8StringEncoding]];
	  [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	  
	  // encode message
	  [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	  [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"message\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	  [postBody appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
	  [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	  
	  // encode media
	  [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	  [postBody appendData:[@"Content-Disposition: form-data; name=\"media\"; filename=\"image.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	  [postBody appendData:[@"Content-Type: image/png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	  [postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	  
	  // get the image data from the array directly into NSData object
	  NSData *imageData = UIImagePNGRepresentation(picture);
	  
	  // add it to body
	  [postBody appendData:imageData];
	  [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	  
	  // final boundary
	  [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	  
	  // set body
	  [request setHTTPBody:postBody];
	  
	  [request addValue:oauthHeaders forHTTPHeaderField:@"X-Verify-Credentials-Authorization"];
	  [request addValue:@"https://api.twitter.com/1/account/verify_credentials.json" forHTTPHeaderField:@"X-Auth-Service-Provider"];
	  [request setValue:[NSString stringWithFormat:@"%d", [postBody length]] forHTTPHeaderField:@"Content-Length"];
	  
	  NSLog(@"headers: %@", [request allHTTPHeaderFields]);
	  NSURLConnection *updateConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	  [updateConnection start];*/
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connection didReceiveResponse:%d", [(NSHTTPURLResponse *)response statusCode]);
	/*if ([(NSHTTPURLResponse *)response statusCode] != 200) {	//did not succeed
		sendDidFail = YES;
	}*/
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"connectiondidrecievedata: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	/*[delegate addToSentList:TWITTER username:username succeeded:NO];
	sendDidFail = NO;
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    //[receivedData release];
	
	[theRequest release];*/
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"twitter connection did finish loading");
	/*[delegate addToSentList:TWITTER username:username succeeded:!sendDidFail];
	sendDidFail = NO;
	
	// release the connection, and the data object
	[theConnection release];
    //[receivedData release];
	[theRequest release];*/
}

#pragma mark -
#pragma mark OAuth

- (void)setAccessToken:(OAToken *)token {
	[_accessToken autorelease];
	_accessToken = [token retain];
}


#pragma mark -
#pragma mark ASIHTTPRequestDelegate methods

- (void)requestReceivedResponseHeaders:(ASIHTTPRequest *)request {
	NSLog(@"response headers: %@", [request responseHeaders]);
}

- (void)requestFinished:(ASIHTTPRequest *)request {
  // TODO: Pass values as individual parameters to delegate methods instead of wrapping in NSDictionary.
    
	NSString *responseString = nil;
	responseString = [request responseString];
	
  switch ([request responseStatusCode]) {
    case 200:
    {
      // Success, but let's parse and see.
      // TODO: Error out if parse failed?
      // TODO: Need further checks for success.
            
      if ([_delegate respondsToSelector:@selector(twitpicDidFinishUpload:)]) {
        [_delegate twitpicDidFinishUpload:responseString];
      }
      
      break;
    }
    case 400:
      // Failed.      
	  if ([_delegate respondsToSelector:@selector(twitpicDidFailUpload:)]) {
        [_delegate twitpicDidFailUpload:responseString];
      }
      
      break;
    default:      
	  if ([_delegate respondsToSelector:@selector(twitpicDidFailUpload:)]) {
        [_delegate twitpicDidFailUpload:responseString];
      }
      
      break;
  }
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    
	NSString *responseString = nil;
	responseString = [request responseString];
	
	if ([_delegate respondsToSelector:@selector(twitpicDidFailUpload:)]) {
		[_delegate twitpicDidFailUpload:responseString];
	}
			
}


@end
