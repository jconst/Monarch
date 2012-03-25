//
//  ImgurRequest.m
//  Monarch
//
//  Created by Joseph Constan on 3/13/11.
//  Copyright 2011 Timothy Rauh Jr. All rights reserved.
//

#import "ImgurRequest.h"
#import "ASIFormDataRequest.h"

@implementation ImgurRequest

@synthesize delegate;

- (void)getTagForImage:(UIImage *)image {
	NSURL *url = [NSURL URLWithString:@"http://imgur.com/api/upload"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	
	[request addPostValue:@"14617cae510e445b34466970848a8d4f" forKey:@"key"];
	[request addData:UIImagePNGRepresentation(image) forKey:@"image"];
	
	request.requestMethod = @"POST";
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	BOOL tagIsNull = ([[request responseString] rangeOfString:@"<original_image>"].location == NSNotFound);
	if (tagIsNull) {
		[self requestFailed:nil];
		return;
	}
	
	NSString *imgUrl = [[[[[request responseString] componentsSeparatedByString:@"<original_image>"] objectAtIndex:1]
													componentsSeparatedByString:@"</original_image>"] objectAtIndex:0];

	NSString *imgTag = [NSString stringWithFormat:@"<image src=\"%@\" />", imgUrl];
	if ([delegate respondsToSelector:@selector(imgurRequest:didReturnTag:)]) {
		[delegate imgurRequest:self didReturnTag:imgTag];
	}
}
	
- (void)requestFailed:(ASIHTTPRequest *)request
{
	if ([delegate respondsToSelector:@selector(imgurRequest:didReturnTag:)]) {
		[delegate imgurRequest:self didReturnTag:@""];
	}
}

- (void)dealloc {
	[delegate release];
	[super dealloc];
}

@end
