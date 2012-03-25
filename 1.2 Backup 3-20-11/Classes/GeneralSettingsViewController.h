//
//  GeneralSettingsViewController.h
//  Monarch
//
//  Created by Joseph Constan on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GeneralSettingsViewController : UIViewController {
	UISwitch *correctionSwitch;
	UISwitch *confirmationSwitch;
	UISwitch *autosaveSwitch;
}
@property (nonatomic, retain) IBOutlet UISwitch *correctionSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *confirmationSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *autosaveSwitch;

- (IBAction)savePreferences;

@end
