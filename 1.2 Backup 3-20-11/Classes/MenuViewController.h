//
//  MenuViewController.h
//  Monarch
//
//  Created by Joseph Constan on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "VariableStore.h"

@class LoadDraftViewController, FoursquareSettingsViewController, GeneralSettingsViewController, ImageListViewController, PicasaSettingsViewController;

@interface MenuViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	NSString *cacheStatus;
	NSString *cacheTitle;
		
	LoadDraftViewController *loadDraftViewController;
	FoursquareSettingsViewController *foursquareSettingsViewController;
	GeneralSettingsViewController *generalSettingsViewController;
	PicasaSettingsViewController *picasaSettingsViewController;
	MFMailComposeViewController *mailViewController;
	id delegate;
}
@property (nonatomic, retain) PicasaSettingsViewController *picasaSettingsViewController;
@property (nonatomic, retain) NSString *cacheStatus;
@property (nonatomic, retain) NSString *cacheTitle;
@property (nonatomic, assign) id delegate;

- (void)saveDraft;
- (BOOL)isAlreadySaved;

@end
