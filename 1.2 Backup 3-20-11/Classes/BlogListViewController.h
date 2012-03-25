//
//  BlogListViewController.h
//  Monarch
//
//  Created by Joseph Constan on 6/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"

@class AccountInfo;

@interface BlogListViewController : UITableViewController {

	NSDictionary *blogList;
	AccountInfo	 *currentInfo;
}

@property (nonatomic, retain) NSDictionary *blogList;
@property (nonatomic, retain) AccountInfo  *currentInfo;

@end
