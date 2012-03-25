#import <Foundation/Foundation.h>
#import "MOFBStatus.h"
#import "UIImage+Extras.h"

@class MOFBHelper;

@protocol MOFBHelperDelegate <MOFBStatusDelegate>
@end

@interface MOFBHelper : NSObject <MOFBStatusDelegate>{
	id delegate;
	MOFBStatus *mofbStatus;
}

@property (nonatomic, assign) id <MOFBHelperDelegate> delegate;
@property (nonatomic, retain) NSString *status;

- (void) setFBStatus:(NSString *)description withImages:(NSArray *)images title:(NSString *)title delegate:(id)statusDelegate;

@end
