//
//  DBConnectController+DBConnectController_NSNotification.m
//  dropbox
//
//  Created by Ruben Fonseca on 08/11/12.
//
//

#import "DBConnectController+NSNotification.h"

@implementation DBConnectController (NSNotification)

- (BOOL)openUrl:(NSURL *)openUrl {
	UIApplication *app = [UIApplication sharedApplication];
	id<UIApplicationDelegate> delegate = app.delegate;
	
	if ([delegate respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
		[delegate application:app openURL:openUrl sourceApplication:@"com.getdropbox.Dropbox" annotation:nil];
	} else if ([delegate respondsToSelector:@selector(application:handleOpenURL:)]) {
		[delegate application:app handleOpenURL:openUrl];
	} else {
		NSLog(@"DropboxSDK: app delegate does not implement application:openURL:sourceApplication:annotation:");
		return NO;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxDidPostLaunchOptions" object:nil];
	
	return YES;
}

@end
