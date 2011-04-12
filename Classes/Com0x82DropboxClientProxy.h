//
//  Com0x82DropboxClientProxy.h
//  dropbox
//
//  Created by Ruben Fonseca on 11/04/09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiProxy.h"
#import "DropboxSDK.h"

@interface Com0x82DropboxClientProxy : TiProxy {
  DBRestClient *restClient;
  
  KrollCallback *loadAccountInfoSuccessCallback;
  KrollCallback *loadAccountInfoErrorCallback;
  
  KrollCallback *loadMetadataSuccessCallback;
  KrollCallback *loadMetadataUnchangedCallback;
  KrollCallback *loadMetadataErrorCallback;
  
  KrollCallback *loadThumbnailSuccessCallback;
  KrollCallback *loadThumbnailErrorCallback;
  NSString *thumbnailTempPath;
  
  KrollCallback *loadFileSuccessCallback;
  KrollCallback *loadFileErrorCallback;
  KrollCallback *loadFileProgressCallback;
  NSString *fileTempPath;
  
  KrollCallback *createFolderSuccessCallback;
  KrollCallback *createFolderErrorCallback;
  
  KrollCallback *deletePathSuccessCallback;
  KrollCallback *deletePathErrorCallback;
  
  KrollCallback *uploadFileSuccessCallback;
  KrollCallback *uploadFileProgressCallback;
  KrollCallback *uploadFileErrorCallback;
  
  KrollCallback *copyPathSuccessCallback;
  KrollCallback *copyPathErrorCallback;
  
  KrollCallback *movePathSuccessCallback;
  KrollCallback *movePathErrorCallback;
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
