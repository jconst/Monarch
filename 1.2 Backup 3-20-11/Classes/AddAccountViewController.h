//
//  AddAccountViewController.h
//  Monarch
//
//  Created by Joseph Constan on 5/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"
#import "AccountInfo.h"
#import "FBConnect.h"
#import "MOFBHelper.h"

@class AccountInfo, BlogListViewController;
@protocol NSXMLParserDelegate;


@interface AddAccountViewController : UIViewController <NSXMLParserDelegate> {

	UILabel			*usernameLabel;
	UITextField		*usernameField;
	UITextField		*passwordField;
	UIButton		*addButton;
	UIView			*concatView;
	UIActivityIndicatorView *addWheel;
	
	NSXMLParser		*listParser;
	const NSString *blank;
	NSString		*currentXMLElement;
	NSMutableDictionary	*blogListDict;
	
	BOOL	inEntry;
	BOOL	isBlog;
	NSUInteger blogNum;
	NSUInteger siteType;
	
	BlogListViewController *blogListViewController;
}

@property (nonatomic, retain) UILabel			*usernameLabel;
@property (nonatomic, retain) IBOutlet UITextField		*usernameField;
@property (nonatomic, retain) IBOutlet UITextField		*passwordField;
@property (nonatomic, retain) IBOutlet UIButton			*addButton;
@property (nonatomic, retain) UIView			*concatView;
@property (nonatomic, retain) NSXMLParser				*listParser;
@property (nonatomic, retain) NSString					*currentXMLElement;
@property (nonatomic, retain) NSMutableDictionary		*blogListDict;

- (id)initWithSiteType:(NSUInteger)type;
- (IBAction) addButtonPressed;
- (void) parseBlogList:(NSData *)listData;
- (void) parseAlbumList:(NSData *)listData forUsername:(NSString *)username;
- (void) loadSiteView;

@end
