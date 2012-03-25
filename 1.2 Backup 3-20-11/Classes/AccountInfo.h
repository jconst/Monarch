//
//  AccountInfo.h
//  Monarch
//
//  Created by Joseph Constan on 5/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VariableStore.h"

#define TWITTER 0
#define TUMBLR 1
#define FOURSQUARE 2
#define BLOGGER 3
#define PICASA 4
#define FACEBOOK 5
#define LINKEDIN 6


@interface AccountInfo : NSObject {

	NSString *username;
	NSString *password;
	unichar  siteType;
	BOOL	 selected;
	NSString *blogName;
	NSString *blogID;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic) unichar siteType;
@property (nonatomic) BOOL	selected;
@property (nonatomic, retain) NSString *blogName;
@property (nonatomic, retain) NSString *blogID;


@end
