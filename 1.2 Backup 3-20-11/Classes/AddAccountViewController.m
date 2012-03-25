//
//  AddAccountViewController.m
//  Monarch
//
//  Created by Joseph Constan on 5/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddAccountViewController.h"

@implementation AddAccountViewController

@synthesize usernameField, passwordField, addButton, concatView, 
			usernameLabel, listParser, currentXMLElement, blogListDict;


- (id)initWithSiteType:(NSUInteger)type
{
	self = [super initWithNibName:@"AddAccountView" bundle:nil];
	siteType = type;
	return self;
}

- (IBAction) addButtonPressed
{
	AccountInfo *currentInfo = [[AccountInfo alloc] init];
	
	[passwordField resignFirstResponder];
	[usernameField resignFirstResponder];
	
	if (usernameField.text == blank) {
		if (passwordField.text == blank) {
			UIAlertView *blankFieldAlert;
			blankFieldAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithString:@"Blank Fields"] 
														 message:[NSString stringWithString:@"Username and password fields are blank"] delegate:nil 
											   cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[blankFieldAlert show];
			[blankFieldAlert release];
		}
		else {
			UIAlertView *blankFieldAlert;
			blankFieldAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithString:@"Blank Field"] 
														 message:[NSString stringWithString:@"Username field is blank"] delegate:nil 
											   cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[blankFieldAlert show];
			[blankFieldAlert release];
		}
	}
	else if (passwordField.text == blank) {
		UIAlertView *blankFieldAlert;
		blankFieldAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithString:@"Blank Field"] 
													 message:[NSString stringWithString:@"Password field is blank"] delegate:nil 
										   cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[blankFieldAlert show];
		[blankFieldAlert release];
	}
	else {
		currentInfo.username = usernameField.text;
		currentInfo.password = passwordField.text;
		currentInfo.siteType = siteType;
		
		if (siteType == BLOGGER) {
			addButton.hidden = YES;
			addWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			addWheel.center = addButton.center;
			[self.view addSubview:addWheel];
			[addWheel startAnimating];
			//authenticate with ClientLogin service
			BloggerRequest *blogReq = [[BloggerRequest alloc] init];
			[blogReq authenticateWithUsername:usernameField.text password:passwordField.text delegate:self];
		}
		else if (siteType == PICASA) {
			addButton.hidden = YES;
			addWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			addWheel.center = addButton.center;
			[self.view addSubview:addWheel];
			[addWheel startAnimating];
			//authenticate with ClientLogin service
			PicasaRequest *picasaReq = [[PicasaRequest alloc] init];
			[picasaReq authenticateWithUsername:usernameField.text password:passwordField.text delegate:self];
		} else if (siteType == FOURSQUARE) {
			[[[VariableStore sharedInstance] accounts] addObject:currentInfo];		
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(openFoursquareSettings)];
			//[[[[UIApplication sharedApplication] delegate] detailViewController].popoverController dismissPopoverAnimated:YES];
		}
		else {
			[[[VariableStore sharedInstance] accounts] addObject:currentInfo];		
			[[[[[self navigationController] viewControllers] objectAtIndex:0] tableView] reloadData];
			[self.navigationController popToRootViewControllerAnimated:YES];
		}
	}
	[currentInfo release];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	self.title = @"Add Account";
	blank = usernameField.text;
	[self loadSiteView];
	
	usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 85, 21)];
	[self.view addSubview:usernameLabel];
	if (siteType == TWITTER) {
		[usernameLabel setText:@"Username"];
	} else {
		[usernameLabel setText:@"Email"];
	}
	[super viewDidLoad];
}


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)loadSiteView
{
	UIImageView *bulletView;
	UILabel *viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 36)];
	viewLabel.font = [viewLabel.font fontWithSize:20];
	viewLabel.backgroundColor = [UIColor clearColor];
	switch (siteType) {
		case TWITTER:
			bulletView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Twitter Icon.png"]];
			viewLabel.text = @"Twitter";
			break;
		case TUMBLR:
			bulletView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Tumblr Icon.png"]];
			viewLabel.text = @"Tumblr";
			break;
		case FOURSQUARE:
			bulletView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Foursquare Icon.png"]];
			viewLabel.text = @"Foursquare";
			break;
		case BLOGGER:
			bulletView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Blogger Icon.png"]];
			viewLabel.text = @"Blogger";
			break;
		case PICASA:
			bulletView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Picasa Icon.png"]];
			viewLabel.text = @"Picasa";
			break;
		default:
			break;
	}
	bulletView.frame = CGRectMake(0, 0, 36, 36);
	[bulletView addSubview:viewLabel];
	viewLabel.frame = CGRectMake(40, 0, 200, 36);
	concatView = [[UIView alloc] initWithFrame:CGRectMake(18, 210, 240, 36)];
	[concatView addSubview:bulletView];
	[concatView addSubview:viewLabel];
	[self.view addSubview:concatView];
	[viewLabel release];
	[bulletView release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[alertView release];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

-(void)parseBlogList:(NSData *)listData
{
	//NSLog(@"parsing blog list:%@", [[[NSString alloc] initWithData:listData encoding:NSUTF8StringEncoding] autorelease]);
	listParser = [[NSXMLParser alloc] initWithData:listData];
	blogListDict = [[NSMutableDictionary alloc] init];
	isBlog = YES;
	[listParser setDelegate:self];
	if ([listParser parse]) {
		NSLog(@"Blogger Parsing succeeded");
	} else {
		NSLog(@"Blogger Parsing failed");
		NSLog(@"%@", [listParser parserError]);
	}
	[listParser release];
}

-(void)parseAlbumList:(NSData *)listData forUsername:(NSString *)username
{
	listParser = [[NSXMLParser alloc] initWithData:listData];
	blogListDict = [[NSMutableDictionary alloc] init];
	[blogListDict setObject:username forKey:@"CURRENTUN"];
	isBlog = NO;
	[listParser setDelegate:self];
	if ([listParser parse]) {
		NSLog(@"Picasa Parsing succeeded");
	} else {
		NSLog(@"Picasa Parsing failed");
		NSLog(@"%@", [listParser parserError]);
	}
	[listParser release];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{	
	// most of the blogger objects will just be used for picasa as well, just for ease of programming
	blogNum = 0;
	inEntry = NO;
}

- (void)parser:(NSXMLParser *)parser 
		didStartElement:(NSString *)elementName 
		namespaceURI:(NSString *)namespaceURI 
		qualifiedName:(NSString *)qualifiedName 
		attributes:(NSDictionary *)attributeDict
{
	currentXMLElement = [elementName retain];
	if ([elementName isEqualToString:@"entry"]) {
		inEntry = YES;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (isBlog) {
		if ([currentXMLElement isEqualToString:@"title"]) {
			if (inEntry == NO) {
				[blogListDict setObject:string forKey:@"LISTTITLE"];
			} else {
				[blogListDict setObject:string forKey:[NSString stringWithFormat:@"BLOGNAME%d", blogNum]];
			}
		}
		if ([currentXMLElement isEqualToString:@"id"]) {
			if (inEntry) {
				[blogListDict setObject:[[string componentsSeparatedByString:@"blog-"] objectAtIndex:1] forKey:[NSString stringWithFormat:@"BLOGID%d", blogNum]];
			}
		}
	} else {
		if ([currentXMLElement isEqualToString:@"name"]) {
			[blogListDict setObject:string forKey:@"AUTHORNAME"];
		}
		if ([currentXMLElement isEqualToString:@"title"] && inEntry) {
			[blogListDict setObject:string forKey:[NSString stringWithFormat:@"ALBUMNAME%d", blogNum]];
		}
		if ([currentXMLElement isEqualToString:@"id"]) {
			if (inEntry) {
				[blogListDict setObject:string forKey:[NSString stringWithFormat:@"ALBUMID%d", blogNum]];
			}
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"entry"]) {
		inEntry = NO;
	}
	if ([elementName isEqualToString:@"title"] && inEntry) {
		blogNum++;
	}
	currentXMLElement = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	NSLog(@"%@", blogListDict);
	if (isBlog) {
		//push view controller onto stack, load data into it, make delegate save blog name and ID (plus standard data
		//like un, pw, type and selected), create new uitableviewcell, and pop to root controller
		blogListViewController = [[BlogListViewController alloc] init];
		blogListViewController.blogList = [blogListDict copy];
		[blogListDict release];
	
		AccountInfo *currentInfo = [[AccountInfo alloc] init];
		currentInfo.username = usernameField.text;
		currentInfo.password = passwordField.text;
		currentInfo.siteType = BLOGGER;
		blogListViewController.currentInfo = currentInfo;
		[currentInfo release];
		[addWheel release];
		addButton.hidden = NO;
		[self.navigationController pushViewController:blogListViewController animated:YES];
	} else {	// picasa
		//push view controller onto stack, load data into it, make delegate save blog name and ID (plus standard data
		//like un, pw, type and selected), create new uitableviewcell, and pop to root controller		
		AccountInfo *currentInfo = [[AccountInfo alloc] init];
		currentInfo.username = usernameField.text;
		currentInfo.password = passwordField.text;
		currentInfo.siteType = PICASA;
		[[[VariableStore sharedInstance] accounts] addObject:currentInfo];
		[currentInfo release];
		
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(openPicasaSettingsWithList:) withObject:blogListDict];
		[addWheel release];
		addButton.hidden = NO;
		[[[[self.navigationController.viewControllers objectAtIndex:0] detailViewController] popoverController] dismissPopoverAnimated:YES];
	}
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }*/

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


#pragma mark -
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
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
	[currentXMLElement release];
	[blogListDict release];
	if (siteType == BLOGGER) {
		[blogListViewController release];
	}
	[listParser release];
	[concatView release];
	[addButton release];
	[usernameField release];
	[passwordField release];
    [usernameLabel release];
	
	[super dealloc];
}


@end

