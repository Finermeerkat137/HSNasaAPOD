#import "HSNasaPictureOfTheDayViewController.h"
#import "cutils.h"
#import <notify.h>
#define log Log

static NSString* apiKey = nil;
NSString* date = nil;
int lockVar = 0;
static NSDictionary* apidict = nil;
@implementation HSNasaPictureOfTheDayViewController

-(void)viewDidLoad {

	[super viewDidLoad];
	
	self.square = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
	
	[self.view addSubview:self.square];
	self.square.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self.square.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
	[self.square.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
	[self.square.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
	[self.square.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
	
	NSURL* imgurl = nil;
	NSURL* nasaurl = [NSURL URLWithString:@"http://apod.nasa.gov"];

    date = [[NSString alloc] init];
	apiKey = [widgetOptions[@"APIKey"] stringValue ];

	if ([self checkIfUp: nasaurl] == TRUE) {
		lockVar = 1;
		imgurl = [self getCurrentAPOD];
		Log([[imgurl absoluteString] UTF8String]);
		Log("\nIMGURL has been validated as above\n");
		
		if (imgurl == nil) {
			Log("IMGURL is null\n");
		}

		else {
			[self getImage: imgurl];
		}
	}

	lockVar = 0;
	self.square.layer.cornerRadius = 20;
	self.square.layer.masksToBounds = YES;
	self.square.contentMode = UIViewContentModeScaleAspectFill;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveNotification:) name:@"sendNotificationToApod" object:nil];
	//[NSTimer scheduledTimerWithTimeInterval:7200.0 target:self selector:@selector(updateImage) userInfo:nil repeats:YES];

}

-(void)updateImage {

	if ([self checkIfUp: [NSURL URLWithString:@"http://nasa.gov"]] == TRUE) {
        if ((lockVar == 0) && ([self hasAPODChanged] == TRUE)) {
	        NSURL* imgurl = [self getCurrentAPOD];
			if (imgurl != nil) {
	            [self getImage: imgurl];
			}
	    }
    }
	Log("Timer did run\n");
}

-(void)getImage:(NSURL*)url {

	NSString* URLString = [url absoluteString];

	if (![[url scheme] length]) {
    	url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
		Log("This is from getImage: ");
		Log([[url absoluteString] UTF8String]);
	}

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

		NSData* data = [NSData dataWithContentsOfURL:url];
		UIImage* image = [UIImage imageWithData:data];
	
		dispatch_async(dispatch_get_main_queue(), ^{
			self.square.image = image;
		});
	});
}

-(BOOL)checkIfUp:(NSURL*)URL {

	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:4];
	[request setHTTPMethod: @"HEAD"];
	NSURLResponse* response;
	NSError* error;
	NSData* data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];

	if (data) {
		return TRUE;
	}
	else {
		return FALSE;
	}
}		

-(BOOL)hasAPODChanged {

	NSDictionary* dict = [self getAPODJson];

    if (dict == nil) {
            return FALSE;
    }

	NSString* string = [[NSString alloc] initWithString:[dict objectForKey:@"date"]];
	
	if ([string isEqualToString: date]) {
		return FALSE;
	}

	else {
		return TRUE;
	}
}	
	
-(NSDictionary*)getAPODJson {

	NSError* error;
	NSURL* url = nil;

	if (apiKey == nil || [apiKey length] == 0) {
		url = [NSURL URLWithString:@"https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"];
		log("APIKey is nil - defaults to DEMO-KEY\n");
	}

	else {
		url = [NSURL URLWithString: [NSString stringWithFormat:@"https://api.nasa.gov/planetary/apod?api_key=%@", apiKey]];
		log("URL used in getAPODJson: ");
		log([[url absoluteString] UTF8String]);
	}

	NSData* data = [NSData dataWithContentsOfURL: url];

	if (data == nil) {
		apidict = nil;
		return apidict;
	} 

    apidict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
	
	if ([apidict objectForKey:@"code"] != nil) {
		apidict = nil;
		return apidict;
	} 

	return apidict;
}

-(NSURL*)getCurrentAPOD {

	NSDictionary* dict = [self getAPODJson]; 
	NSURL* imageURL;

	if (dict == nil) {
		return nil;
	}

	if ([widgetOptions [@"hdEnabled"] boolValue]) {

		if ([dict objectForKey:@"hdurl"] != nil) {
			imageURL = [NSURL URLWithString:[dict objectForKey:@"hdurl"]];
			Log("Taking hdurl\n");
		}

		else {
			imageURL = [NSURL URLWithString:[dict objectForKey:@"url"]];
		}

	}

	else {
		imageURL = [NSURL URLWithString:[dict objectForKey:@"url"]];
	}

	date = [[NSString alloc] initWithString:[dict objectForKey:@"date"]];

	if ([[dict objectForKey:@"media_type"] isEqualToString:@"video"]) {
		Log("video\n");
		if ([[imageURL absoluteString] containsString:@"youtube"]) {
			Log("yt\n");
			return [self getYTThumbnail:(imageURL)];
		}

		else if ([[imageURL absoluteString] containsString:@"vimeo"]) {
			Log("vm\n");
			return [self getVimeoThumbnail:(imageURL)];
		}
	}

	return imageURL;
}

+(HSWidgetSize)minimumSize {
	
	return HSWidgetSizeMake(2, 2);
}

-(BOOL)isAccessoryTypeEnabled:(AccessoryType)accessoryType {
	int rows = [widgetOptions[@"makeLarge"] boolValue] ? 3 : 1;
	if (accessoryType == AccessoryTypeExpand) {
		HSWidgetSize finalExpandedSize = HSWidgetSizeAdd(self.widgetFrame.size, rows, 2);
		return [self containsSpaceToExpandOrShrinkToWidgetSize:finalExpandedSize];
	} 

	else if (accessoryType == AccessoryTypeShrink) {
		return self.widgetFrame.size.numRows > rows && self.widgetFrame.size.numCols > 2;
	}

	return [super isAccessoryTypeEnabled:accessoryType];
}

-(void)accessoryTypeTapped:(AccessoryType)accessoryType {
	int rows = [widgetOptions[@"makeLarge"] boolValue] ? 3 : 1;

	if (accessoryType == AccessoryTypeExpand) {
		HSWidgetSize finalExpandSize = HSWidgetSizeAdd(self.widgetFrame.size, rows, 2);
		[self updateForExpandOrShrinkToWidgetSize:finalExpandSize];
	}

	else if (accessoryType == AccessoryTypeShrink) {
		HSWidgetSize finalShrinkSize = HSWidgetSizeAdd(self.widgetFrame.size, -rows, -2);
		[self updateForExpandOrShrinkToWidgetSize:finalShrinkSize];
	}
}

-(NSURL*)getYTThumbnail:(NSURL*)YTURL {

	NSString* link = [YTURL absoluteString];
    NSString* ytID = nil;
	NSString* regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression* regExp = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray* array = [regExp matchesInString:link options:0 range:NSMakeRange(0,link.length)];

    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        ytID = [link substringWithRange:result.range];
    }

	NSString* baseURL = [NSString stringWithFormat:@"%@/%@/%@", @"img.youtube.com/vi", ytID, @"hqdefault.jpg"];
	Log([baseURL UTF8String]);
	return [NSURL URLWithString:baseURL];
}

-(NSURL*)getVimeoThumbnail:(NSURL*)VMURL {

	NSURL* JSONURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", @"https://vimeo.com/api/oembed.json?url=https://vimeo.com", [VMURL lastPathComponent]]];
	NSData* data = [NSData dataWithContentsOfURL: JSONURL];

	if (data == nil) {
		return nil;
	}

	NSDictionary* dict = [NSJSONSerialization JSONObjectWithData: data options:kNilOptions error:nil];

	return [NSURL URLWithString: [dict objectForKey:@"thumbnail_url"]];
}

+(NSDictionary*)getAPIDictionary {

	return apidict;
}

-(void)didRecieveNotification:(NSNotification*)notification {

	[self updateImage];
}

@end
