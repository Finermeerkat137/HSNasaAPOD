#import <HSWidgets/HSWidgetCombinedAdditionalOptionsAndPreferencesViewController.h>

@interface HSNasaPictureOfTheDayPreferencesViewController : HSWidgetCombinedAdditionalOptionsAndPreferencesViewController
-(NSArray* )specifiers;
-(void)showInfo;
-(void)dismissMyView;
-(void)sendNotification;
-(void)goToAPODURL;
-(void)saveAPODToPhotos;
@end