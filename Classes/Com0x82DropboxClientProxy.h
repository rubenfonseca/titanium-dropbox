//
//  Com0x82DropboxClientProxy.h
//  dropbox
//
//  Created by Ruben Fonseca on 11/04/09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiProxy.h"

@interface Com0x82DropboxClientProxy : TiProxy {
  DBRestClient *restClient;
  
  KrollCallback *loadAccountInfoSuccessCallback;
  KrollCallback *loadAccountInfoErrorCallback;
  
  KrollCallback *loadMetadataSuccessCallback;
  KrollCallback *loadMetadataUnchangedCallback;
  KrollCallback *loadMetadataErrorCallback;
  
	NSMutableDictionary *loadThumbnailDictionary;
  
  NSMutableDictionary *loadFileDictionary;
  NSMutableDictionary *uploadFileDictionary;
	NSMutableDictionary *chunkedUploadFileDictionary;
  
  KrollCallback *createFolderSuccessCallback;
  KrollCallback *createFolderErrorCallback;
  
  KrollCallback *deletePathSuccessCallback;
  KrollCallback *deletePathErrorCallback;
  
  KrollCallback *copyPathSuccessCallback;
  KrollCallback *copyPathErrorCallback;
  
  KrollCallback *movePathSuccessCallback;
  KrollCallback *movePathErrorCallback;
	
	KrollCallback *sharePathSuccessCallback;
	KrollCallback *sharePathErroCallback;
	
	KrollCallback *mediaPathSuccessCallback;
	KrollCallback *mediaPathErrorCallback;
	
	KrollCallback *searchSuccesCallback;
	KrollCallback *searchErrorCallback;
	
	KrollCallback *copyRefSuccessCallback;
	KrollCallback *copyRefErrorCallback;
	
	KrollCallback *deltaSuccessCallback;
	KrollCallback *deltaErrorCallback;
  
  KrollCallback *loadRevisionsSuccessCallback;
  KrollCallback *loadRevisionsErrorCallback;
  
  KrollCallback *restoreSuccessCallback;
  KrollCallback *restoreErrorCallback;
}

-(void)loadAccountInfo:(id)args;
-(void)loadMetadata:(id)args;
-(void)loadThumbnail:(id)args;
-(void)loadFile:(id)args;
-(void)cancelFileLoad:(id)args;

-(void)createFolder:(id)args;
-(void)deletePath:(id)args;
-(void)uploadFile:(id)args;
-(void)copyPath:(id)args;
-(void)movePath:(id)args;

@end
