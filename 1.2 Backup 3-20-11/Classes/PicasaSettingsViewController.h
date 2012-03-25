//
//  PicasaSettingsViewController.h
//  Monarch
//
//  Created by Joseph Constan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"


@interface PicasaSettingsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	
	UIPickerView *usernamePicker;
	UIPickerView *albumPicker;
	
	NSDictionary *albumListDict;
}

@property (nonatomic, retain) IBOutlet UIPickerView *usernamePicker;
@property (nonatomic, retain) IBOutlet UIPickerView *albumPicker;

@property (nonatomic, retain) NSDictionary *albumListDict;

- (IBAction) saveButtonPressed;
- (IBAction) loadAlbums;

@end
