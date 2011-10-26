/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "Com0x82DropboxModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation Com0x82DropboxModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"3f3d7c59-425a-476e-9671-a86b3b141fb0";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.0x82.dropbox";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)resumed:(id)note {  
  NSDictionary *launchOptions = [[TiApp app] launchOptions];
  if(launchOptions != nil) {
    NSString *urlString = [launchOptions objectForKey:@"url"];
    if(urlString != nil && [urlString hasPrefix:@"db"]) {
      NSURL *url = [NSURL URLWithString:urlString];
      if([[DBSession sharedSession] handleOpenURL:url]) {
        if([[DBSession sharedSession] isLinked]) {
          [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxLoginResult" object:self userInfo:[NSDictionary dictionaryWithObject:NUMBOOL(true) forKey:@"result"]];
        } else {
          [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxLoginResult" object:self userInfo:[NSDictionary dictionaryWithObject:NUMBOOL(false) forKey:@"result"]];
        }
      }
    }
  }
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Listener Notifications

#pragma Public APIs
MAKE_SYSTEM_STR(DROPBOX_ROOT_APP_FOLDER, kDBRootAppFolder)
MAKE_SYSTEM_STR(DROPBOX_ROOT_DROPBOX, kDBRootDropbox)

@end
