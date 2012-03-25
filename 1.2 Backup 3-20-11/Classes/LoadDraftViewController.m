//
//  LoadDraftViewController.m
//  Monarch
//
//  Created by Joseph Constan on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoadDraftViewController.h"


@implementation LoadDraftViewController


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
    [super viewDidLoad];

	self.title = @"Load Draft";
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:@"DRAFTARRAY"] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[[defaults stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:CURRENTROW] rangeOfString:@"::</title>::"].location != NSNotFound) { 
		//draft has a title
		cell.textLabel.text = [[[[defaults stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:CURRENTROW] 
								componentsSeparatedByString:@"::</title>::"] objectAtIndex:0];
	}
	else {
		//set label to be first 25 characters of message instead of the blank title
		cell.textLabel.text = ([[[defaults stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:CURRENTROW] length] > 35) ?
						[[[defaults stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:CURRENTROW] substringToIndex:35] :
						[[defaults stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:CURRENTROW];
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



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
		NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[[defaults stringArrayForKey:@"DRAFTARRAY"] count]];
		[tempArray setArray:[defaults stringArrayForKey:@"DRAFTARRAY"]];
		[tempArray removeObjectAtIndex:[indexPath indexAtPosition:0]];
		[defaults setObject:(NSArray *)tempArray forKey:@"DRAFTARRAY"];
		
		[tempArray release];
		[defaults release];
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



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

#pragma mark -
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSLog(@"draft array: %@", [[NSUserDefaults standardUserDefaults]  stringArrayForKey:@"DRAFTARRAY"]);
	if ([[[[NSUserDefaults standardUserDefaults]  stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:[indexPath indexAtPosition:1]] rangeOfString:@"::</title>::"].location != NSNotFound) {
		//draft has a title
		MonarchAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate setCheckedStatus:[[[[[NSUserDefaults standardUserDefaults]  stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:[indexPath indexAtPosition:1]] //status
																		 componentsSeparatedByString:@"::</title>::"] objectAtIndex:1]
																 title:[[[[[NSUserDefaults standardUserDefaults]  stringArrayForKey:@"DRAFTARRAY"] objectAtIndex:[indexPath indexAtPosition:1]] //title
																		componentsSeparatedByString:@"::</title>::"] objectAtIndex:0]];
	}
	else {	//no title
		MonarchAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate setCheckedStatus:[[[NSUserDefaults standardUserDefaults] 
									 objectForKey:@"DRAFTARRAY"] objectAtIndex:[indexPath indexAtPosition:1]]
							 title:nil];
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
    [super dealloc];
}


@end

