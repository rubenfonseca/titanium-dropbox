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

@interface Com0x82DropboxSessionProxy : TiProxy <DBSessionDelegate> {
  DBSession *session;
  
  NSString *key;
  NSString *secret;
  NSString *root;
  
  KrollCallback *authenticateSuccessCallback;
  KrollCallback *authenticateCancelCallback;
}

@property (nonatomic, readwrite, retain) NSString *key;
@property (nonatomic, readwrite, retain) NSString *secret;
@property (nonatomic, readwrite, retain) NSString *root;

#pragma mark Public
-(id)isLinked:(id)args;
-(void)unlink:(id)args;

#pragma mark Private
-(DBSession *)_session;

@end
