//
//  FoursquareSettingsViewController.h
//  Monarch
//
//  Created by Joseph Constan on 7/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"


@interface FoursquareSettingsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate> {
	
	UIPickerView *typePicker;
	UIPickerView *venuePicker;
	UILabel		 *venueLabel;
	UIButton	 *saveButton;
	UIActivityIndicatorView *venueWheel;
	
	NSURLConnection *venueConnection;
	NSMutableDictionary	*venueDictionary;
	
	CLLocationManager *clm;
	CLLocation *currentLocation;

	BOOL shouldSendMessage;
}

@property (nonatomic, retain) IBOutlet UIPickerView *typePicker;
@property (nonatomic, retain) IBOutlet UIPickerView *venuePicker;
@property (nonatomic, retain) IBOutlet UILabel		*venueLabel;
@property (nonatomic, retain) IBOutlet UIButton		*saveButton;

@property (nonatomic, retain) NSMutableDictionary *venueDictionary;

-(IBAction)saveButtonPressed;

@end
