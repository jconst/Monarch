//
//  FoursquareSettingsViewController.m
//  Monarch
//
//  Created by Joseph Constan on 7/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FoursquareSettingsViewController.h"


@implementation FoursquareSettingsViewController

@synthesize typePicker, venuePicker, venueDictionary, venueLabel, saveButton;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"locationManager didFailWithError:%@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if (shouldSendMessage == YES) {
		NSMutableURLRequest *venueRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:
												[NSString stringWithFormat:@"http://api.foursquare.com/v1/venues.json?geolat=%f&geolong=%f&geohacc=%f&geovacc=%f&geoalt=%f", 
												 newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.horizontalAccuracy, newLocation.verticalAccuracy, newLocation.altitude]]];
	
		[venueRequest setValue:@"Monarch-iPad:1.0" forHTTPHeaderField:@"User-Agent"];
		[venueRequest setHTTPMethod:@"GET"];
	
		NSLog(@"%@, headers = %@", venueRequest, [venueRequest allHTTPHeaderFields]);
	
		venueConnection = [[NSURLConnection alloc] initWithRequest:venueRequest delegate:self];
		shouldSendMessage = NO;
		[clm stopUpdatingLocation];
	}
	shouldSendMessage = YES;
}

#pragma mark -
#pragma mark Overridden Methods
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Foursquare Settings";

	venuePicker.hidden = YES;
	
	venueWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	venueWheel.center = venuePicker.center;
	[self.view addSubview:venueWheel];
	[venueWheel startAnimating];
	
	shouldSendMessage = NO;
	
	clm = [[CLLocationManager alloc] init];
	clm.purpose = @"Monarch requires your location for use of Foursquare services";
	clm.delegate = self;
	clm.distanceFilter = kCLDistanceFilterNone;
	clm.desiredAccuracy = kCLLocationAccuracyBest;
	if ([clm locationServicesEnabled]) {
		[clm startUpdatingLocation];
	} else {
		NSLog(@"CLLocation services unavailable");
	}
	 
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated
{
	if ([[[UIApplication sharedApplication] delegate] detailViewController].popoverController.popoverVisible) {
		[[[[UIApplication sharedApplication] delegate] detailViewController].popoverController dismissPopoverAnimated:YES];
	}
	[typePicker selectRow:VENUECHECKIN - 1 inComponent:0 animated:NO];	//set Venue Check-In to selected
	
	[super viewWillAppear:animated];
}

- (IBAction)saveButtonPressed
{
	[[NSUserDefaults standardUserDefaults] setObject:[venueDictionary objectForKey:[NSString stringWithFormat:@"VenueID%d", [venuePicker selectedRowInComponent:0]]]
											  forKey:@"MonarchFoursquareVenueID"];
	[[NSUserDefaults standardUserDefaults] setInteger:([typePicker selectedRowInComponent:0]+1) forKey:@"MonarchFoursquarePostType"];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIPickerView Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return (pickerView == venuePicker) ? 10 : 4;
}

#pragma mark -
#pragma mark UIPickerView Delegate Methods
/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (pickerView == venuePicker) {
		return nil;
	}
	else {		//typePicker
		switch (row) {
			case 0:
				return @"Shout (With Location)";
				break;
			case 1:
				return @"Shout (No Location)";
				break;
			case 2:
				return @"Venue Check-In";
				break;
			case 3:
				return @"Venue Tip";
				break;
			case 4:
				return @"Venue To-Do";
				break;
			default:
				return nil;
				break;
		}
	}
}*/

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	if (pickerView == venuePicker) {
		if (!venueDictionary) {
			return nil;
		}
		UIImageView *bulletView;
		UILabel *viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 36)];
		viewLabel.font = [viewLabel.font fontWithSize:20];
		viewLabel.text = [venueDictionary objectForKey:[NSString stringWithFormat:@"VenueName%d", row]];
		viewLabel.backgroundColor = [UIColor clearColor];
		
		if ([venueDictionary objectForKey:[NSString stringWithFormat:@"VenueImage%d", row]]) {
			bulletView = [[UIImageView alloc] initWithImage:[venueDictionary objectForKey:[NSString stringWithFormat:@"VenueImage%d", row]]];
		
			bulletView.frame = CGRectMake(0, 0, 36, 36);
			[bulletView addSubview:viewLabel];
			viewLabel.frame = CGRectMake(40, 0, 200, 36);
			UIView *concatView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 36)];
			[concatView addSubview:bulletView];
			[concatView addSubview:viewLabel];
			return concatView;
		}
		else {
			return viewLabel;
		}

	}
	else {
		UILabel *viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 36)];
		viewLabel.font = [viewLabel.font fontWithSize:18];
		viewLabel.backgroundColor = [UIColor clearColor];
		
		switch (row) {
			case 0:
				viewLabel.text = @"Shout (No Location)";
				break;
			case 1:
				viewLabel.text = @"Venue Check-In";
				break;
			case 2:
				viewLabel.text = @"Venue Tip";
				break;
			case 3:
				viewLabel.text = @"Venue To-Do";
				break;
			default:
				break;
		}
		return viewLabel;
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[UIView beginAnimations:@"venuePickerShowOrHide" context:nil];
	[UIView setAnimationDuration:0.5];
	
	if (pickerView == typePicker) {
		if (row == 0 || row == 1) {
			venuePicker.alpha = 0;
			venueLabel.alpha = 0;
		
			CGRect buttonFrame = saveButton.frame;
			buttonFrame.origin.y = 289;
			saveButton.frame = buttonFrame;
		}
		else {
			venuePicker.alpha = 1;
			venueLabel.alpha = 1;
			
			CGRect buttonFrame = saveButton.frame;
			buttonFrame.origin.y = 550;
			saveButton.frame = buttonFrame;
		}
	}
	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSArray *venueArray = [dataString componentsSeparatedByString:@"},{"];
	venueDictionary = [[NSMutableDictionary alloc] initWithCapacity:30];
	
	if ([dataString rangeOfString:@"\"venues\":"].location != NSNotFound) {
		for (int i=0; i < 10; i++) {
			if (i < [venueArray count]) {
				// parse JSON response
				NSString *component = [venueArray objectAtIndex:i];
				NSLog(@"%@", component);
				[venueDictionary setObject:[[[[component componentsSeparatedByString:@"id\":"] objectAtIndex:1] 
														componentsSeparatedByString:@",\"name\":"] objectAtIndex:0]
									forKey:[NSString stringWithFormat:@"VenueID%d", i]];
				[venueDictionary setObject:[[[[component componentsSeparatedByString:@"\"name\":\""] objectAtIndex:1]
														componentsSeparatedByString:@"\",\""] objectAtIndex:0]
									forKey:[NSString stringWithFormat:@"VenueName%d", i]];
				if ([component rangeOfString:@"iconurl"].location != NSNotFound) {
					[venueDictionary setObject:[UIImage imageWithData:
												[NSData dataWithContentsOfURL:
												 [NSURL URLWithString:[[[[component componentsSeparatedByString:@"iconurl\":\""] objectAtIndex:1]
																				componentsSeparatedByString:@"\"},"] objectAtIndex:0]]]]
										forKey:[NSString stringWithFormat:@"VenueImage%d", i]];
				}
			}
		}
		NSLog(@"%@", venueDictionary);
		if ([typePicker selectedRowInComponent:0] != 0) {
			[venuePicker reloadComponent:0];
			venuePicker.hidden = NO;
			[venueWheel removeFromSuperview];
			[venueWheel release];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connection didReceiveResponse:%d", [(NSHTTPURLResponse *)response statusCode]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"connectionDidFinishLoading");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"connection didFailWithError:%@ %@", [error userInfo], error);
	if ([[[error userInfo] objectForKey:@"NSLocalizedDescription"] isEqualToString:@"no Internet connection"]) {
		[venueWheel release];
		UITextView *errorText = [[[UITextView alloc] initWithFrame:venuePicker.frame] autorelease];
		errorText.text = @"Cannot load venue list - No Internet Connection";
		errorText.font = [errorText.font fontWithSize:16];
		[self.view addSubview:errorText];
	}
}

#pragma mark -
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}

#pragma mark -
#pragma mark Memory Functions
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[clm release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
