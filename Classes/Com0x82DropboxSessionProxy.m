//
//  Com0x82DropboxClientProxy.m
//  dropbox
//
//  Created by Ruben Fonseca on 11/04/09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Com0x82DropboxSessionProxy.h"
#import "Com0x82DropboxClientProxy.h"
#import "TiUIViewProxy.h"
#import "TiApp.h"

@implementation Com0x82DropboxSessionProxy

@synthesize key, secret, root;

#pragma mark Memory Management
-(id)init {
  if(self = [super init]) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginResult:) name:@"DropboxLoginResult" object:nil];
  }
  
  return self;
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DropboxLoginResult" object:nil];
  
  if(session != nil) {
    RELEASE_TO_NIL(session);
  }
  
  RELEASE_TO_NIL(key);
  RELEASE_TO_NIL(secret);
  RELEASE_TO_NIL(root);
  
  [super dealloc];
}

#pragma mark Public API
-(id)isLinked:(id)args {
  return NUMBOOL([[self _session] isLinked]);
}

-(void)unlink:(id)args {
  [[self _session] unlinkAll];
}

-(void)link:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id cancel  = [args objectForKey:@"cancel"];
    
  RELEASE_TO_NIL(authenticateSuccessCallback);
  RELEASE_TO_NIL(authenticateCancelCallback);
  
  authenticateSuccessCallback = [success retain];
  authenticateCancelCallback = [cancel retain];
  
  [self unlink:nil];
	
	TiRootViewController *currentVC = [TiApp controller];
	[currentVC manuallyRotateToOrientation:UIInterfaceOrientationPortrait duration:0.0];
  [[DBSession sharedSession] linkFromController:currentVC];
}

#pragma mark Internal stuff
-(DBSession *)_session {
  if(session == nil) {
    if(key == nil || secret == nil) {
      [self throwException:@"missing key or secret" subreason:nil location:CODELOCATION];
    }
    
    session = [[DBSession alloc] initWithAppKey:key appSecret:secret root:root];
    session.delegate = self;
    [DBSession setSharedSession:session];
  }
  
  return session;
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
  [self fireEvent:@"reauth" withObject:nil];
}

#pragma mark DropboxLoginResult
-(void)loginResult:(NSNotification *)note {
  BOOL result = [[note.userInfo objectForKey:@"result"] boolValue];
  
  if(result) {
    Com0x82DropboxClientProxy *clientProxy = [[[Com0x82DropboxClientProxy alloc] init] autorelease];
    NSDictionary *event = [NSDictionary dictionaryWithObject:clientProxy forKey:@"client"];
    
    [self _fireEventToListener:@"success" withObject:event listener:authenticateSuccessCallback thisObject:self];
  } else {
    [self _fireEventToListener:@"cancel" withObject:nil listener:authenticateCancelCallback thisObject:self];
  }
}

@end
