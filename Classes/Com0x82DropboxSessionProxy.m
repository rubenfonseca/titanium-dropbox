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

@synthesize key, secret;

#pragma mark Memory Management
-(void)dealloc {
  if(session != nil) {
    RELEASE_TO_NIL(session);
  }
  
  RELEASE_TO_NIL(key);
  RELEASE_TO_NIL(secret);
  
  [super dealloc];
}

#pragma mark Public API
-(id)isLinked:(id)args {
  return NUMBOOL([[self _session] isLinked]);
}

-(void)unlink:(id)args {
  [[self _session] unlink];
}

-(void)showAuthenticationWindow:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id cancel  = [args objectForKey:@"cancel"];
    
  RELEASE_TO_NIL(authenticateSuccessCallback);
  RELEASE_TO_NIL(authenticateCancelCallback);
  
  authenticateSuccessCallback = [success retain];
  authenticateCancelCallback = [cancel retain];
  
  [[self _session] unlink];
  DBLoginController *controller = [[DBLoginController new] autorelease];
  controller.delegate = self;
  [controller presentFromController:[TiApp controller]];
}

#pragma mark Internal stuff
-(DBSession *)_session {
  if(session == nil) {
    if(key == nil || secret == nil) {
      [self throwException:@"missing key or secret" subreason:nil location:CODELOCATION];
    }
    
    session = [[DBSession alloc] initWithConsumerKey:key consumerSecret:secret];
    [DBSession setSharedSession:session];
    [session release];
  }
  
  return session;
}

- (void)loginControllerDidLogin:(DBLoginController*)controller {
  if(authenticateSuccessCallback) {
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys: [[[Com0x82DropboxClientProxy alloc] _initWithPageContext:self.pageContext] autorelease], @"client", nil];
    [self _fireEventToListener:@"success" withObject:event listener:authenticateSuccessCallback thisObject:nil];
  }
}
- (void)loginControllerDidCancel:(DBLoginController*)controller {
  if(authenticateCancelCallback) {
    NSDictionary *event = [NSDictionary dictionary];
    [self _fireEventToListener:@"cancel" withObject:event listener:authenticateCancelCallback thisObject:nil];
  }
}

@end
