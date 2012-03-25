//
//  RootViewController.m
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize detailViewController, chooseController;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	chooseController = [[ChooseWebsiteViewController alloc] init];
	chooseController.session = [FBSession sessionForApplication:@"b85e1641a85eae5b552970c7b1027876" secret:@"8f3081804bf1ceba09462a3876c364b8" delegate:chooseController];
	
	[self loadData];
	
	if ([chooseController.session resume]) {
		NSLog(@"should resume properly");
		chooseController.isLoggedIn = YES;
	}
	else {
		chooseController.isLoggedIn = NO;
	}
	
	if (self.tableView.editing == NO) {
		[self pressedCancel];
	}
	else {
		[self pressedEdit];
	}
	[super viewDidLoad];
}

- (void) loadData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *infoDictionary;	
	[[VariableStore sharedInstance] setAccounts:[[NSMutableArray alloc] init]];
	
	infoDictionary = [[NSMutableDictionary alloc] initWithDictionary:[defaults dictionaryForKey:@"MonarchAccountInfo"]];
	
	for (int i=0; i < [infoDictionary count] / 4; i++) {
		if ([[infoDictionary objectForKey:[NSString stringWithFormat:@"MonarchSiteType%d", i]] characterAtIndex:0] != FACEBOOK) {
			AccountInfo *tempInfo = [[AccountInfo alloc] init];

			tempInfo.username = [infoDictionary objectForKey:[NSString stringWithFormat:@"MonarchUsername%d", i]];
			tempInfo.password = [infoDictionary objectForKey:[NSString stringWithFormat:@"MonarchPassword%d", i]];
			tempInfo.siteType = [[infoDictionary objectForKey:[NSString stringWithFormat:@"MonarchSiteType%d", i]] characterAtIndex:0];
			tempInfo.selected = [[infoDictionary objectForKey:[NSString stringWithFormat:@"MonarchSelected%d", i]] boolValue];
			if (tempInfo.siteType == BLOGGER) {
				tempInfo.blogName = [defaults objectForKey:[NSString stringWithFormat:@"MonarchBlogName%d", i]];
				tempInfo.blogID = [defaults objectForKey:[NSString stringWithFormat:@"MonarchBlogID%d", i]];			
			}
			[[[VariableStore sharedInstance] accounts] addObject:tempInfo];
			[tempInfo release];
		}
	}	
	[infoDictionary release];
}

- (void)pressedEdit
{    
    UIBarButtonItem *cancelButton =
	[[[UIBarButtonItem alloc]
	  initWithTitle:@"Cancel"
	  style:UIBarButtonItemStyleDone
	  target:self
	  action:@selector(pressedCancel)]
	 autorelease];
	
    [self.navigationItem setRightBarButtonItem:cancelButton animated:YES];
	
    [self.tableView setEditing:YES animated:YES];
}

- (void)pressedCancel
{
    UIBarButtonItem *editButton =
	[[[UIBarButtonItem alloc]
	  initWithTitle:@"Edit"
	  style:UIBarButtonItemStylePlain
	  target:self
	  action:@selector(pressedEdit)]
	 autorelease];
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
		
    [self.tableView setEditing:NO animated:YES];
}

- (NSUInteger)accountsSelected
{
	NSUInteger selected = 0;
	
	for (int i=0; i < [self tableView:self.tableView numberOfRowsInSection:0] - 1; i++) {
		if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] selected] == YES) {
			selected++;
		}
	}
	return selected;
}


- (void)viewWillAppear:(BOOL)animated {
	if (detailViewController.rightPopoverController.popoverVisible) {
		[detailViewController.rightPopoverController dismissPopoverAnimated:YES];
	}
    [super viewWillAppear:animated];
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

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[VariableStore sharedInstance] accounts].count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
	
	UIImageView *checkmarkImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Check.png"]] autorelease];
	UIImageView *crossmarkImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cross.png"]] autorelease];
		
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
	if ([indexPath indexAtPosition:1] == [self.tableView numberOfRowsInSection:0] - 1) { //if last row in table
		cell.textLabel.text = [NSString stringWithString:@"Add Account"];				 //label = add account
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;				 // > symbol at right side of cell
		cell.accessoryView = nil;
		cell.detailTextLabel.text = nil;
		[cell.imageView setImage:nil];
	}
	else {
		
		switch ([[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] siteType]) {
			case TWITTER:
				cell.textLabel.text = [NSString stringWithString:@"Twitter"];
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] username]];
				[cell.imageView setImage:[UIImage imageNamed:@"Twitter Icon.png"]];
				break;
			case FACEBOOK:
				cell.textLabel.text = [NSString stringWithString:@"Facebook"];
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] username]];
				[cell.imageView setImage:[UIImage imageNamed:@"Facebook Icon.png"]];
				break;
			case TUMBLR:
				cell.textLabel.text = [NSString stringWithString:@"Tumblr"];
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] username]];
				[cell.imageView setImage:[UIImage imageNamed:@"Tumblr Icon.png"]];
				break;
			case FOURSQUARE:
				cell.textLabel.text = [NSString stringWithString:@"Foursquare"];
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] username]];
				[cell.imageView setImage:[UIImage imageNamed:@"Foursquare Icon.png"]];
				break;
			case BLOGGER:
				cell.textLabel.text = [NSString stringWithString:@"Blogger"];
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] blogName]];
				[cell.imageView setImage:[UIImage imageNamed:@"Blogger Icon.png"]];
				break;
			case PICASA:
				cell.textLabel.text = [NSString stringWithString:@"Picasa"];
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] username]];
				[cell.imageView setImage:[UIImage imageNamed:@"Picasa Icon.png"]];
				break;
			case LINKEDIN:
				cell.textLabel.text = [NSString stringWithString:@"Linkedin"];
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] username]];
				[cell.imageView setImage:[UIImage imageNamed:@"Linkedin Icon.png"]];
				break;
			/*case MYSPACE:
				cell.textLabel.text = [NSString stringWithFormat:@"MySpace (%@)", [[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] username]];
				break;*/
			default:
				cell.textLabel.text = nil;
				break;
		}
		if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] selected] == NO) {	//if not selected
			cell.accessoryView = crossmarkImage;																						//crossmark accessory view
		}
		else {																																//if selected
			cell.accessoryView = checkmarkImage;																						//checkmark accessory
		}
	}
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath indexAtPosition:1] == [[[VariableStore sharedInstance] accounts] count]) {
		return NO;
	}    
	else {
		return YES;
	}
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] siteType] == FACEBOOK) {
			if (chooseController.session) {
				[chooseController.session logout];
			}
		}
		else {
			[[[VariableStore sharedInstance] accounts] removeObjectAtIndex:[indexPath indexAtPosition:1]];
		}
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
}*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 if ([indexPath indexAtPosition:1] == [[[VariableStore sharedInstance] accounts] count]) {
 return NO;
 }    
 else {
 return YES;
 }
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([indexPath indexAtPosition:1] == [self.tableView numberOfRowsInSection:0] - 1) {
		[self.navigationController pushViewController:chooseController animated:YES];
	}
	else {
		if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] selected] == NO) {
									
			[[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] setSelected:YES] ;
		
			[[aTableView cellForRowAtIndexPath:indexPath] setHighlighted:NO];
					
			[[self tableView] reloadData];
		}
		else {
			[[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] setSelected:NO];
		
			[[aTableView cellForRowAtIndexPath:indexPath] setHighlighted:NO];
					
			[[self tableView] reloadData];
		}
	}
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
	[chooseController.session release];
	[chooseController release];
    [super dealloc];
}


@end

