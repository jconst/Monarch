//
//  FoursquareRequest.h
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "VariableStore.h"

#define SHOUTNOLOC 1
#define VENUECHECKIN 2
#define VENUETIP 3
#define VENUETODO 4

@interface FoursquareRequest : NSObject <CLLocationManagerDelegate> {
	NSString		*username;
	NSString		*password;
	NSMutableData	*receivedData;
	NSMutableURLRequest	*theRequest;
	NSURLConnection *theConnection;
	id				delegate;
	CLLocationManager *clm;
	
	BOOL			sendDidFail;
	BOOL			isPost;
	NSString		*requestBody;
	NSString		*lastStatus;
}

@property(nonatomic, retain) NSString		*username;
@property(nonatomic, retain) NSString		*password;
@property(nonatomic, retain) NSMutableData	*receivedData;
@property(nonatomic, retain) id				delegate;
@property(nonatomic, retain) CLLocationManager *clm;


-(void)request:(NSURL *)url;

-(void)statuses_update:(NSString *)status delegate:(id)requestDelegate requestSelector:(SEL)requestSelector;

@end
