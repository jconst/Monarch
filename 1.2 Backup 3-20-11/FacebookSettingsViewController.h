//
//  FacebookSettingsViewController.h
//  Monarch
//
//  Created by Joseph Constan on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FacebookSettingsViewController : UIViewController {

	UISegmentedControl *photoUploadType;
	UISwitch *postAsNote;
}
@property (nonatomic, retain) IBOutlet UISegmentedControl *photoUploadType;
@property (nonatomic, retain) IBOutlet UISwitch *postAsNote;

@end
