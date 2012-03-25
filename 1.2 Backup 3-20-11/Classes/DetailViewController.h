//
//  DetailViewController.h
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"
#import "TwitterRequest.h"
#import "TumblrRequest.h"
#import "FoursquareRequest.h"
#import "FBConnect.h"
#import "MOFBHelper.h"
#import "Reachability.h"
#import "MenuViewController.h"

#define AWAY YES
#define BACK NO

#define CURRENTROW [indexPath indexAtPosition:1]
#define CURRENTSECTION [indexPath indexAtPosition:0]

@class MenuViewController;

typedef enum {
	portrait,
	portraitUpsideDown,
	landscapeLeft,
	landscapeRight
} Orientations;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIActionSheetDelegate, 
													MOFBHelperDelegate, FBSessionDelegate, UITextViewDelegate, UIScrollViewDelegate> {
    											
    UIPopoverController *popoverController;
	UIPopoverController *rightPopoverController;
	UINavigationBar *navigationBar;
	UITextView *statusText;
	UITextField *titleField;
	UIImageView *statusImage;
	UIImageView *arrowImage;
	UIImageView *backgroundImage;
	UIBarButtonItem	*optionButton;
														
	UIImageView *paperclip;
	UIButton *photo;
	UIImageView *polaroids;
	UIButton *removeImage;
														
	UIActivityIndicatorView *sendingSpinner;
						
	BOOL useTwitlonger;
	BOOL keyboardIsUp;
	BOOL sendCanceled;
	BOOL imagesPresent;
	NSMutableString *sentString;
	NSMutableArray *sentArray;
									
	Orientations lastOrientation;
														
	UINavigationController *rightMenuNavController;
	
	UISwipeGestureRecognizer *swipeRecognizer;
	const char *siteNames[30];

	MenuViewController *menuViewController;
	
	MOFBHelper *fbHelper;
//	FBSession *session;
	
    id detailItem;
}

@property (nonatomic, retain) UIPopoverController		*popoverController;
@property (nonatomic, retain) UIPopoverController		*rightPopoverController;
@property (nonatomic, retain) MenuViewController *menuViewController;
@property (nonatomic, retain) UINavigationController *rightMenuNavController;
@property (nonatomic, retain) id detailItem;

@property (nonatomic, retain) IBOutlet UINavigationBar	*navigationBar;
@property (nonatomic, retain) IBOutlet UITextView		*statusText;
@property (nonatomic, retain) IBOutlet UITextField		*titleField;
@property (nonatomic, retain) IBOutlet UIImageView		*statusImage;
@property (nonatomic, retain) IBOutlet UIImageView		*arrowImage;
@property (nonatomic, retain) IBOutlet UIBarButtonItem	*optionButton;
@property (nonatomic, retain) UIImageView *backgroundImage;

@property (nonatomic, retain) NSMutableString *sentString;
@property (nonatomic, retain) NSMutableArray *sentArray;
@property (nonatomic, retain) UIButton *photo;

@property (nonatomic, retain) UISwipeGestureRecognizer *swipeRecognizer;

- (void) showCodevsMessage;
- (void) showImageList;
- (void) optionButtonPressed;
- (void) flickPaperAway;
- (void) flickPaperInDirection:(BOOL)dir;
- (void) confirmSend;
- (void) sendUpdate;
- (void) addToSentList:(NSUInteger)siteNum username:(NSString *)un succeeded:(BOOL)success;
- (void) attachImage:(UIImage *)image;
- (void) removeImages;


@end