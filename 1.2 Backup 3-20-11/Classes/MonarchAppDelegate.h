//
//  MonarchAppDelegate.h
//  Monarch
//
//  Created by Joseph Constan on 4/26/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RootViewController;
@class DetailViewController;
@class AddAccountViewController;

@interface MonarchAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
	UINavigationController *menuNavController;
    RootViewController *rootViewController;
    DetailViewController *detailViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic,retain) IBOutlet UINavigationController *menuNavController;
@property (nonatomic,retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic,retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic,retain) IBOutlet DetailViewController *detailViewController;

- (void) setStatus:(NSString *)statTxt title:(NSString *)titleTxt checkSave:(NSString *)checkSave;	
- (void) setUncheckedStatus:(NSString *)statTxt title:(NSString *)titleTxt;
- (void) setCheckedStatus:(NSString *)statTxt title:(NSString *)titleTxt;
- (void) reloadCorrectionDefaults;
- (NSNumber *) rootViewCellsSelected;
- (void) openPicasaSettingsWithList:(NSDictionary *)albumListDict;
- (void) openFoursquareSettings;

@end
