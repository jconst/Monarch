//
//  FacebookSettingsViewController.m
//  Monarch
//
//  Created by Joseph Constan on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookSettingsViewController.h"


@implementation FacebookSettingsViewController

@synthesize photoUploadType, postAsNote;

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
    [super viewDidLoad];
	
	[photoUploadType addTarget:self action:@selector(photoUploadTypeChanged) forControlEvents:UIControlEventValueChanged];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
	 
- (void)photoUploadTypeChanged
{
	NSLog(@"%d", [photoUploadType isEnabledForSegmentAtIndex:0]);
	//if ([[photoUploadType titleForSegmentAtIndex:photoUploadType.selectedSegmentIndex] isEqualToString:@"Wall"]) {}
	//[[NSUserDefaults standardUserDefaults] setBool: forKey:MonarchFBUploadToWall
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
