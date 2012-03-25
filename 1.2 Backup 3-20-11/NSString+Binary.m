//
//  NSString+Binary.m
//  Monarch
//
//  Created by Joseph Constan on 7/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+Binary.h"


@implementation NSString (Binary)

+ binaryDataStringFromImage:(UIImage *)image
{
	NSInteger bufferSize = [UIImagePNGRepresentation(image) length];
	unsigned char imageBuffer[bufferSize];
	[UIImagePNGRepresentation(image) getBytes:imageBuffer length:bufferSize];
	unsigned char *bufferCopy = &imageBuffer;
	
	NSMutableString *binaryStr = [NSMutableString stringWithString:@""];
	for(int i=0; i < bufferSize; i++)
	{
		NSMutableString *str = [NSMutableString stringWithString:@""];
		for(; [str length] < 8; *bufferCopy >>= 1)
		{
			// Prepend "0" or "1", depending on the bit
			[str insertString:((*bufferCopy & 1) ? @"1" : @"0") atIndex:0];
		}
		[binaryStr appendString:str];
		*bufferCopy++;
	}
	return (NSString *)binaryStr;
}

@end
