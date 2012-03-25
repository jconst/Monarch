//
//  GeneralSettingsViewController.m
//  Monarch
//
//  Created by Joseph Constan on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GeneralSettingsViewController.h"


@implementation GeneralSettingsViewController

@synthesize correctionSwitch, confirmationSwitch, autosaveSwitch;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"General Settings";
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[correctionSwitch setOn:(![defaults boolForKey:@"MonarchDontAutoCorrect"]) animated:NO];
	[confirmationSwitch setOn:(![defaults boolForKey:@"MonarchDontConfirmSend"]) animated:NO];
	[autosaveSwitch setOn:(![defaults boolForKey:@"MonarchDontAutoSave"]) animated:NO];
	
    [super viewWillAppear:animated];
}

- (IBAction)savePreferences
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setBool:(!correctionSwitch.on) forKey:@"MonarchDontAutoCorrect"];
	[defaults setBool:(!confirmationSwitch.on) forKey:@"MonarchDontConfirmSend"];
	[defaults setBool:(!autosaveSwitch.on) forKey:@"MonarchDontAutoSave"];
		
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(reloadCorrectionDefaults)];
	[self.navigationController popToRootViewControllerAnimated:YES];
	//NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

#pragma mark -
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Memory Management

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
