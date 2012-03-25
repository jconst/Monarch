//
//  ImgurRequest.h
//  Monarch
//
//  Created by Joseph Constan on 3/13/11.
//  Copyright 2011 Timothy Rauh Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VariableStore.h"
#import "ASIHTTPRequest.h"

@interface ImgurRequest : NSObject <ASIHTTPRequestDelegate> {
	
	id delegate;
}
@property (nonatomic, retain) id delegate;

- (void)getTagForImage:(UIImage *)image;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end
