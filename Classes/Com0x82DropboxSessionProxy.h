//
//  Com0x82DropboxClientProxy.h
//  dropbox
//
//  Created by Ruben Fonseca on 11/04/09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TiApp.h"
#import "TiProxy.h"
#import "DropboxSDK.h"

@interface Com0x82DropboxSessionProxy : TiProxy <DBLoginControllerDelegate> {
  DBSession *session;
  
  NSString *key;
  NSString *secret;
  
  KrollCallback *authenticateSuccessCallback;
  KrollCallback *authenticateCancelCallback;
}

@property (nonatomic, readwrite, retain) NSString *key;
@property (nonatomic, readwrite, retain) NSString *secret;

#pragma mark Public
-(id)isLinked:(id)args;
-(void)unlink:(id)args;
-(void)showAuthenticationWindow:(id)args;

#pragma mark Private
-(DBSession *)_session;

@end
