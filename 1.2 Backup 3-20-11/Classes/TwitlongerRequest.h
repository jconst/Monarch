//
//  TwitlongerRequest.h
//  Monarch
//
//  Created by Joseph Constan on 3/15/11.
//  Copyright 2011 Timothy Rauh Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterRequest.h"

@interface TwitlongerRequest : NSObject {
	id delegate;
	NSString *lastStatus;
}
@property (nonatomic, retain) id delegate;

- (void)uploadStatus:(NSString *)status username:(NSString *)username;

@end
