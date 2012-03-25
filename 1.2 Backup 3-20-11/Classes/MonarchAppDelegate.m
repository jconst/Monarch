//
//  MonarchAppDelegate.m
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "MonarchAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"
#import "AddAccountViewController.h"


@implementation MonarchAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController, menuNavController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    
    // Add the split view controller's view to the window and display.
    [window addSubview:splitViewController.view];
    [window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	//Save data
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
	
	for (int i=0; i < [[[VariableStore sharedInstance] accounts] count]; i++) {
		if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == FACEBOOK) {
			[[NSUserDefaults standardUserDefaults] setBool:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] selected] 
													forKey:@"MonarchFBSelected"];
		}
		NSNumber *tempBool = [NSNumber numberWithBool:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] selected]];
		unichar tempChar[1];
		tempChar[0] = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType];
		NSString *tempStr = [[NSString alloc] initWithCharacters:tempChar length:1];
		
		[infoDictionary setObject:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username] 
						   forKey:[NSString stringWithFormat:@"MonarchUsername%d", i]];
		[infoDictionary setObject:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] password] 
						   forKey:[NSString stringWithFormat:@"MonarchPassword%d", i]];
		[infoDictionary setObject:tempStr 
						   forKey:[NSString stringWithFormat:@"MonarchSiteType%d", i]];
		[infoDictionary setObject:tempBool 
						   forKey:[NSString stringWithFormat:@"MonarchSelected%d", i]];	
		if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == BLOGGER) {
			[defaults setObject:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] blogName] 
						 forKey:[NSString stringWithFormat:@"MonarchBlogName%d", i]];
			[defaults setObject:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] blogID] 
						 forKey:[NSString stringWithFormat:@"MonarchBlogID%d", i]];
		}
		[tempStr release];
	}
	/*if ([defaults objectForKey:@"MonarchAccountInfo"]) {
		[defaults removeObjectForKey:@"MonarchAccountInfo"];
	}*/
	[defaults setObject:infoDictionary forKey:@"MonarchAccountInfo"];
	[infoDictionary release];
	
	// save draft if necessary
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MonarchDontAutoSave"] == NO) {
		if ([detailViewController.statusText.text isEqualToString:@"(null)"])
			detailViewController.statusText.text = @"";
		if ([detailViewController.titleField.text isEqualToString:@"(null)"])
			detailViewController.titleField.text = @"";
		if ((![detailViewController.statusText.text isEqualToString:@""] ||		//if status or
			 ![detailViewController.titleField.text isEqualToString:@""]) &&		//title is not empty and
			![detailViewController.menuViewController isAlreadySaved]) {		//draft is not already saved
			[detailViewController.menuViewController saveDraft];
		}
	}
	//delete venue ID
	//[defaults removeObjectForKey:@"MonarchFoursquareVenueID"];

	[defaults synchronize];
}

//the following 2 methods only exist because performselector:withobject: can only take 2 arguments (that I know of...)
//even though I changed the way ^^^ that works, I'm still leaving these here because I'm lazy
- (void) setCheckedStatus:(NSString *)statTxt title:(NSString *)titleTxt
{
	[self setStatus:statTxt title:titleTxt checkSave:@"YES"];
}

- (void) setUncheckedStatus:(NSString *)statTxt title:(NSString *)titleTxt
{
	[self setStatus:statTxt title:titleTxt checkSave:@"NO"];
}

- (void) reloadCorrectionDefaults
{
	// load auto-correction defaults
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MonarchDontAutoCorrect"] == YES) {
		detailViewController.statusText.autocorrectionType = UITextAutocorrectionTypeNo;
		detailViewController.statusText.autocapitalizationType = UITextAutocapitalizationTypeNone;
		detailViewController.titleField.autocorrectionType = UITextAutocorrectionTypeNo;
		detailViewController.titleField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	} else {
		detailViewController.statusText.autocorrectionType = UITextAutocorrectionTypeYes;
		detailViewController.statusText.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		detailViewController.titleField.autocorrectionType = UITextAutocorrectionTypeYes;
		detailViewController.titleField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	}
}

- (NSNumber *) rootViewCellsSelected
{
	return [NSNumber numberWithUnsignedInteger:[rootViewController accountsSelected]];
}

- (void) openPicasaSettingsWithList:(NSDictionary *)albumListDict
{
	NSLog(@"%@", albumListDict);
	NSUInteger indexes[2] = {2, 2};
	NSIndexPath *pathToPicasaSettings = [NSIndexPath indexPathWithIndexes:indexes length:2];
	
	[rootViewController.navigationController popToRootViewControllerAnimated:YES];
	[rootViewController.tableView reloadData];
	[detailViewController optionButtonPressed];
	[detailViewController.menuViewController tableView:detailViewController.menuViewController.tableView didSelectRowAtIndexPath:pathToPicasaSettings];
	detailViewController.menuViewController.picasaSettingsViewController.albumListDict = albumListDict;
	[detailViewController.menuViewController.picasaSettingsViewController loadAlbums];
}

- (void) openFoursquareSettings
{
	NSUInteger indexes[2] = {2, 1};
	NSIndexPath *pathToFoursquareSettings = [NSIndexPath indexPathWithIndexes:indexes length:2];
	
	[rootViewController.navigationController popToRootViewControllerAnimated:YES];
	[rootViewController.tableView reloadData];
	[detailViewController optionButtonPressed];
	[detailViewController.menuViewController tableView:detailViewController.menuViewController.tableView didSelectRowAtIndexPath:pathToFoursquareSettings];
}

//it should be noted that this method doesn't set the status on the website, just changes the text in the app's textView (for loading drafts)
- (void) setStatus:(NSString *)statTxt title:(NSString *)titleTxt checkSave:(NSString *)checkSave
{
	if ([checkSave isEqualToString:@"YES"]) {
		if (![[detailViewController.statusText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
			//status body not empty
			detailViewController.menuViewController.cacheStatus = statTxt;
			detailViewController.menuViewController.cacheTitle = titleTxt;
			UIAlertView *overwriteAlert = [[UIAlertView alloc] initWithTitle:@"Save Before Loading?" 
																	 message:@"You are currently writing a message. Save it and continue loading draft?" 
																	delegate:detailViewController.menuViewController 
														   cancelButtonTitle:@"Cancel" 
														   otherButtonTitles:@"Save", @"Don't Save", nil];
			[overwriteAlert dismissWithClickedButtonIndex:1 animated:YES];
			[overwriteAlert dismissWithClickedButtonIndex:2 animated:YES];
			[overwriteAlert show];
		}
		else {
			NSLog(@"else1 %@", statTxt);
			detailViewController.statusText.text = statTxt;
			detailViewController.titleField.text = titleTxt;
		}
	}
	else {
		NSLog(@"else2 %@", statTxt);
		detailViewController.statusText.text = statTxt;
		detailViewController.titleField.text = titleTxt;
	}
	[detailViewController.rightPopoverController dismissPopoverAnimated:YES];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    //Save data
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *infoDictionary;
	
	infoDictionary = [[NSMutableDictionary alloc] init];
	
	for (int i=0; i < [[[VariableStore sharedInstance] accounts] count]; i++) {
		if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == FACEBOOK) {
			[[NSUserDefaults standardUserDefaults] setBool:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] selected] 
													forKey:@"MonarchFBSelected"];
		}
		NSNumber *tempBool = [NSNumber numberWithBool:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] selected]];
		unichar tempChar[1];
		tempChar[0] = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType];
		NSString *tempStr = [[NSString alloc] initWithCharacters:tempChar length:1];
		
		[infoDictionary setObject:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username] 
						   forKey:[NSString stringWithFormat:@"MonarchUsername%d", i]];
		[infoDictionary setObject:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] password] 
						   forKey:[NSString stringWithFormat:@"MonarchPassword%d", i]];
		[infoDictionary setObject:tempStr 
						   forKey:[NSString stringWithFormat:@"MonarchSiteType%d", i]];
		[infoDictionary setObject:tempBool 
						   forKey:[NSString stringWithFormat:@"MonarchSelected%d", i]];	
		if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == BLOGGER) {
			[defaults setObject:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] blogName] 
							forKey:[NSString stringWithFormat:@"MonarchBlogName%d", i]];
			[defaults setObject:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] blogID] 
							forKey:[NSString stringWithFormat:@"MonarchBlogID%d", i]];
		}
		[tempStr release];
	}
	/*if ([defaults objectForKey:@"MonarchAccountInfo"]) {
		[defaults removeObjectForKey:@"MonarchAccountInfo"];
	}*/
	[defaults setObject:infoDictionary forKey:@"MonarchAccountInfo"];
	[infoDictionary release];
	
	// save draft if necessary
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MonarchDontAutoSave"] == NO) {
		if ((![detailViewController.statusText.text isEqualToString:@""] ||		//if status or
			 ![detailViewController.titleField.text isEqualToString:@""]) &&		//title is not empty and
			![detailViewController.menuViewController isAlreadySaved]) {		//draft is not already saved
			[detailViewController.menuViewController saveDraft];
		}
	}
	//delete venue ID
	[defaults removeObjectForKey:@"MonarchFoursquareVenueID"];
	
	[defaults synchronize];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [splitViewController release];
    [window release];
	[menuNavController release];
	[super dealloc];
}


@end

