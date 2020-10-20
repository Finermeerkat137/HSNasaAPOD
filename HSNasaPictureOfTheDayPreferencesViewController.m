#import "HSNasaPictureOfTheDayPreferencesViewController.h"
#import "OBWelcomeController.h"
#import "HSNasaPictureOfTheDayViewController.h"
#import <stdio.h>
#import "cutils.h"
#import <UIKit/UIWindow+Private.h>
#import <notify.h>

OBWelcomeController* moreInfoController = nil;
UIWindow* topWindow = nil;

@implementation HSNasaPictureOfTheDayPreferencesViewController
-(NSArray *)specifiers {
	
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

-(void)showInfo {

	topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	topWindow.windowLevel = UIWindowLevelAlert + 1;
	topWindow.hidden = NO;
	NSDictionary* apodDict = nil;

	if ([HSNasaPictureOfTheDayViewController getAPIDictionary] == nil) {
		Log("showInfo failed due to lack of dict\n");
	}

	else {
		apodDict = [HSNasaPictureOfTheDayViewController getAPIDictionary];
	}

	moreInfoController = [[OBWelcomeController alloc] initWithTitle:[apodDict objectForKey:@"title"] detailText:[apodDict objectForKey:@"explanation"] icon:[UIImage systemImageNamed:@"sparkles"]];
	[moreInfoController addBulletedListItemWithTitle:@"Date: " description:[apodDict objectForKey:@"date"] image:[UIImage systemImageNamed:@"calendar"]];
	[moreInfoController addBulletedListItemWithTitle:@"Copyright" description:([apodDict objectForKey:@"copyright"] ? [apodDict objectForKey:@"copyright"] : @"Unavailable") image:[UIImage systemImageNamed:@"person.fill"]];
	OBBoldTrayButton* continueButton = [OBBoldTrayButton buttonWithType:1];

	[continueButton addTarget:self action:@selector(dismissMyView) forControlEvents:UIControlEventTouchUpInside];
	[continueButton setClipsToBounds:YES];
	[continueButton setTitle:@"Done" forState:UIControlStateNormal];
	[continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[continueButton.layer setCornerRadius:17];
	[moreInfoController.buttonTray addButton:continueButton];	

	moreInfoController.modalPresentationStyle = UIModalPresentationPageSheet;
	moreInfoController.modalInPresentation = YES;
	moreInfoController.view.tintColor = [UIColor systemBlueColor];

	UIViewController* topController = [[UIViewController alloc] init];
	topWindow.rootViewController = topController;

	topController.modalPresentationStyle = UIModalPresentationCurrentContext;
	[topController presentViewController:moreInfoController animated:YES completion:nil];

	int notify_token;
	notify_register_dispatch("com.apple.springboard.lockstate", &notify_token, dispatch_get_main_queue(), ^(int token) {
		uint64_t state = UINT64_MAX;
    	notify_get_state(token, &state);
    	if(state != 0) {
    	    [self dismissMyView];
    	}
    }
	);



}	

-(void)dismissMyView {
	Log("dismissMyView was called\n");
	[moreInfoController dismissViewControllerAnimated:YES completion:nil];
	topWindow = nil;
}

-(void)sendNotification {

	[[NSNotificationCenter defaultCenter] postNotificationName:@"sendNotificationToApod" object:self];
}

@end

