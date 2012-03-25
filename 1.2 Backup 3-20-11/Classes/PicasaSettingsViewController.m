//
//  PicasaSettingsViewController.m
//  Monarch
//
//  Created by Joseph Constan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PicasaSettingsViewController.h"


@implementation PicasaSettingsViewController

@synthesize usernamePicker, albumPicker, albumListDict;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
			// Custom initialization
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	if ([[[UIApplication sharedApplication] delegate] detailViewController].popoverController.popoverVisible) {
		[[[[UIApplication sharedApplication] delegate] detailViewController].popoverController dismissPopoverAnimated:YES];
	}
    [super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if ([usernamePicker numberOfRowsInComponent:0] > 0)
		[self pickerView:usernamePicker didSelectRow:0 inComponent:0];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (pickerView == albumPicker) {
		if (!usernamePicker)
			return 2;
		else {
 			return (([albumListDict count] - 2) / 2);
		}
	} else {	// username picker
		NSUInteger amountOfPicasaUsernames = 0;
		for (int i = 0; i < [[[VariableStore sharedInstance] accounts] count]; i++) {
			if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == PICASA)
				amountOfPicasaUsernames++;
		}
		return amountOfPicasaUsernames;
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSLog(@"titleforrow...");
	if (pickerView == usernamePicker) {
		NSMutableArray *indexesForPicasaAccounts = [[[NSMutableArray alloc] init] autorelease];
		for (int i = 0; i < [[[VariableStore sharedInstance] accounts] count]; i++) {
			if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == PICASA) {
				[indexesForPicasaAccounts addObject:[NSNumber numberWithInt:i]];
			}
		}
		NSUInteger picasaIndex = [[indexesForPicasaAccounts objectAtIndex:row] unsignedIntegerValue];
		NSLog(@"picasaindex = %d", picasaIndex);
		NSLog(@"%@", albumListDict);
		return [[[[VariableStore sharedInstance] accounts] objectAtIndex:picasaIndex] username];
	} else {	//album picker
		NSLog(@"%@", albumListDict);
		return [albumListDict objectForKey:[NSString stringWithFormat:@"ALBUMNAME%d", row]];
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSString *picasaUsername;
	if (pickerView == usernamePicker) {
		for (int i = 0; i < [[[VariableStore sharedInstance] accounts] count]; i++) {
			if ([[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username] isEqualToString:
				 [self pickerView:usernamePicker titleForRow:row forComponent:component]])
				picasaUsername = [self pickerView:usernamePicker titleForRow:[usernamePicker selectedRowInComponent:0] forComponent:0];
		}
		albumListDict = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"MonarchAlbumList%@", picasaUsername]];
		[albumPicker reloadComponent:0];
	}
}

- (IBAction) saveButtonPressed
{
	[[NSUserDefaults standardUserDefaults] setObject:[albumListDict objectForKey:
													  [NSString stringWithFormat:@"ALBUMID%d", 
													   [albumPicker selectedRowInComponent:0]]]
											  forKey:[NSString stringWithFormat:@"MonarchPicasaAlbumID%@", [albumListDict objectForKey:@"CURRENTUN"]]];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) loadAlbums
{
	[[NSUserDefaults standardUserDefaults] setObject:albumListDict 
											  forKey:[NSString stringWithFormat:@"MonarchAlbumList%@", 
													  [albumListDict objectForKey:@"CURRENTUN"]]];
	[usernamePicker reloadComponent:0];
	[albumPicker reloadComponent:0];
}

#pragma mark -
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
