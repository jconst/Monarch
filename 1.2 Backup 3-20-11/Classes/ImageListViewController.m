    //
//  ImageListViewController.m
//  Monarch
//
//  Created by Joseph Constan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageListViewController.h"
#import "ASIFormDataRequest.h"
#import "UIImage+Extras.h"


@implementation ImageListViewController

@synthesize imagesScroll, isEditing, instructLabel;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)removeButtonPressed:(id)sender
{
	[UIView beginAnimations:@"deleteImage" context:nil];
	[UIView setAnimationDuration:0.4];
	 
	for (int i = 0; i < [images count]; i++) {
		if (CGRectContainsPoint([[images objectAtIndex:i] frame], [sender frame].origin)) {
			// remove from data source
			if (i == [images count] - 1 && [images count] != 1) {
				[[[[[self.navigationController viewControllers] objectAtIndex:0] delegate] photo] 
				 setImage:[[[VariableStore sharedInstance] images] objectAtIndex:i-1] forState:UIControlStateNormal];
			}
			[[[VariableStore sharedInstance] images] removeObjectAtIndex:i];
			[[images objectAtIndex:i] removeFromSuperview];
			[images removeObjectAtIndex:i];
			/*// find last button
			NSUInteger index = 0;
			for (int i = 1; i < [buttons count]; i++) {
				if ([[buttons objectAtIndex:i] frame].origin.x > [[buttons objectAtIndex:index] frame].origin.x ||
					[[buttons objectAtIndex:i] frame].origin.y > [[buttons objectAtIndex:index] frame].origin.y) {
					index = i;
				}
			}*/
			[[buttons lastObject] removeFromSuperview];
			[buttons removeObject:[buttons lastObject]];
		}
	}
	for (int i = 0; i < [images count]; i++) {
		CGRect imageFrame = [[images objectAtIndex:i] frame];
		imageFrame.origin.x = ((i % 4) * 78);
		imageFrame.origin.y = ((i / 4) * 80);
		[[images objectAtIndex:i] setFrame:imageFrame];
	}
	[UIView commitAnimations];
	if ([images count] == 0) {
		[[[[self.navigationController viewControllers] objectAtIndex:0] delegate] performSelector:@selector(removeImages)];
	}
}

- (void)setIsEditing:(BOOL)isEdit
{
	if (isEdit == YES) {
		for (int i = 0; i < [buttons count]; i++) {
			[[buttons objectAtIndex:i] setHidden:NO];
						
			isEditing = YES;
		}
	}
	else {
		for (int i = 0; i < [buttons count]; i++) {
			[[buttons objectAtIndex:i] setHidden:YES];
			
			isEditing = NO;
		}
	}
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
	
    [self setIsEditing:YES];
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
	
    [self setIsEditing:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	
	[self setIsEditing:NO];
	[buttons release];
	[images release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSLog(@"images variablestore count: %d%", [[[VariableStore sharedInstance] images] count]);
	
	images = [[NSMutableArray alloc] init];
	buttons = [[NSMutableArray alloc] init];
	
	[imagesScroll setContentOffset:CGPointMake(-4, -4)];
	
	if ([[VariableStore sharedInstance] images]) {
		
		[self loadImages];
	
		for (int i = 0; i < [[[VariableStore sharedInstance] images] count]; i++) {
			UIButton *tileButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
			[tileButton setImage:[UIImage imageNamed:@"xButton.png"] forState:UIControlStateNormal];
			[tileButton setImage:[UIImage imageNamed:@"xButton Highlighted.png"] forState:UIControlStateHighlighted];
			tileButton.showsTouchWhenHighlighted = YES;
		
			CGRect imageFrame = tileButton.frame;
			imageFrame.origin.x = (((i % 4) * 78) + 60);	//first time I've ever used the modulus operator. Feels good man.
			imageFrame.origin.y = (((i / 4) * 80) + 60);
			tileButton.frame = imageFrame;
			[tileButton addTarget:self action:@selector(removeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[imagesScroll addSubview:tileButton];
			[buttons addObject:tileButton];
			[tileButton release];
		}
	}
	
	[self pressedCancel];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Images";
	[imagesScroll setContentSize:CGSizeMake(312, 592)];
}

- (void)loadImages
{
	[images removeAllObjects];
	for (int i = 0; i < [[[VariableStore sharedInstance] images] count]; i++) {
		UIButton *tile = [UIButton buttonWithType:UIButtonTypeCustom];
		tile.tag = i;
		[tile setImage:[[[VariableStore sharedInstance] images] objectAtIndex:i]// imageByScalingProportionallyToSize:CGSizeMake(76, 76)]
			  forState:UIControlStateNormal];
		[tile addTarget:self action:@selector(tilePressed:) forControlEvents:UIControlEventTouchUpInside];
		tile.frame = CGRectMake(((i % 4) * 78), ((i / 4) * 80), 76, 76);
		[images addObject:tile];
		[imagesScroll addSubview:tile];
	}
}

- (void)tilePressed:(id)sender {
	if (isEditing) {
		return;
	}
	[UIView beginAnimations:@"LabelSlideOut" context:nil];
	[UIView setAnimationDuration:0.5];
	instructLabel.center = CGPointMake(instructLabel.center.x, instructLabel.center.y + instructLabel.frame.size.height*2);
	[UIView commitAnimations];
	
	imagesScroll.frame = CGRectMake(imagesScroll.frame.origin.x, imagesScroll.frame.origin.y, imagesScroll.frame.size.width, self.view.frame.size.height);
	
	imgWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	imgWheel.center = [sender center];
	[self.view addSubview:imgWheel];
	[imgWheel startAnimating];
	
	currentTileNum = [sender tag];

	ImgurRequest *imgurReq = [[ImgurRequest alloc] init];
	imgurReq.delegate = self;
	UIImage *image = [[[VariableStore sharedInstance] images] objectAtIndex:[sender tag]];
	if (image.size.width > 400) {
		image = [image imageByScalingProportionallyToSize:CGSizeMake(400, ((400 / image.size.width) * image.size.height))];
	}
	[imgurReq getTagForImage:image];
}

- (void)imgurRequest:(ImgurRequest *)imgurReq didReturnTag:(NSString *)tag {
	NSLog(@"requestFinished:%@", tag);

	if (tag.length > 0) {
		imgTag = [tag retain];
		UIAlertView *imgurCopyView = [[UIAlertView alloc] initWithTitle:@"Copy Tag to Clipboard" 
																message:@"Paste this code to insert the image into the body of a Blogger post.\
 This image will be removed from the stack, and leftover images will be appended to the end of the post." 
															   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Copy", nil];
		[imgurCopyView show];
		[imgurCopyView release];
	} else {
		UIAlertView *imgurFailView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" 
																message:@"Unable to connect to imgur.com to generate an img tag." 
															   delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[imgurFailView show];
		[imgurFailView release];
	}
	[imgurReq release];
	[imgWheel stopAnimating];
	[imgWheel release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
		gpBoard.string = imgTag;
		[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
		[self removeButtonPressed:[buttons objectAtIndex:currentTileNum]];
		[[[[[UIApplication sharedApplication] delegate] detailViewController] rightPopoverController] dismissPopoverAnimated:YES];
	}
	[imgTag release];
}

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
	[imagesScroll release];
	[instructLabel release];
    [super dealloc];
}


@end
