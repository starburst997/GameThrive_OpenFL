#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GameThrive/GameThrive.h"

extern "C" void notificationOpened( const char* message, const char* additionalData, bool isActive );

@interface NSDictionary (BVJSONString)

-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;

@end

@implementation NSDictionary (BVJSONString)

-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
													   options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
														 error:&error];
	
	if (! jsonData) {
		NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
		return @"{\"title\":\"Title 1\"}";
	} else {
		return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	}
}

@end

@interface GameThriveLib:NSObject

	@property (strong, nonatomic) GameThrive *gameThrive;
	+ (GameThriveLib *)instance;

@end

@interface NMEAppDelegate : NSObject <UIApplicationDelegate>



@end

@implementation NMEAppDelegate (GameThriveLib)

	-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
		NSLog(@"APP LAUNCHED...");
		
		[[GameThrive alloc] initWithLaunchOptions:launchOptions handleNotification:^(NSString* message, NSDictionary* additionalData, BOOL isActive) {
			
			NSLog(@"APP LOG ADDITIONALDATA: %@", additionalData);
			
			NSString * dataStr = @"{\"title\":\"Title 2\"}";
			if (additionalData)
			{
				dataStr = [additionalData bv_jsonStringWithPrettyPrint:false];
			}
			
			notificationOpened( [message UTF8String], [dataStr UTF8String], isActive );
		}];
		
		
		return YES;
	}
	
@end

@implementation GameThriveLib
	
	-(BOOL)showDialog:(NSString *)title message:(NSString *)message
	{
		
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
														    message:message
														   delegate:self
												  cancelButtonTitle:@"Close"
												  otherButtonTitles:nil, nil];
		
		[alertView show];
		
		return YES;
	}

	-(BOOL)configure
	{
		return YES;
	}

	+ (GameThriveLib *)instance{
		static GameThriveLib *instance;

		@synchronized(self){
			if (!instance)
				instance = [[GameThriveLib alloc] init];

			return instance;
		}
	}

@end

namespace gamethrive 
{
	void Configure()
	{
		NSLog(@"CONFIGURE CALLED");
		
		[[GameThriveLib instance] configure];
	}
	
	void ShowDialog( const char* title, const char* message )
	{
		[[GameThriveLib instance] showDialog: [[NSString alloc] initWithUTF8String:title] message:[[NSString alloc] initWithUTF8String:message]];
	}
}
