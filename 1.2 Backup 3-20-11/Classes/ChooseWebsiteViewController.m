//
//  ChooseWebsiteViewController.m
//  Monarch
//
//  Created by Joseph Constan on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChooseWebsiteViewController.h"

@implementation ChooseWebsiteViewController

@synthesize session, isLoggedIn, fbPermission, linkedinRequestToken;

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
	self.title = @"Choose Site";
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 7;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
	
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	switch ([indexPath indexAtPosition:1]) {
		case TWITTER:
			cell.textLabel.text = @"Twitter";
			[cell.imageView setImage:[UIImage imageNamed:@"Twitter Icon.png"]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case FACEBOOK:
			cell.textLabel.text = @"Facebook";
			[cell.imageView setImage:[UIImage imageNamed:@"Facebook Icon.png"]];
			cell.accessoryType = UITableViewCellAccessoryNone;
			break;
		case TUMBLR:
			cell.textLabel.text = @"Tumblr";
			[cell.imageView setImage:[UIImage imageNamed:@"Tumblr Icon.png"]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case FOURSQUARE:
			cell.textLabel.text = @"Foursquare";
			[cell.imageView setImage:[UIImage imageNamed:@"Foursquare Icon.png"]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case BLOGGER:
			cell.textLabel.text = @"Blogger";
			[cell.imageView setImage:[UIImage imageNamed:@"Blogger Icon.png"]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case PICASA:
			cell.textLabel.text = @"Picasa";
			[cell.imageView setImage:[UIImage imageNamed:@"Picasa Icon.png"]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case LINKEDIN:
			cell.textLabel.text = @"Linkedin";
			[cell.imageView setImage:[UIImage imageNamed:@"Linkedin Icon.png"]];
			cell.accessoryType = UITableViewCellAccessoryNone;
			break;
		/*case MYSPACE:
			cell.textLabel.text = [NSString stringWithFormat:@"MySpace (%@)", [[[[VariableStore sharedInstance] accounts] objectAtIndex:[indexPath indexAtPosition:1]] username]];
			break;*/
		default:
			cell.textLabel.text = nil;
			break;
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if ([indexPath indexAtPosition:1] == FACEBOOK) {
		if (isLoggedIn) {
			UIAlertView *fbAccountsAlert = [[[UIAlertView alloc] initWithTitle:@"Already Logged In" 
																	  message:@"The Facebook API currently supports only one user logged in at a time" 
																	 delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
			[fbAccountsAlert show];
		} else {
			FBLoginDialog* dialog = [[[FBLoginDialog alloc] init] autorelease];
			[dialog show];			
		}
	}
	else if ([indexPath indexAtPosition:1] == TWITTER) {
		[VariableStore sharedInstance].twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
		[[VariableStore sharedInstance] twitterEngine].consumerKey = TwitterConsumerKey;
		[[VariableStore sharedInstance] twitterEngine].consumerSecret = TwitterConsumerSecret;
		
		UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:[[VariableStore sharedInstance] twitterEngine] 
																									   delegate: self];
		controller.contentSizeForViewInPopover = CGSizeMake(320, 600);
		
		if (controller) 
			[self.navigationController pushViewController:controller animated:YES];
	} else if ([indexPath indexAtPosition:1] == LINKEDIN) {
		NSLog(@"didSelect Linkedin");
		NSUInteger linkedinPath[2] = {0, LINKEDIN};
		UIActivityIndicatorView *linkedinWheel = [[[UIActivityIndicatorView alloc] init] autorelease];
		[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:linkedinPath length:2]] setAccessoryView:linkedinWheel];
		LinkedinRequest *linkReq = [[LinkedinRequest alloc] init];
		linkReq.delegate = self;
		[linkReq getRequestToken];
	}
	else {
		addController = [[AddAccountViewController alloc] initWithSiteType:[indexPath indexAtPosition:1]];
		[self.navigationController pushViewController:addController animated:YES];
	}
}

#pragma mark -
#pragma mark Facebook support

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	NSLog(@"session:didLogin:%qu", [[NSUserDefaults standardUserDefaults] objectForKey:@"FBUserID"]);
	self.isLoggedIn = YES;
	AccountInfo *currentInfo = [[AccountInfo alloc] init];
	
	// ask for permissions
	fbPermission.delegate = self;
	[fbPermission obtain:@"status_update"];
	[fbPermission obtain:@"offline_access"];
	
	// pull user info from facebook
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%qu", uid]];
	NSString *userInfo = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:NULL];
	NSLog(@"%@", userInfo);
	
	NSArray *infoArray = [[userInfo stringByReplacingOccurrencesOfString:@"\"" withString:@""] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":,"]];
	
	// add account info to singleton and rootViewController
	currentInfo.username = [infoArray objectAtIndex:3] ? [infoArray objectAtIndex:3] : @"";
	currentInfo.password = @"password";	//facebook api does not allow third-party logins
	currentInfo.siteType = FACEBOOK;
	currentInfo.selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"MonarchFBSelected"];
	
	[[[VariableStore sharedInstance] accounts] addObject:currentInfo];
	
	[currentInfo release];
	[[[[self.navigationController viewControllers] objectAtIndex:0] tableView] reloadData];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)sessionDidLogout:(FBSession*)session {
	//delete facebook account when logout
	for (NSUInteger i=0; i < [[[VariableStore sharedInstance] accounts] count]; i++) {
		if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == FACEBOOK) {
			NSLog(@"sessionDidLogout");
			[[[VariableStore sharedInstance] accounts] removeObjectAtIndex:i];
		}
	}
	isLoggedIn = NO;
	[[[[[self navigationController] viewControllers] objectAtIndex:0] tableView] reloadData];	
	[self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)permissionGranted:(MOFBPermission*)permission {
	/*if ([permission.extPerm isEqualToString:@"offline_access"]) 
		[permission release];*/
}

- (void)permissionDenied:(MOFBPermission*)permission {
	/*if ([permission.extPerm isEqualToString:@"offline_access"]) 
		[permission release];*/
}

	
#pragma mark -
#pragma mark Twitter support
	
	//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	NSLog(@"oauth data : %@", data);
	
	[defaults setObject: data forKey: [NSString stringWithFormat:@"MonarchTwitterAuth%@", username]];
	[defaults synchronize];
}
	
- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: [NSString stringWithFormat:@"MonarchTwitterAuth%@", username]];
}
	
	//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	NSLog(@"Authenicated for %@", username);
	
	// save access data to defaults for multiple accounts
	[[NSUserDefaults standardUserDefaults] setObject: [[VariableStore sharedInstance] twitterEngine]._accessToken.secret forKey: [NSString stringWithFormat:@"MonarchTwitterAccessSecret%@", username]];
	[[NSUserDefaults standardUserDefaults] setObject: [[VariableStore sharedInstance] twitterEngine]._accessToken.key forKey: [NSString stringWithFormat:@"MonarchTwitterAccessKey%@", username]];
	
	// add account to list
	AccountInfo *currentInfo = [[AccountInfo alloc] init];
	currentInfo.username = username;
	currentInfo.password = @"password";		//@"password" is just a dummy for storage because of oauth
	currentInfo.siteType = TWITTER;
	[[[VariableStore sharedInstance] accounts] addObject:currentInfo];
	
	[[[[self.navigationController viewControllers] objectAtIndex:0] tableView] reloadData];
	[self.navigationController popToRootViewControllerAnimated:YES];
}
	
- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	NSLog(@"Twitter Authentication Failed!");
	[self.navigationController popToRootViewControllerAnimated:YES];
	[[[[[self.navigationController viewControllers] objectAtIndex:0] detailViewController] popoverController] dismissPopoverAnimated:YES];
}
	
- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	NSLog(@"Twitter Authentication Canceled.");
	[self.navigationController popToRootViewControllerAnimated:YES];
	[[[[[self.navigationController viewControllers] objectAtIndex:0] detailViewController] popoverController] dismissPopoverAnimated:YES];
}
	
	//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
	[[[[self.navigationController viewControllers] objectAtIndex:0] detailViewController] addToSentList:TWITTER username:[VariableStore sharedInstance].currentName succeeded:YES];
}
	
- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
	[[[[self.navigationController viewControllers] objectAtIndex:0] detailViewController] addToSentList:TWITTER username:[VariableStore sharedInstance].currentName succeeded:NO];
}
	
#pragma mark -
#pragma mark Linkedin support
- (void) openLinkedinWebViewWithData:(NSData *)data
{
	NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	NSUInteger linkedinPath[2] = {0, LINKEDIN};
	[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:linkedinPath length:2]] setAccessoryView:nil];
	
	// parse data, get token
	NSString *requestToken = [[dataString componentsSeparatedByString:@"&oauth_token_secret"] objectAtIndex:0];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth/authorize?%@", requestToken]];

	UIWebView *linkedinWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 640, 600)];
	linkedinController = [[[UIViewController alloc] init] autorelease];
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 600)];
	scrollView.contentSize = CGSizeMake(640, 600);
	[linkedinController.view addSubview:scrollView];
	[scrollView addSubview:linkedinWebView];
	linkedinController.contentSizeForViewInPopover = CGSizeMake(320, 600);
	[self.navigationController pushViewController:linkedinController animated:YES];
	firstLoad = YES;
	[linkedinWebView loadRequest:[NSURLRequest requestWithURL:url]];
	linkedinWebView.delegate = self;
	// show loading spinner
	loadingWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	loadingWheel.center = linkedinController.view.center;
	[loadingWheel startAnimating];
	[linkedinController.view addSubview:loadingWheel];
}

- (void) webViewDidFinishLoad: (UIWebView *) webView {
	//[self performInjection];
	NSLog(@"webViewDidFinishLoad");
	if (firstLoad) {
		NSLog(@"firstload");
		firstLoad = NO;
		[loadingWheel stopAnimating];
		[loadingWheel removeFromSuperview];
		[loadingWheel release];
	} else {
		/*NSString *authPin = [self locateAuthPinInWebView: webView];
		NSLog(@"pin = %@", authPin);
		
		if (authPin.length) {
			//[self gotPin: authPin];
			return;
		}*/
		UIView *bgView = [[UIView alloc] initWithFrame:webView.frame];
		bgView.backgroundColor = [UIColor whiteColor];
		linkedinController.view = bgView;
		CGRect viewFrame = webView.frame;
		viewFrame.size.height = 262;
		webView.frame = viewFrame;
		[linkedinController.view addSubview:webView];
		
		UILabel *enterPinLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, viewFrame.size.height+4, viewFrame.size.width-40, 30)];
		enterPinLabel.text = @"Paste the 5-digit pin above here:";
		pinField = [[UITextField alloc] initWithFrame:CGRectMake(20, viewFrame.size.height+40, viewFrame.size.width-40, 25)];
		pinField.borderStyle = UITextBorderStyleRoundedRect;
		UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[doneButton setTitleColor:[UIColor colorWithRed:0.0 green:0.1 blue:0.6 alpha:1] forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		[doneButton setTitle:@"Done" forState:UIControlStateNormal & UIControlStateHighlighted];
		doneButton.frame = CGRectMake(linkedinController.view.center.x - 40, viewFrame.size.height+80, 80, 40);
		[doneButton addTarget:self action:@selector(linkedinButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		
		[linkedinController.view addSubview:enterPinLabel];
		[linkedinController.view addSubview:pinField];
		[linkedinController.view addSubview:doneButton];
	}
}

- (void) linkedinButtonPressed
{
	NSLog(@"button pressed");
	LinkedinRequest *linkReq = [[[LinkedinRequest alloc] init] autorelease];
	linkReq.pin = pinField.text;
	linkReq.requestToken = linkedinRequestToken;
	linkReq.delegate = self;
	[linkReq getAccessToken];
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
	self.session = nil;
}


- (void)dealloc {
	[session.delegates removeObject: self];
	[session release];
	[fbPermission release];
    [super dealloc];
}


@end

