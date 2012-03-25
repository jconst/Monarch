//
//  MenuViewController.m
//  Monarch
//
//  Created by Joseph Constan on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"



@implementation MenuViewController

@synthesize cacheStatus, cacheTitle, delegate, picasaSettingsViewController;

#define STATBODY [[delegate statusText] text]
#define STATTITLE [[delegate titleField] text]

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
	self.navigationItem.title = @"Menu";
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	
	MonarchAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	if ([appDelegate detailViewController].popoverController.popoverVisible) {
		[[appDelegate detailViewController].popoverController dismissPopoverAnimated:YES];
	}
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != 0) {
		if (buttonIndex == 1) {			//save pressed
			[self saveDraft];
		}
		//probably change to NSInvocation
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(setUncheckedStatus:title:) 
														   withObject:cacheStatus
														   withObject:cacheTitle];
		 [cacheStatus release];
		[cacheTitle release];
	}
	[alertView release];
}

#pragma mark -
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 630.0);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
   switch (section) {
		case 0:
			return 2;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 3;
			break;
		case 3:
		   return 3;
			break;
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"Images";
			break;
		case 1:
			return @"Drafts";
			break;
		case 2:
			return @"Settings";
			break;
		case 3:
			return @"Other";
			break;
		default:
			return nil;
			break;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (CURRENTSECTION == 0) {		//section 2 (images)
		if (CURRENTROW == 0) {
			cell.textLabel.text = @"Insert Image";
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		if (CURRENTROW == 1) {
			cell.textLabel.text = [NSString stringWithFormat:@"View Attached Images (%d)", [[[VariableStore sharedInstance] images] count]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
    if (CURRENTSECTION == 1) {		//section 1 (drafts)
		if (CURRENTROW == 0) {		//row 0
			if ([self isAlreadySaved]) {
				cell.textLabel.text = @"Saved!";
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			else {
				cell.textLabel.text = @"Save Draft";
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}	
		if (CURRENTROW == 1) {	//row 1 (section 0 still)
			NSUInteger draftCount = ([defaults stringArrayForKey:@"DRAFTARRAY"]) ? [[defaults stringArrayForKey:@"DRAFTARRAY"] count] : 0;
			cell.textLabel.text = [NSString stringWithFormat:@"Load Draft (%d)", draftCount];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	if (CURRENTSECTION == 2) {
		if (CURRENTROW == 0) {
			cell.textLabel.text = @"General Settings";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (CURRENTROW == 1) {
			cell.textLabel.text = @"Foursquare Settings";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (CURRENTROW == 2) {
			cell.textLabel.text = @"Picasa Settings";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	if (CURRENTSECTION == 3) {
		if (CURRENTROW == 0) {
			cell.textLabel.text = @"Contact Us";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (CURRENTROW == 1) {
			cell.textLabel.text = @"Instructions";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (CURRENTROW == 2) {
			cell.textLabel.text = @"Credits";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (BOOL)isAlreadySaved
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([[defaults stringArrayForKey:@"DRAFTARRAY"] count] != 0) {
		for (int i=0; i < [[defaults stringArrayForKey:@"DRAFTARRAY"] count]; i++) {
			if ([[[defaults stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:i] rangeOfString:@"::</title>::"].location != NSNotFound) {
				if ([[[[[defaults stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:i] componentsSeparatedByString:@"::</title>::"] objectAtIndex:1] isEqualToString:STATBODY]) {
					return YES;
				}
				else {
					if (i == [[defaults stringArrayForKey:@"DRAFTARRAY"] count] - 1) return NO;
				}
			}
			else {
				if ([[[defaults stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:i] isEqualToString:STATBODY]) {
					return YES;
				}
				else {
					if (i == [[defaults stringArrayForKey:@"DRAFTARRAY"] count] - 1) return NO;
				}
			}
		}
	}
	else {
		return NO;
	}
}


- (void)saveDraft
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if([[STATTITLE stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {	//title empty
		if (![defaults stringArrayForKey:@"DRAFTARRAY"]) {				
			[defaults setObject:[NSArray arrayWithObject:STATBODY] forKey:@"DRAFTARRAY"];
		}
		else {
			NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[defaults stringArrayForKey:@"DRAFTARRAY"].count];
			[tempArray setArray:[defaults objectForKey:@"DRAFTARRAY"]];
			[tempArray addObject:STATBODY];
			[defaults setObject:(NSArray *)tempArray forKey:@"DRAFTARRAY"];
			[tempArray release];
		}
	}
	else {
		if (![defaults stringArrayForKey:@"DRAFTARRAY"]) {				
			[defaults setObject:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@::</title>::%@", STATTITLE, STATBODY]] forKey:@"DRAFTARRAY"];
		}
		else {
			NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[defaults stringArrayForKey:@"DRAFTARRAY"].count];
			[tempArray setArray:[defaults objectForKey:@"DRAFTARRAY"]];
			[tempArray addObject:[NSString stringWithFormat:@"%@::</title>::%@", STATTITLE, STATBODY]];
			[defaults setObject:(NSArray *)tempArray forKey:@"DRAFTARRAY"];
		}
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Save Draft"]) {
		[self saveDraft];
		[tableView reloadData];
	}
	if ([indexPath indexAtPosition:0] == 1 && [indexPath indexAtPosition:1] == 1) {	//load draft
		loadDraftViewController = [[LoadDraftViewController alloc] init];
		[self.navigationController pushViewController:loadDraftViewController animated:YES];
	}
	if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Foursquare Settings"]) {
		BOOL anyFoursquareAccounts = NO;
		for (int i = 0; i < [[[VariableStore sharedInstance] accounts] count]; i++) {
			if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == FOURSQUARE)
				anyFoursquareAccounts = YES;
		}
		if (anyFoursquareAccounts == YES) {
			foursquareSettingsViewController = [[FoursquareSettingsViewController alloc] init];
			[self.navigationController pushViewController:foursquareSettingsViewController animated:YES];
		} else {
			UIAlertView *noFoursquareAlert = [[[UIAlertView alloc] initWithTitle:@"No Foursquare Account"
																	 message:@"You haven't added any Foursquare accounts to the interface."
																	delegate:nil 
														   cancelButtonTitle:@"OK"
														   otherButtonTitles:nil] autorelease];
			[noFoursquareAlert show];
		}
	}
	if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"General Settings"]) {
		generalSettingsViewController = [[GeneralSettingsViewController alloc] init];
		[self.navigationController pushViewController:generalSettingsViewController animated:YES];
	}
	if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Picasa Settings"]) {
		BOOL anyPicasaAccounts = NO;
		for (int i = 0; i < [[[VariableStore sharedInstance] accounts] count]; i++) {
			if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == PICASA)
				anyPicasaAccounts = YES;
		}
		if (anyPicasaAccounts) {
			picasaSettingsViewController = [[PicasaSettingsViewController alloc] init];
			[self.navigationController pushViewController:picasaSettingsViewController animated:YES];
		} else {
			UIAlertView *noPicasaAlert = [[[UIAlertView alloc] initWithTitle:@"No Picasa Account"
																	 message:@"You haven't added any Picasa accounts to the interface."
																	delegate:nil 
														   cancelButtonTitle:@"OK"
														   otherButtonTitles:nil] autorelease];
			[noPicasaAlert show];
		}
	}
	if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Insert Image"]) {
		UIImagePickerController *insertImageController = [[UIImagePickerController alloc] init];
		insertImageController.delegate = self;
		[[delegate rightPopoverController] setContentViewController:insertImageController animated:YES];
	}
	if ([indexPath indexAtPosition:0] == 0 && [indexPath indexAtPosition:1] == 1) {	//View Attached Images
		ImageListViewController *imageListViewController = [[ImageListViewController alloc] initWithNibName:@"ImageListView" bundle:nil];
		[self.navigationController pushViewController:imageListViewController animated:YES];
	}
	if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Contact Us"]) {
		if ([MFMailComposeViewController canSendMail]) {
			mailViewController = [[[MFMailComposeViewController alloc] init] autorelease];
			[mailViewController setToRecipients:[NSArray arrayWithObjects:@"joseph@codevs.com", @"andrew@andrewrauh.com", nil]];
			[mailViewController setSubject:@"Monarch Express"];
			mailViewController.mailComposeDelegate = self;
			//[mailViewController setSubject:(NSString *)"Monarch for iPad"];
			MonarchAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
			[[appDelegate detailViewController] presentModalViewController:mailViewController animated:YES];
		}
	}
	if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Instructions"]) {
		UIViewController *insructionsViewController = [[UIViewController alloc] initWithNibName:@"InstructionsView" bundle:nil];
		insructionsViewController.contentSizeForViewInPopover = CGSizeMake(320, 600);
		[self.navigationController pushViewController:insructionsViewController animated:YES]; 
	}
	if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Credits"]) {
		UIViewController *creditsViewController = [[UIViewController alloc] initWithNibName:@"CreditsView" bundle:nil];
		creditsViewController.contentSizeForViewInPopover = CGSizeMake(320, 650);
		[self.navigationController pushViewController:creditsViewController animated:YES]; 
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	MonarchAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate detailViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[delegate attachImage:[info objectForKey:UIImagePickerControllerOriginalImage]]; 
	[[delegate rightPopoverController] dismissPopoverAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[[delegate rightPopoverController] dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[self.navigationController release];
    [super dealloc];
}


@end

