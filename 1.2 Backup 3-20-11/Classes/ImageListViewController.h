//
//  ImageListViewController.h
//  Monarch
//
//  Created by Joseph Constan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"

@class ImgurRequest;

@interface ImageListViewController : UIViewController <UIActionSheetDelegate> {
	
	UIScrollView *imagesScroll;
	BOOL		 isEditing;
	NSUInteger	 currentTileNum;
	
	NSString *imgTag;
	UIActivityIndicatorView *imgWheel;
	UILabel *instructLabel;
	NSMutableArray *images;
	NSMutableArray *buttons;
}
@property (nonatomic, retain) IBOutlet UIScrollView *imagesScroll;
@property (nonatomic, retain) IBOutlet UILabel *instructLabel;
@property (nonatomic) BOOL		isEditing;

- (void) loadImages;
- (void) imgurRequest:(ImgurRequest *)imgurReq didReturnTag:(NSString *)tag;

@end
