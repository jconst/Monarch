//
//  VariableStore.h
//  Monarch
//
//  Created by Joseph Constan on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RootViewController.h"
#import "DetailViewController.h"
#import "AddAccountViewController.h"
#import "AccountInfo.h"
#import "TwitterRequest.h"
#import "FoursquareRequest.h"
#import "BloggerRequest.h"
#import "BlogListViewController.h"
#import "MenuViewController.h"
#import "FoursquareSettingsViewController.h"
#import "ChooseWebsiteViewController.h"
#import "GeneralSettingsViewController.h"
#import "LoadDraftViewController.h"
#import "ImageListViewController.h"
#import "PicasaRequest.h"
#import "PicasaSettingsViewController.h"
#import "SA_OAuthTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import "NSData+Base64a.h"
#import "OAuthConsumer.h"
#import "LinkedinRequest.h"
#import "ImgurRequest.h"

#define TwitterConsumerKey				@"XbUEQq5mLNCrZNZU0coCOA"
#define TwitterConsumerSecret			@"N7S3JxRWSg1eefJHvN8lt7bZUGJ3cn68x4yuN9RN7c"

@interface VariableStore : NSObject
{
	NSMutableArray *accounts;
	NSMutableArray *images;
	SA_OAuthTwitterEngine *twitterEngine;
	NSString *currentName;
	CLLocationManager *clm;
}
@property (nonatomic, retain) NSMutableArray *accounts;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) SA_OAuthTwitterEngine *twitterEngine;
@property (nonatomic, retain) NSString *currentName;
@property (nonatomic, retain) CLLocationManager *clm;

// message from which our instance is obtained
+ (VariableStore *)sharedInstance;
@end

