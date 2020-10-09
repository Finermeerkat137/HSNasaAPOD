#import <HSWidgets/HSWidgetViewController.h>

@interface HSNasaPictureOfTheDayViewController : HSWidgetViewController
@property (nonatomic, strong) UIImageView* square;
-(void)getImage:(NSURL*)url;
-(BOOL)checkIfUp:(NSURL*)URL;
-(NSURL*)getCurrentAPOD;
-(BOOL)hasAPODChanged;
-(void)updateImage;
-(NSURL*)getVimeoThumbnail:(NSURL*)VMURL;
-(NSURL*)getYTThumbnail:(NSURL*)YTURL;
+(NSDictionary*)getAPIDictionary;
-(void)didRecieveNotification:(NSNotification*)notification;
@end

