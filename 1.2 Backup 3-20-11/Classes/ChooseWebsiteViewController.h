//
//  ChooseWebsiteViewController.h
//  Monarch
//
//  Created by Joseph Constan on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"
#import "SA_OAuthTwitterController.h"


@class AddAccountViewController, SA_OAuthTwitterEngine, OAToken;

@interface ChooseWebsiteViewController : UITableViewController <FBSessionDelegate, MOFBPermissionDelegate, SA_OAuthTwitterControllerDelegate, UIWebViewDelegate> {

	AddAccountViewController *addController;
	
	MOFBPermission *fbPermission;
	FBSession *session;
	SA_OAuthTwitterEngine *_engine;
	UIActivityIndicatorView *loadingWheel;
	BOOL isLoggedIn;
	BOOL firstLoad;
	UIViewController *linkedinController;
	UITextField *pinField;
	OAToken *linkedinRequestToken;
}

@property (nonatomic, retain) FBSession *session;
@property (nonatomic, retain) MOFBPermission *fbPermission;
@property (nonatomic, retain) OAToken *linkedinRequestToken;
@property (nonatomic) BOOL isLoggedIn;

- (void) openLinkedinWebViewWithData:(NSData *)data;
- (void) linkedinButtonPressed;

@end
