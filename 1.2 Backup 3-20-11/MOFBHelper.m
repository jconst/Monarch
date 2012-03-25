#import "MOFBHelper.h"

@implementation MOFBHelper

@synthesize delegate;

- (id) init {
	self = [super init];
	mofbStatus = [[[MOFBStatus alloc] init] retain];
	mofbStatus.delegate = self;		
	return self;
}

- (NSString *)status {
	return mofbStatus.status;
}

- (void)setStatus:(NSString *)status {
	[mofbStatus update:status];
}

- (void) setFBStatus:(NSString *)description withImages:(NSArray *)images title:(NSString *)title delegate:(id)statusDelegate {
	self.delegate = statusDelegate;
	//upload photo(s) to user's albums
	mofbStatus.delegate = statusDelegate;
	for (int i=0; i < [images count]; i++) {
		NSDictionary *params = [NSDictionary dictionaryWithObject:description forKey:@"caption"];
		// shrink image if necessary
		UIImage *scaledImage = [images objectAtIndex:i];
		if ([[images objectAtIndex:i] size].height > 720) {
			scaledImage = [scaledImage imageByScalingProportionallyToSize:CGSizeMake(720, 720)];
		}
	if ([[images objectAtIndex:i] size].width > 720) {
			scaledImage = [scaledImage imageByScalingProportionallyToSize:CGSizeMake(720, 720)];
		}
		[[FBRequest requestWithDelegate:mofbStatus] call:@"facebook.Photos.Upload" params:params dataParam:UIImagePNGRepresentation(scaledImage)];
	}
}

- (void)statusDidUpdate:(MOFBStatus*)aMofbStatus {
	[delegate statusDidUpdate:self];
	NSLog(@"status did update");
}

-(void)status:(MOFBStatus*)aMofbStatus DidFailWithError:(NSError*)error {
	[delegate status:self DidFailWithError:error];
	NSLog(@"status failed to update");
}

- (void)dealloc {
	[mofbStatus release];
	[super dealloc];
}

@end

