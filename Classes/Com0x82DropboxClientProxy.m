//
//  Com0x82DropboxClientProxy.m
//  dropbox
//
//  Created by Ruben Fonseca on 11/04/09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Com0x82DropboxClientProxy.h"
#import "TiBlob.h"
#import "TiFile.h"
#import "TiUtils.h"

#import "DBMetadata+Dumper.h"
#import "DBRestClient+OverwriteUpload.h"

@interface Com0x82DropboxClientProxy () <DBRestClientDelegate>
@property (nonatomic, readonly) DBRestClient* restClient;
@end

@implementation Com0x82DropboxClientProxy

#pragma mark Memory management 
-(void)dealloc {
  RELEASE_TO_NIL(restClient);
  
  RELEASE_TO_NIL(loadAccountInfoSuccessCallback);
  RELEASE_TO_NIL(loadAccountInfoErrorCallback);
  
  RELEASE_TO_NIL(loadMetadataSuccessCallback);
  RELEASE_TO_NIL(loadMetadataUnchangedCallback);
  RELEASE_TO_NIL(loadMetadataErrorCallback);
  
  RELEASE_TO_NIL(loadThumbnailSuccessCallback);
  RELEASE_TO_NIL(loadThumbnailErrorCallback);
  RELEASE_TO_NIL(thumbnailTempPath);
  
  RELEASE_TO_NIL(loadFileSuccessCallback);
  RELEASE_TO_NIL(loadFileErrorCallback);
  RELEASE_TO_NIL(loadFileProgressCallback);
  RELEASE_TO_NIL(fileTempPath);
  
  RELEASE_TO_NIL(createFolderSuccessCallback);
  RELEASE_TO_NIL(createFolderErrorCallback);
  
  RELEASE_TO_NIL(deletePathSuccessCallback);
  RELEASE_TO_NIL(deletePathErrorCallback);
  
  RELEASE_TO_NIL(uploadFileSuccessCallback);
  RELEASE_TO_NIL(uploadFileProgressCallback);
  RELEASE_TO_NIL(uploadFileErrorCallback);
  
  RELEASE_TO_NIL(copyPathSuccessCallback);
  RELEASE_TO_NIL(copyPathErrorCallback);
  
  RELEASE_TO_NIL(movePathSuccessCallback);
  RELEASE_TO_NIL(movePathErrorCallback);
  
  [super dealloc];
}

#pragma mark Public API
-(void)loadAccountInfo:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  id success = [args objectForKey:@"success"];
  id error   = [args objectForKey:@"error"];
  
  RELEASE_AND_REPLACE(loadAccountInfoSuccessCallback, success);
  RELEASE_AND_REPLACE(loadAccountInfoErrorCallback, error);
    
  [self.restClient loadAccountInfo];
}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [event setValue:info.country forKey:@"country"];
  [event setValue:info.displayName forKey:@"displayName"];
  [event setValue:info.userId forKey:@"userId"];
  [event setValue:info.referralLink forKey:@"referralLink"];
  
  NSMutableDictionary *quota = [NSMutableDictionary dictionary];
  [quota setValue:NUMLONGLONG(info.quota.normalConsumedBytes) forKey:@"normal"];
  [quota setValue:NUMLONGLONG(info.quota.sharedConsumedBytes) forKey:@"shared"];
  [quota setValue:NUMLONGLONG(info.quota.totalBytes) forKey:@"quota"];
  [event setValue:quota forKey:@"quota"];
  
  if(loadAccountInfoSuccessCallback)
    [self _fireEventToListener:@"success" withObject:event listener:loadAccountInfoSuccessCallback thisObject:nil];
}

- (void)restClient:(DBRestClient*)client loadAccountInfoFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  if(loadAccountInfoErrorCallback)
    [self _fireEventToListener:@"error" withObject:event listener:loadAccountInfoErrorCallback thisObject:nil];
}

-(void)loadMetadata:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  id success = [args objectForKey:@"success"];
  id unchanged = [args objectForKey:@"unchanged"];
  id error = [args objectForKey:@"error"];
  
  RELEASE_AND_REPLACE(loadMetadataSuccessCallback, success);
  RELEASE_AND_REPLACE(loadMetadataUnchangedCallback, unchanged);
  RELEASE_AND_REPLACE(loadMetadataErrorCallback, error);
    
  id path = [args objectForKey:@"path"];
  id hash = [args objectForKey:@"hash"];
  ENSURE_TYPE(path, NSString);
  ENSURE_TYPE_OR_NIL(hash, NSString);
  
  [self.restClient loadMetadata:path withHash:hash];
}

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [metadata dumpToDictionary:event];
  
  if(loadMetadataSuccessCallback)
    [self _fireEventToListener:@"success" withObject:event listener:loadMetadataSuccessCallback thisObject:nil];
}
- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
  if(loadMetadataUnchangedCallback)
    [self _fireEventToListener:@"unchanged" withObject:[NSDictionary dictionary] listener:loadMetadataUnchangedCallback thisObject:nil];
}
- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  if(loadMetadataErrorCallback)
    [self _fireEventToListener:@"error" withObject:event listener:loadMetadataErrorCallback thisObject:nil];
}

-(void)loadThumbnail:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id error = [args objectForKey:@"error"];
  
  RELEASE_AND_REPLACE(loadThumbnailSuccessCallback, success);
  RELEASE_AND_REPLACE(loadThumbnailErrorCallback, error);
    
  id path = [args objectForKey:@"path"];
  id size = [args objectForKey:@"size"];
  ENSURE_TYPE(path, NSString);
  ENSURE_TYPE_OR_NIL(size, NSString);
  if(size == nil)
    size = @"small";
  
  thumbnailTempPath = [NSTemporaryDirectory() stringByAppendingString:@"thumbnail.jpg"];
  [self.restClient loadThumbnail:path ofSize:size intoPath:thumbnailTempPath];
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
  TiBlob *blob = [[[TiBlob alloc] initWithFile:thumbnailTempPath] autorelease];
  
  NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:blob, @"thumbnail", nil];
  
  if(loadThumbnailSuccessCallback)
    [self _fireEventToListener:@"success" withObject:event listener:loadThumbnailSuccessCallback thisObject:nil];
}
- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  if(loadThumbnailErrorCallback)
    [self _fireEventToListener:@"error" withObject:event listener:loadThumbnailErrorCallback thisObject:nil];
}

-(void)loadFile:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id error = [args objectForKey:@"error"];
  id progress = [args objectForKey:@"progress"];
  
  RELEASE_AND_REPLACE(loadFileSuccessCallback, success);
  RELEASE_AND_REPLACE(loadFileErrorCallback, error);
  RELEASE_AND_REPLACE(loadFileProgressCallback, progress);
  
  id path = [args objectForKey:@"path"];
  ENSURE_TYPE(path, NSString);
  
  fileTempPath = [NSTemporaryDirectory() stringByAppendingString:@"file"];
  [self.restClient loadFile:path intoPath:fileTempPath];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath contentType:(NSString*)contentType {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [event setValue:NULL_IF_NIL(contentType) forKey:@"content-type"];
  
  TiBlob *blob = [[[TiBlob alloc] initWithFile:fileTempPath] autorelease];
  [event setValue:blob forKey:@"file"];
  
  if(loadFileSuccessCallback)
    [self _fireEventToListener:@"success" withObject:event listener:loadFileSuccessCallback thisObject:nil];
}
- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
  NSDictionary *event = [NSDictionary dictionaryWithObject:NUMFLOAT(progress) forKey:@"progress"];
  
  if(loadFileProgressCallback)
    [self _fireEventToListener:@"progress" withObject:event listener:loadFileProgressCallback thisObject:nil];
}
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  if(loadFileErrorCallback)
    [self _fireEventToListener:@"error" withObject:event listener:loadFileErrorCallback thisObject:nil];
}

-(void)cancelFileLoad:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSString);
  
  [self.restClient cancelFileLoad:args];
}

-(void)createFolder:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
 
  id success = [args objectForKey:@"success"];
  id error = [args objectForKey:@"error"];
  
  RELEASE_AND_REPLACE(createFolderSuccessCallback, success);
  RELEASE_AND_REPLACE(createFolderErrorCallback, error);
  
  id path = [args objectForKey:@"path"];
  ENSURE_TYPE(path, NSString);
  
  [self.restClient createFolder:path];
}

- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [folder dumpToDictionary:event];
  
  if(createFolderSuccessCallback)
    [self _fireEventToListener:@"success" withObject:event listener:createFolderSuccessCallback thisObject:nil];
}
- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  if(createFolderErrorCallback)
    [self _fireEventToListener:@"error" withObject:event listener:createFolderErrorCallback thisObject:nil]; 
}

-(void)deletePath:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id error = [args objectForKey:@"error"];
  
  RELEASE_AND_REPLACE(deletePathSuccessCallback, success);
  RELEASE_AND_REPLACE(deletePathErrorCallback, error);
  
  id path = [args objectForKey:@"path"];
  ENSURE_TYPE(path, NSString);
  
  [self.restClient deletePath:path];
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path {
  NSDictionary *event = [NSDictionary dictionaryWithObject:path forKey:@"path"];
  
  if(deletePathSuccessCallback)
    [self _fireEventToListener:@"success" withObject:event listener:deletePathSuccessCallback thisObject:nil];
}
- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  if(deletePathErrorCallback)
    [self _fireEventToListener:@"error" withObject:event listener:deletePathErrorCallback thisObject:nil];
}

-(void)uploadFile:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id progress = [args objectForKey:@"progress"];
  id error = [args objectForKey:@"error"];
  
  RELEASE_AND_REPLACE(uploadFileSuccessCallback, success);
  RELEASE_AND_REPLACE(uploadFileProgressCallback, progress);
  RELEASE_AND_REPLACE(uploadFileErrorCallback, error);
  
  id file = [args objectForKey:@"file"];
  id path = [args objectForKey:@"path"];
  id fileName = [args objectForKey:@"filename"];
  id parentRev = [args objectForKey:@"parentRev"];
  BOOL overwrite = [TiUtils boolValue:@"overwrite" properties:args def:NO];
  
  ENSURE_TYPE(file, TiFile);
  ENSURE_TYPE(path, NSString);
  ENSURE_TYPE_OR_NIL(fileName, NSString);
  ENSURE_TYPE_OR_NIL(parentRev, NSString);
  
  if(fileName == nil)
    fileName = [[file path] lastPathComponent];
  
  [self.restClient uploadFile:fileName toPath:path withParentRev:parentRev fromPath:[file path] withOverwrite:overwrite];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString *)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [metadata dumpToDictionary:event];
  [event setValue:destPath forKey:@"path"];
  
  if(uploadFileSuccessCallback)
    [self _fireEventToListener:@"success" withObject:event listener:uploadFileSuccessCallback thisObject:nil];
}
- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress 
           forFile:(NSString*)destPath from:(NSString*)srcPath {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [event setValue:NUMFLOAT(progress) forKey:@"progress"];
  [event setValue:destPath forKey:@"path"];
  
  if(uploadFileProgressCallback)
    [self _fireEventToListener:@"progress" withObject:event listener:uploadFileProgressCallback thisObject:nil];
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  if(uploadFileErrorCallback)
    [self _fireEventToListener:@"error" withObject:event listener:uploadFileErrorCallback thisObject:nil];
}

-(void)copyPath:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id error = [args objectForKey:@"error"];
  
  RELEASE_AND_REPLACE(copyPathSuccessCallback, success);
  RELEASE_AND_REPLACE(copyPathErrorCallback, error);
  
  id fromPath = [args objectForKey:@"fromPath"];
  id toPath = [args objectForKey:@"toPath"];
  ENSURE_TYPE(fromPath, NSString);
  ENSURE_TYPE(toPath, NSString);
  
  [self.restClient copyFrom:fromPath toPath:toPath];
}

- (void)restClient:(DBRestClient*)client copiedPath:(NSString *)from_path toPath:(NSString *)to_path {
  NSDictionary *event = [NSDictionary dictionary];
  
  if(copyPathSuccessCallback)
    [self _fireEventToListener:@"success" withObject:event listener:copyPathSuccessCallback thisObject:nil];
}

- (void)restClient:(DBRestClient*)client copyPathFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  if(copyPathErrorCallback)
    [self _fireEventToListener:@"error" withObject:event listener:copyPathErrorCallback thisObject:nil];
}

-(void)movePath:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id error = [args objectForKey:@"error"];
  
  RELEASE_AND_REPLACE(movePathSuccessCallback, success);
  RELEASE_AND_REPLACE(movePathErrorCallback, error);
  
  id fromPath = [args objectForKey:@"fromPath"];
  id toPath = [args objectForKey:@"toPath"];
  ENSURE_TYPE(fromPath, NSString);
  ENSURE_TYPE(toPath, NSString);
  
  [self.restClient moveFrom:fromPath toPath:toPath];
}

- (void)restClient:(DBRestClient*)client movedPath:(NSString *)from_path toPath:(NSString *)to_path {
  NSDictionary *event = [NSDictionary dictionary];
  
  if(movePathSuccessCallback)
    [self _fireEventToListener:@"success" withObject:event listener:movePathSuccessCallback thisObject:nil];
}
- (void)restClient:(DBRestClient*)client movePathFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  if(movePathErrorCallback)
    [self _fireEventToListener:@"error" withObject:event listener:movePathErrorCallback thisObject:nil];
}

#pragma mark Private Methods
- (DBRestClient *)restClient {
  if(restClient == nil) {
    restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = self;
  }
  
  if(![[DBSession sharedSession] isLinked]) {
    [self throwException:@"Dropbox Session is not Linked" subreason:@"Please link your session" location:CODELOCATION];
    return nil;
  }
    
  return restClient;
}

@end
