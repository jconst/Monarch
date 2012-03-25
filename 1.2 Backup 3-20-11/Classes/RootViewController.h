//
//  RootViewController.h
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"

@class DetailViewController, ChooseWebsiteViewController;

@interface RootViewController : UITableViewController {
	DetailViewController *detailViewController;
	ChooseWebsiteViewController *chooseController;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) ChooseWebsiteViewController *chooseController;

- (void) loadData;
- (void) pressedEdit;
- (void) pressedCancel;
- (NSUInteger) accountsSelected;

@end