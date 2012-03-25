//
//  DetailViewController.m
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//

#import "DetailViewController.h"


@implementation DetailViewController

@synthesize navigationBar, popoverController, detailItem, statusText, 
				arrowImage, statusImage, swipeRecognizer, rightMenuNavController,
				titleField, backgroundImage, sentArray, optionButton, menuViewController,
				rightPopoverController, sentString, photo;


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([statusText isFirstResponder] || [titleField isFirstResponder]) {
		if (CGRectContainsPoint(backgroundImage.frame, [[touches anyObject] locationInView:self.view])) {
			[statusText resignFirstResponder];
			[titleField resignFirstResponder];
		}
	}
}

-(void)addToSentList:(NSUInteger)siteNum username:(NSString *)un succeeded:(BOOL)success
{	
	//NSLog(@"added: %@ to sent list", [NSString stringWithCString:siteNames[siteNum] encoding:NSUTF8StringEncoding]);
	if (success) {
		[sentArray addObject:[NSString stringWithFormat:@"- Sent to %@!\n", [NSString stringWithCString:siteNames[siteNum] encoding:NSUTF8StringEncoding]]];
	} else {
		[sentArray addObject:[NSString stringWithFormat:@"- Send to %@ (%@) Failed. Try re-entering your account info.\n", 
							  [NSString stringWithCString:siteNames[siteNum] encoding:NSUTF8StringEncoding], un]];
	}
	if ([sentArray count] == [[[[UIApplication sharedApplication] delegate] performSelector:@selector(rootViewCellsSelected)] unsignedIntegerValue]) {
		for (int i = 0; i < [sentArray count]; i++) {
			[sentString appendString:[sentArray objectAtIndex:i]];
		}
		
		[sendingSpinner stopAnimating];
		[sendingSpinner release];
		
		UIAlertView *sentView = [[UIAlertView alloc] initWithTitle:nil message:sentString delegate:nil 
												 cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		
		[sentArray removeAllObjects];
		[sentString setString:@""];
		
		[sentView dismissWithClickedButtonIndex:0 animated:YES];
		[sentView show];
		[sentView release];
	}
}

- (void)sendUpdate
{	
	sendingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	sendingSpinner.frame = CGRectMake(0, 0, 50, 50);
	sendingSpinner.center = self.view.center;
	[self.view addSubview:sendingSpinner];
	[sendingSpinner startAnimating];
	
	BOOL twitterSelected = NO;
	for (int i = 0; i < [[[VariableStore sharedInstance] accounts] count]; i++) {
		if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == TWITTER && 
			[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] selected] == YES) {
			twitterSelected = YES;
		}
	}
	if (twitterSelected == YES && statusText.text.length > 140 && !useTwitlonger) {
		UIAlertView *charLimitAlert = [[[UIAlertView alloc] initWithTitle:@"Character Limit Exceeded" 
																 message:@"You are sending to Twitter but have exceeded their 140 character limit.You can either trim the message to 140 characters, or use TwitLonger.com's API to include a link to the full tweet." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"TwitLonger", @"Trim", nil] autorelease];
		[charLimitAlert show];
		[sendingSpinner stopAnimating];
		[sendingSpinner release];
		return;
	}
	useTwitlonger = NO;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	BOOL internetConnected = YES;
	NSUInteger accountsSelected = 0;
	
	Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))	//if internet is not connected
	{
		UIAlertView *sendingView = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"You require an internet connection via WiFi or cellular network for the message to send." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[sendingView show];
		[sendingView release];
		internetConnected = NO;
		
		[sendingSpinner stopAnimating];
		[sendingSpinner release];
	}
	else {		
		for (int i = 0; i < [[[VariableStore sharedInstance] accounts] count]; i++) {
			if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] selected] == YES) {
								
				if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == TWITTER) {
					
					[VariableStore sharedInstance].currentName = [[NSString alloc] initWithString:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username]];
					
					TwitterRequest *twitReq = [[TwitterRequest alloc] init];
					twitReq.username = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username];
					twitReq.password = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] password];
									
					[twitReq statuses_update:statusText.text images:(NSArray *)[[VariableStore sharedInstance] images] requestDelegate:self];
					[twitReq release];
				}
				if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == FACEBOOK) {
					if ([[[VariableStore sharedInstance] images] count] > 0) {
						[fbHelper setFBStatus:statusText.text withImages:[[VariableStore sharedInstance] images] title:titleField.text delegate:self];
					} else {
						NSLog(@"Facebook");
						fbHelper.status = statusText.text;
					}
				}
				if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == TUMBLR) {
					TumblrRequest *tumblrReq;
					tumblrReq = [[TumblrRequest alloc] init];
					tumblrReq.username = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username];
					tumblrReq.password = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] password];
					
					if ([[[VariableStore sharedInstance] images] count] > 0) {
						[tumblrReq statuses_update:statusText.text title:titleField.text 
											 image:[[[VariableStore sharedInstance] images] objectAtIndex:0]delegate:self];
					} else {
						[tumblrReq statuses_update:statusText.text title:titleField.text 
											 image:nil delegate:self];
					}
					[tumblrReq release];
				}	
				if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == FOURSQUARE) {
					FoursquareRequest *fsReq;
					fsReq = [[FoursquareRequest alloc] init];
					fsReq.username = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username];
					fsReq.password = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] password];
										
					[fsReq statuses_update:statusText.text delegate:self requestSelector:nil];
					//[fsReq release];
				}	
				if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == BLOGGER) {
					BloggerRequest *blogReq;
					blogReq = [[BloggerRequest alloc] init];
					blogReq.username = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username];
					blogReq.password = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] password];
					[blogReq statuses_update:statusText.text title:titleField.text 
									  blogID:[[[[VariableStore sharedInstance] accounts] objectAtIndex:i] blogID]
															 delegate:self];
					//[blogReq autorelease];
				}	
				if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == PICASA) {
					if ([[[VariableStore sharedInstance] images] count] > 0) {
						PicasaRequest *picasaReq;
						picasaReq = [[PicasaRequest alloc] init];
						picasaReq.username = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username];
						picasaReq.password = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] password];
						[picasaReq statuses_update:statusText.text title:titleField.text images:[[VariableStore sharedInstance] images]
										   albumID:[[NSUserDefaults standardUserDefaults] stringForKey:
													[NSString stringWithFormat:@"MonarchPicasaAlbumID%@", 
													 [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username]]] delegate:self];
						[picasaReq release];
					} else {
						UIAlertView *noImagesAlert = [[[UIAlertView alloc] initWithTitle:@"No Images Attached" 
																				message:@"Picasa does not support updates with no images attached" 
																			   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
						internetConnected = NO;
						[noImagesAlert show];
					}
				}	
				if ([[[[VariableStore sharedInstance] accounts] objectAtIndex:i] siteType] == LINKEDIN) {
					LinkedinRequest *linkReq;
					linkReq = [[LinkedinRequest alloc] init];
					linkReq.username = [[[[VariableStore sharedInstance] accounts] objectAtIndex:i] username];
					[linkReq statuses_update:statusText.text delegate:self];
					[linkReq release];
				}	
				accountsSelected++;
			}
		}
	}
	if (internetConnected) {
		if (accountsSelected == 0) {
			UIAlertView *sendingView = [[[UIAlertView alloc] initWithTitle:@"No Destination" 
																   message:@"You haven't selected any destination sites to send to" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
			[sendingView show];
			[sendingSpinner stopAnimating];
			[sendingSpinner release];
		}
		else {
			statusText.text = nil;
			titleField.text = nil;
		}
	}
	if ([[[VariableStore sharedInstance] images] count] > 0) [self removeImages];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self flickPaperInDirection:BACK];
}

- (void)confirmSend
{	
	//ask user to confirm (UIActionSheet) and if they hit yes, send, otherwise cancel and return paper to original position
	UIActionSheet *confirmSheet = [[UIActionSheet alloc]
					initWithTitle:@"Send Update?"
					delegate:self 
					cancelButtonTitle:@"Cancel"
					destructiveButtonTitle:nil 
					otherButtonTitles:@"Send", nil];
		
	confirmSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[confirmSheet showInView:self.view];
	[confirmSheet release];
}

- (void)flickPaperInDirection:(BOOL)dir;
{
	CGRect imageFrame;

	[self textViewDidChange:statusText];	//update character count
	
	[statusText resignFirstResponder];		//hide keyboard if it is up
	[titleField resignFirstResponder];
	[UIView beginAnimations:@"flickPaper" context:nil];
	[UIView setAnimationDuration:0.65];
	[UIView setAnimationDelegate:self];
	
	if (lastOrientation == landscapeLeft ||
		lastOrientation == landscapeRight) {
		if (dir == AWAY) {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MonarchDontConfirmSend"]) {
				[UIView setAnimationDidStopSelector:@selector(sendUpdate)];	//perform method sendUpdate when animation stops
			} else {
				[UIView setAnimationDidStopSelector:@selector(confirmSend)];	//perform method confirmSend when animation stops
			}
				
			imageFrame = statusImage.frame;
			imageFrame.origin.x += 800;
			statusImage.frame = imageFrame;
			
			//move statusText
			imageFrame = statusText.frame;
			imageFrame.origin.y = 127;
			imageFrame.origin.x = 920;
			statusText.frame = imageFrame;
			
			if (imagesPresent == YES) {
				//move polaroids et all
				imageFrame = polaroids.frame;
				imageFrame.origin.x += 800;
				polaroids.frame = imageFrame;
				imageFrame = photo.frame;
				imageFrame.origin.x += 800;
				photo.frame = imageFrame;
				imageFrame = paperclip.frame;
				imageFrame.origin.x += 800;
				paperclip.frame = imageFrame;
			}
		}
		else {	//dir = back
			imageFrame = statusImage.frame;
			imageFrame.origin.x = -30;
			statusImage.frame = imageFrame;
			
			//move statusText
			imageFrame = statusText.frame;
			imageFrame.origin.y = 127;
			imageFrame.origin.x = 120;
			statusText.frame = imageFrame;
			
			if (imagesPresent == YES) {
				//move polaroids et all
				imageFrame = polaroids.frame;
				imageFrame.origin.x = 15;
				imageFrame.origin.y = self.view.frame.size.height / 1.7;
				polaroids.frame = imageFrame;
			
				imageFrame = paperclip.frame;
				imageFrame.origin.x = 2;
				imageFrame.origin.y = self.view.frame.size.height/1.4;
				paperclip.frame = imageFrame;
				
				imageFrame = photo.frame;
				imageFrame.size.width = 196;
				imageFrame.size.height = 185;
				imageFrame.origin.x = polaroids.frame.origin.x + 32;
				imageFrame.origin.y = polaroids.frame.origin.y + 27;
				photo.frame = imageFrame;
			}
		}
		//move titleField
		imageFrame = titleField.frame;
		imageFrame.origin = statusImage.frame.origin;
		imageFrame.origin.y += 50;
		imageFrame.origin.x = statusText.frame.origin.x;
		titleField.frame = imageFrame;

		if (imagesPresent == YES) {
			// move button
			imageFrame = removeImage.frame;
			imageFrame.origin.x = polaroids.frame.origin.x + 35;
			imageFrame.origin.y = polaroids.frame.origin.y + 230;
			removeImage.frame = imageFrame;
		}
	}
	else {
		if (dir == AWAY) {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MonarchDontConfirmSend"]) {
				[UIView setAnimationDidStopSelector:@selector(sendUpdate)];	//perform method sendUpdate when animation stops
			} else {
				[UIView setAnimationDidStopSelector:@selector(confirmSend)];	//perform method confirmSend when animation stops
			}
		
			imageFrame = statusImage.frame;
			imageFrame.origin.y -= 964;
			statusImage.frame = imageFrame;
			
			if (imagesPresent == YES) {
				//move polaroids et all
				imageFrame = polaroids.frame;
				imageFrame.origin.y -= 964;
				polaroids.frame = imageFrame;
				imageFrame = photo.frame;
				imageFrame.origin.y -= 964;
				photo.frame = imageFrame;
				imageFrame = paperclip.frame;
				imageFrame.origin.y -= 964;
				paperclip.frame = imageFrame;
			}
		}
		else {	//dir = back
			imageFrame = statusImage.frame;
			imageFrame.origin.y = 227;
			statusImage.frame = imageFrame;
			
			if (imagesPresent == YES) {
				//move polaroids et all
				imageFrame = polaroids.frame;
				imageFrame.origin.x = 50;
				imageFrame.origin.y = self.view.frame.size.height / 1.5;
				polaroids.frame = imageFrame;
			
				imageFrame = paperclip.frame;
				imageFrame.origin.x = 37;
				imageFrame.origin.y = self.view.frame.size.height/1.4;
				paperclip.frame = imageFrame;
				
				imageFrame = photo.frame;
				imageFrame.origin.x = polaroids.frame.origin.x + 32;
				imageFrame.origin.y = polaroids.frame.origin.y + 27;
				photo.frame = imageFrame;
			}
		}	
			//move statusText
		imageFrame = statusText.frame;
		imageFrame.origin = statusImage.frame.origin;
		imageFrame.origin.y += 102;
		imageFrame.origin.x += 166;
		statusText.frame = imageFrame;
			//move titleField
		imageFrame = titleField.frame;
		imageFrame.origin = statusImage.frame.origin;
		imageFrame.origin.y += 54;
		imageFrame.origin.x += 166;
		titleField.frame = imageFrame;
		if (imagesPresent == YES) {
			// move button
			imageFrame = removeImage.frame;
			imageFrame.origin.x = polaroids.frame.origin.x + 35;
			imageFrame.origin.y = polaroids.frame.origin.y + 230;
			removeImage.frame = imageFrame;
		}
	}
	[UIView commitAnimations];
}

//dummy class just for use with initWithTarget:action:, etc...
-(void)flickPaperAway
{
	[self flickPaperInDirection:AWAY];
}

-(void)optionButtonPressed
{
	if (rightPopoverController.popoverVisible) {
		[rightPopoverController dismissPopoverAnimated:YES];
		return;
	} else {
		if (popoverController.popoverVisible) {
			[popoverController dismissPopoverAnimated:YES];
		}
	}
	[statusText resignFirstResponder];
	[titleField resignFirstResponder];
	
	menuViewController = [[MenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
	menuViewController.delegate = self;

	rightMenuNavController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
	if (!rightPopoverController.popoverVisible) {
		[rightPopoverController release];
		rightPopoverController = [[UIPopoverController alloc] initWithContentViewController:rightMenuNavController];
		[rightPopoverController presentPopoverFromBarButtonItem:optionButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	}
}

-(void)removeImages
{
	NSLog(@"button selected");
	[UIView beginAnimations:@"removePolaroids" context:nil];
	[UIView setAnimationDuration:0.5];
	[[[VariableStore sharedInstance] images] removeAllObjects];
	
	polaroids.alpha = 0;
	photo.alpha = 0;
	paperclip.alpha = 0;
	removeImage.alpha = 0;
	
	[UIView commitAnimations];
	 
	polaroids.hidden = YES;
	photo.hidden = YES;
	paperclip.hidden = YES;
	removeImage.hidden = YES;
	
	imagesPresent = NO;
}

- (void) attachImage:(UIImage *)image
{
	NSLog(@"didFinishPickingMediaWithInfo");
	
	NSLog(@"%d", [[[VariableStore sharedInstance] images] count]);
		polaroids.hidden = NO;
		photo.hidden = NO;
		paperclip.hidden = NO;
		removeImage.hidden = NO;
	[[[VariableStore sharedInstance] images] addObject:image];

	polaroids.image = [UIImage imageNamed:@"Polaroids.png"];
	paperclip.image = [UIImage imageNamed:@"Paperclip.png"];
	[photo setImage:[image retain] forState:UIControlStateNormal];
	[image release];
	
	[removeImage setImage:[UIImage imageNamed:@"xButton.png"] forState:UIControlStateNormal];
	[removeImage setImage:[UIImage imageNamed:@"xButton Highlighted.png"] forState:UIControlStateHighlighted];
	removeImage.showsTouchWhenHighlighted = YES;
	if (lastOrientation ==  landscapeRight || 
		lastOrientation ==  landscapeLeft) {
		CGRect imageFrame = polaroids.frame;
		imageFrame.origin.x = 15;
		imageFrame.origin.y = self.view.frame.size.height / 1.7;
		polaroids.frame = imageFrame;
	
		imageFrame = paperclip.frame;
		imageFrame.origin.x = 2;
		imageFrame.origin.y = self.view.frame.size.height/1.4;
		paperclip.frame = imageFrame;
		
		imageFrame = photo.frame;
		imageFrame.size.width = 196;
		imageFrame.size.height = 185;
		imageFrame.origin.x = polaroids.frame.origin.x + 32;
		imageFrame.origin.y = polaroids.frame.origin.y + 27;
		photo.frame = imageFrame;
	}
	else {
		CGRect imageFrame = polaroids.frame;
		imageFrame.origin.x = 50;
		imageFrame.origin.y = self.view.frame.size.height / 1.5;
		polaroids.frame = imageFrame;
		
		imageFrame = paperclip.frame;
		imageFrame.origin.x = 37;
		imageFrame.origin.y = self.view.frame.size.height/1.4;
		paperclip.frame = imageFrame;
		
		imageFrame = photo.frame;
		imageFrame.size.width = 196;
		imageFrame.size.height = 185;
		imageFrame.origin.x = polaroids.frame.origin.x + 32;
		imageFrame.origin.y = polaroids.frame.origin.y + 27;
		photo.frame = imageFrame;
	}
	CGRect imageFrame = removeImage.frame;
	imageFrame.origin.x = polaroids.frame.origin.x + 35;
	imageFrame.origin.y = polaroids.frame.origin.y + 230;
	removeImage.frame = imageFrame;
	[removeImage addTarget:self action:@selector(removeImages)
    forControlEvents:UIControlEventTouchUpInside];
	
	[photo addTarget:self action:@selector(showImageList) forControlEvents:UIControlEventTouchUpInside];
	
	paperclip.alpha = 0;	
	polaroids.alpha = 0;
	photo.alpha = 0;
	removeImage.alpha = 0.5;
		
	[self.view addSubview:polaroids];
	[self.view addSubview:photo];
	[self.view addSubview:paperclip];
	[self.view addSubview:removeImage];
	
	[UIView beginAnimations:@"FadeInPolaroids" context:nil];
	[UIView setAnimationDuration:0.5];
	paperclip.alpha = 1;
	photo.alpha = 1;
	polaroids.alpha = 1;
	removeImage.alpha = 0.8;
	[UIView commitAnimations];
	imagesPresent = YES;
}

- (void)showCodevsMessage {
	NSError **messageError;
	NSString *codevsMessage = [NSString stringWithContentsOfURL:
							   [NSURL URLWithString:@"http://labs.codevs.com/monarch.txt"]
													   encoding:NSUTF8StringEncoding error:messageError];
	if (messageError) 
		return;
	if (codevsMessage.length <= 0)
		return;
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ViewedMessage"] isEqualToString:codevsMessage])
		return;
	
	UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Message from Codevs.com"
														   message:codevsMessage
														  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[messageAlert show];	
	[[NSUserDefaults standardUserDefaults] setObject:codevsMessage forKey:@"ViewedMessage"];
	[messageAlert release];
}

#pragma mark -
#pragma mark NSNotification delegate Method

- (void)didReceiveNotification:(NSNotification *)notification
{
	if ([statusText isFirstResponder]) {
		if (lastOrientation ==  landscapeRight ||
			lastOrientation ==  landscapeLeft) {

			if ([notification name] == UIKeyboardWillShowNotification) {
				CGRect statFrame = [statusText frame];
				statFrame.size.height /= 2.1;
				statusText.frame = statFrame;
				statusText.scrollEnabled = YES;
			}
			if ([notification name] == UIKeyboardWillHideNotification) {
				CGRect statFrame = [statusText frame];
				statFrame.size.height *= 2.1;
				statusText.frame = statFrame;
				statusText.scrollEnabled = NO;
			}	
		}	
		else {
			if ([notification name] == UIKeyboardWillShowNotification) {
				CGRect statFrame = [statusText frame];
				statFrame.size.height /= 1.5;
				statusText.frame = statFrame;
				statusText.scrollEnabled = YES;
			}
			if ([notification name] == UIKeyboardWillHideNotification) {
				CGRect statFrame = [statusText frame];
				statFrame.size.height *= 1.5;
				statusText.frame = statFrame;
				statusText.scrollEnabled = NO;
			}	
		}
	}
}

#pragma mark -
#pragma mark Managing the popover controller

- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
        
        // Update the view.
        navigationBar.topItem.title = [detailItem description];
    }
	
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    } 
}

- (void)showImageList {
	[rightPopoverController presentPopoverFromBarButtonItem:optionButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	[rightPopoverController setContentViewController:menuViewController.navigationController];
	//[menuViewController.navigationController popToRootViewControllerAnimated:NO];
	NSUInteger indexes[2] = {0,1};
	[menuViewController tableView:menuViewController.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
}
	 
#pragma mark -
#pragma mark UITextView Delegate Methods

- (void)textViewDidChange:(UITextView *)textView {
	if (textView == statusText && textView.text.length > 0) {
		navigationBar.topItem.title = [NSString stringWithFormat:@"Monarch | Character Count: %d", textView.text.length];
	}
}

#pragma mark -
#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1 && [alertView.title isEqualToString:@"Character Limit Exceeded"]) {
		useTwitlonger = YES;
		[self sendUpdate];
	} else if (buttonIndex == 2 && [alertView.title isEqualToString:@"Character Limit Exceeded"]) {
		NSRange charRange = {0, 140};
		statusText.text = [statusText.text substringWithRange:charRange];
		[self sendUpdate];
	} else if (buttonIndex == 0 && [alertView.title isEqualToString:@"Character Limit Exceeded"]) {
		[self flickPaperInDirection:BACK];
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet.title == @"Send Update?") {
		if (buttonIndex == 0) {		//clicked send
			[self sendUpdate];
		}
		if (buttonIndex == 1) {		//clicked cancel
			[self flickPaperInDirection:BACK];
		}
	}
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Destination";
    [navigationBar.topItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.popoverController = pc;
}


- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [navigationBar.topItem setLeftBarButtonItem:nil animated:YES];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIDeviceOrientationUnknown) {
		return NO;
	}
	else {
		return YES;
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			lastOrientation = portrait;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			lastOrientation = portraitUpsideDown;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			lastOrientation = landscapeLeft;
			break;
		case UIInterfaceOrientationLandscapeRight:
			lastOrientation = landscapeRight;
			break;
		default:
			break;
	}
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		//rotate to landscape
		CGRect imageFrame;
		
		[UIView beginAnimations:@"rotateToLandscape" context:nil];
		[UIView setAnimationDuration:0.5];
		
		arrowImage.image = [UIImage imageNamed:@"Blue Arrow Sideways.png"];
		imageFrame = arrowImage.frame;
		imageFrame.origin.x = 560;
		imageFrame.origin.y = 280;
		imageFrame.size.height = 180;
		imageFrame.size.width = 140;
		arrowImage.frame = imageFrame;
		
		imageFrame = statusImage.frame;
		imageFrame.origin.x = -30;
		imageFrame.origin.y = 32;
		imageFrame.size.height = 738;
		imageFrame.size.width = 700;
		statusImage.frame = imageFrame;
		
		imageFrame = statusText.frame;
		imageFrame.origin.y = 127;
		imageFrame.origin.x = 120;
		imageFrame.size.width -= 50;
		statusText.frame = imageFrame;
		statusText.font = [UIFont fontWithName:@"Helvetica" size:19];
		
		imageFrame = titleField.frame;
		imageFrame.origin = statusImage.frame.origin;
		imageFrame.origin.x = statusText.frame.origin.x;
		imageFrame.origin.y += 50;
		imageFrame.size.width = statusText.frame.size.width;
		titleField.frame = imageFrame;
		
		//move polaroids et all
		imageFrame = polaroids.frame;
		imageFrame.origin.x = 15;
		imageFrame.origin.y = 440;
		polaroids.frame = imageFrame;
		
		imageFrame = paperclip.frame;
		imageFrame.origin.x = 2;
		imageFrame.origin.y = 534;
		paperclip.frame = imageFrame;
		
		imageFrame = photo.frame;
		imageFrame.size.width = 196;
		imageFrame.size.height = 185;
		imageFrame.origin.x = polaroids.frame.origin.x + 32;
		imageFrame.origin.y = polaroids.frame.origin.y + 27;
		photo.frame = imageFrame;
		
		// move button
		imageFrame = removeImage.frame;
		imageFrame.origin.x = polaroids.frame.origin.x + 35;
		imageFrame.origin.y = polaroids.frame.origin.y + 230;
		removeImage.frame = imageFrame;
		
		[UIView commitAnimations];
		
		swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	}
	else 
	{
		//rotate to portrait
		CGRect imageFrame;
		
		[UIView beginAnimations:@"rotateToPortrait" context:nil];
		[UIView setAnimationDuration:duration];
		
		arrowImage.image = [UIImage imageNamed:@"Blue Arrow Perspective.png"];
		
		//move arrow
		imageFrame = arrowImage.frame;
		imageFrame.origin.x = 271;
		imageFrame.origin.y = 70;
		imageFrame.size.width = 226;
		imageFrame.size.height = 160;
		arrowImage.frame = imageFrame;
		
		//move paper
		imageFrame = statusImage.frame;
		imageFrame.origin.x = 0;
		imageFrame.origin.y = 227;
		imageFrame.size.height = 777;
		imageFrame.size.width = 768;
		statusImage.frame = imageFrame;
		
		//move body
		imageFrame = statusText.frame;
		imageFrame.size.width = 504;
		imageFrame.origin.y = 329;
		imageFrame.origin.x = 166;
		statusText.frame = imageFrame;
		statusText.font = [UIFont fontWithName:@"Helvetica" size:20];
		
		//move title
		imageFrame = titleField.frame;
		imageFrame.origin = statusImage.frame.origin;
		imageFrame.origin.x += 166;
		imageFrame.origin.y += 54;
		imageFrame.size.width = statusText.frame.size.width;
		titleField.frame = imageFrame;
		
		//move polaroids et all
		imageFrame = polaroids.frame;
		imageFrame.origin.x = 50;
		imageFrame.origin.y = 672;
		polaroids.frame = imageFrame;
		
		imageFrame = paperclip.frame;
		imageFrame.origin.x = 37;
		imageFrame.origin.y = 720;
		paperclip.frame = imageFrame;
		
		imageFrame = photo.frame;
		imageFrame.origin.x = polaroids.frame.origin.x + 32;
		imageFrame.origin.y = polaroids.frame.origin.y + 27;
		photo.frame = imageFrame;
		
		// move button
		imageFrame = removeImage.frame;
		imageFrame.origin.x = polaroids.frame.origin.x + 35;
		imageFrame.origin.y = polaroids.frame.origin.y + 230;
		removeImage.frame = imageFrame;
		
		[UIView commitAnimations];
		
		swipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
	}
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

#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
	[self addToSentList:TWITTER username:[VariableStore sharedInstance].currentName succeeded:YES];
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
	[self addToSentList:TWITTER username:[VariableStore sharedInstance].currentName succeeded:NO];
}

- (void)twitpicDidFinishUpload:(NSString *)response {
	NSLog(@"twitpicDidFinishUpload: response = %@", response);
}

- (void)twitpicDidFailUpload:(NSString *)error {
	
}

#pragma mark -
#pragma mark Facebook Support
- (void)session:(FBSession *)session didLogin:(FBUID)uid {
}

-(void)status:(MOFBStatus*)aMofbStatus DidFailWithError:(NSError*)error
{
	[self addToSentList:FACEBOOK username:nil succeeded:NO];
}

-(void)statusDidUpdate:(id)sender {
	[self addToSentList:FACEBOOK username:nil succeeded:YES];
}

#pragma mark -
#pragma mark View lifecycle

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
	 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:nil object:nil];
	 	 	 
	 sentString = [[NSMutableString alloc] init];
	 sentArray = [[NSMutableArray alloc] init];
	 [VariableStore sharedInstance].images = [[NSMutableArray alloc] init];
	 [VariableStore sharedInstance].twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: 
													 [[[[UIApplication sharedApplication] delegate] performSelector:@selector(rootViewController)] performSelector:@selector(chooseController)]];
	 [[VariableStore sharedInstance] twitterEngine].consumerKey = TwitterConsumerKey;
	 [[VariableStore sharedInstance] twitterEngine].consumerSecret = TwitterConsumerSecret;
	
	 // load auto-correction defaults
	 if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MonarchDontAutoCorrect"] == YES) {
		 statusText.autocorrectionType = UITextAutocorrectionTypeNo;
		 statusText.autocapitalizationType = UITextAutocapitalizationTypeNone;
		 titleField.autocorrectionType = UITextAutocorrectionTypeNo;
		titleField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	 } else {
		 statusText.autocorrectionType = UITextAutocorrectionTypeYes;
		 statusText.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		 titleField.autocorrectionType = UITextAutocorrectionTypeYes;
		 titleField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	 }
	 
	 siteNames[TWITTER] = "Twitter";
	 siteNames[TUMBLR] = "Tumblr";
	 siteNames[FOURSQUARE] = "Foursquare";
	 siteNames[BLOGGER] = "Blogger";
	 siteNames[FACEBOOK] = "Facebook";
	 siteNames[PICASA] = "Picasa";
	 siteNames[LINKEDIN] = "Linkedin";
	 
	 //facebook shtuff
	 fbHelper = [[MOFBHelper alloc] init];
	 fbHelper.delegate = self;
	 
	 optionButton.target = self;
	 optionButton.action = @selector(optionButtonPressed);
	 
	 statusText.backgroundColor = [UIColor clearColor];	//set text box transparent
	 backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];	 //initialize background image
	 backgroundImage.frame = [[self view] frame];	//make it the size and location of the view
	 [[self view] insertSubview:backgroundImage atIndex:0];	//put it at the bottom of the stack
	 
	 //set up swipe gesture recognizer
	 swipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flickPaperAway)] autorelease];
	 if (lastOrientation == landscapeLeft || 
		 lastOrientation ==  landscapeRight) {
		 swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	 }
	 else {
		 swipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
		 statusText.font = [UIFont fontWithName:@"Helvetica" size:20];
	 }
	 
//	 [statusImage addGestureRecognizer:swipeRecognizer];
	 [statusText addGestureRecognizer:swipeRecognizer];
	 
	 removeImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 19, 19)];
	 polaroids = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Polaroids.png"]];
	 photo     = [[UIButton alloc] init];
	 paperclip = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Paperclip.png"]];
	 
	 [super viewDidLoad];
 }
 

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */

 - (void)viewDidAppear:(BOOL)animated {	 
	 [self showCodevsMessage];

	 [super viewDidAppear:animated];
 }
 
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


- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
	self.arrowImage = nil;
	self.statusImage = nil;
	self.backgroundImage = nil;
}


#pragma mark -
#pragma mark Memory management


 - (void)didReceiveMemoryWarning {
 // Releases the view if it doesn't have a superview.
 [super didReceiveMemoryWarning];
 
 // Release any cached data, images, etc that aren't in use.
 }
 

- (void)dealloc {
    [popoverController release];
    [navigationBar release];
	[detailItem release];
	
	[[VariableStore sharedInstance].images release];
	
	[fbHelper release];
	[sentArray release];
	[sentString release];
	
	[statusText release];
	[statusImage release];
	[arrowImage release];
	[backgroundImage release];
	[titleField release];
	
	[polaroids release];
	[photo release];
	[paperclip release];
	[removeImage release];
	
	[swipeRecognizer release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

@end
