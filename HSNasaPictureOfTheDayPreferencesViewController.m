#import "HSNasaPictureOfTheDayPreferencesViewController.h"
#import "OBWelcomeController.h"
#import "HSNasaPictureOfTheDayViewController.h"
#import <stdio.h>
#import "cutils.h"

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
		Log("nodict\n");
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

}	

-(void)dismissMyView {

	[moreInfoController dismissViewControllerAnimated:YES completion:nil];
	topWindow = nil;
}

-(void)sendNotification {

	[[NSNotificationCenter defaultCenter] postNotificationName:@"sendNotificationToApod" object:self];
}

@end

