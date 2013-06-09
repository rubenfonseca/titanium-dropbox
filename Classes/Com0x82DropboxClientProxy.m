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
#import "DBDeltaEntry.h"

@interface Com0x82DropboxClientProxy () <DBRestClientDelegate>
@property (nonatomic, readonly) DBRestClient* restClient;
@end

@implementation Com0x82DropboxClientProxy

#pragma mark Memory management 

-(id)init {
  if(self = [super init]) {
    loadFileDictionary = [[NSMutableDictionary alloc] init];
    uploadFileDictionary = [[NSMutableDictionary alloc] init];
		chunkedUploadFileDictionary = [[NSMutableDictionary alloc] init];
  }
  
  return self;
}

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
  
  RELEASE_TO_NIL(loadFileDictionary);
  RELEASE_TO_NIL(uploadFileDictionary);
	RELEASE_TO_NIL(chunkedUploadFileDictionary);
  
  RELEASE_TO_NIL(createFolderSuccessCallback);
  RELEASE_TO_NIL(createFolderErrorCallback);
  
  RELEASE_TO_NIL(deletePathSuccessCallback);
  RELEASE_TO_NIL(deletePathErrorCallback);
  
  RELEASE_TO_NIL(copyPathSuccessCallback);
  RELEASE_TO_NIL(copyPathErrorCallback);
  
  RELEASE_TO_NIL(movePathSuccessCallback);
  RELEASE_TO_NIL(movePathErrorCallback);
	
	RELEASE_TO_NIL(sharePathSuccessCallback);
	RELEASE_TO_NIL(sharePathErroCallback);
	
	RELEASE_TO_NIL(mediaPathSuccessCallback);
	RELEASE_TO_NIL(mediaPathErrorCallback);
	
	RELEASE_TO_NIL(searchSuccesCallback);
	RELEASE_TO_NIL(searchErrorCallback);
	
	RELEASE_TO_NIL(deltaSuccessCallback);
	RELEASE_TO_NIL(deltaErrorCallback);
  
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

#define kLoadFileSuccessCallback @"LoadfileSuccessCallback"
#define kLoadFileErrorCallback @"LoadFileErrorCallback"
#define kLoadFileProgressCallback @"LoadFileProgressCallback"
#define kLoadFileTempFilePath @"LoadFileTempFilePath"

-(void)loadFile:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id error = [args objectForKey:@"error"];
  id progress = [args objectForKey:@"progress"];
  
  id path = [args objectForKey:@"path"];
  ENSURE_TYPE(path, NSString);
  
  CFUUIDRef uuid = CFUUIDCreate(nil);
  NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuid);
  CFRelease(uuid);

  NSString *fileTempPath = [NSTemporaryDirectory() stringByAppendingString:uuidString];
  NSMutableDictionary *callbacks = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      success, kLoadFileSuccessCallback,
                                      error, kLoadFileErrorCallback,
                                      progress, kLoadFileProgressCallback,
                                      fileTempPath, kLoadFileTempFilePath, nil];
  
  [loadFileDictionary setValue:callbacks forKey:fileTempPath];
  
  [self.restClient loadFile:path intoPath:fileTempPath];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath contentType:(NSString*)contentType {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [event setValue:NULL_IF_NIL(contentType) forKey:@"content-type"];
  
  NSMutableDictionary *callbacks = [loadFileDictionary valueForKey:destPath];
  
  TiBlob *blob = [[[TiBlob alloc] initWithFile:destPath] autorelease];
  [event setValue:blob forKey:@"file"];
  
  if([callbacks valueForKey:kLoadFileSuccessCallback])
    [self _fireEventToListener:@"success" withObject:event listener:[callbacks valueForKey:kLoadFileSuccessCallback] thisObject:nil];
  
  [loadFileDictionary removeObjectForKey:destPath];
}
- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
  NSDictionary *event = [NSDictionary dictionaryWithObject:NUMFLOAT(progress) forKey:@"progress"];
  
  NSMutableDictionary *callbacks = [loadFileDictionary valueForKey:destPath];
  
  if([callbacks valueForKey:kLoadFileProgressCallback])
    [self _fireEventToListener:@"progress" withObject:event listener:[callbacks valueForKey:kLoadFileProgressCallback] thisObject:nil];
}
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  NSString *destPath = [[error userInfo] valueForKey:@"destinationPath"];
  NSMutableDictionary *callbacks = [loadFileDictionary valueForKey:destPath];
  
  if([callbacks valueForKey:kLoadFileErrorCallback])
    [self _fireEventToListener:@"error" withObject:event listener:[callbacks valueForKey:kLoadFileErrorCallback] thisObject:nil];
  
  [loadFileDictionary removeObjectForKey:destPath];
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

-(void)sharePath:(id)args {
	ENSURE_UI_THREAD_1_ARG(args);
	ENSURE_SINGLE_ARG(args, NSDictionary);
	
	id success = [args objectForKey:@"success"];
	id error   = [args objectForKey:@"error"];
	
	RELEASE_AND_REPLACE(sharePathSuccessCallback, success);
	RELEASE_AND_REPLACE(sharePathErroCallback, error);
	
	id path = [args objectForKey:@"path"];
	ENSURE_TYPE(path, NSString);
	
	[self.restClient loadSharableLinkForFile:path];
}

-(void)restClient:(DBRestClient *)restClient loadedSharableLink:(NSString *)link forFile:(NSString *)path {
	NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:path, @"path", link, @"url", nil];
	
	if(sharePathSuccessCallback)
		[self _fireEventToListener:@"success" withObject:event listener:sharePathSuccessCallback thisObject:nil];
}

-(void)restClient:(DBRestClient *)restClient loadSharableLinkFailedWithError:(NSError *)error {
	NSDictionary *event = error.userInfo;
	
	if(sharePathErroCallback)
		[self _fireEventToListener:@"error" withObject:event listener:sharePathErroCallback thisObject:nil];
}

-(void)getStreamableURL:(id)args {
	ENSURE_UI_THREAD_1_ARG(args);
	ENSURE_SINGLE_ARG(args, NSDictionary);
	
	id success = [args objectForKey:@"success"];
	id error   = [args objectForKey:@"error"];
	
	RELEASE_AND_REPLACE(mediaPathSuccessCallback, success);
	RELEASE_AND_REPLACE(mediaPathErrorCallback, error);
	
	id path = [args objectForKey:@"path"];
	ENSURE_TYPE(path, NSString);
	
	[self.restClient loadStreamableURLForFile:path];
}

-(void)restClient:(DBRestClient *)restClient loadedStreamableURL:(NSURL *)url forFile:(NSString *)path {
	NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:path, @"path", [url absoluteString], @"url", nil];
	
	if(mediaPathSuccessCallback)
		[self _fireEventToListener:@"success" withObject:event listener:mediaPathSuccessCallback thisObject:nil];
}

-(void)restClient:(DBRestClient *)restClient loadStreamableURLFailedWithError:(NSError *)error {
	NSDictionary *event = error.userInfo;
	
	if(mediaPathErrorCallback)
		[self _fireEventToListener:@"error" withObject:event listener:mediaPathErrorCallback thisObject:nil];
}

-(void)search:(id)args {
	ENSURE_UI_THREAD_1_ARG(args);
	ENSURE_SINGLE_ARG(args, NSDictionary);
	
	id success = [args objectForKey:@"success"];
	id error   = [args objectForKey:@"error"];
	
	RELEASE_AND_REPLACE(searchSuccesCallback, success);
	RELEASE_AND_REPLACE(searchErrorCallback, error);
	
	id path = [args objectForKey:@"path"];
	id query = [args objectForKey:@"query"];
	
	ENSURE_TYPE(path, NSString);
	ENSURE_TYPE(query, NSString);
	
	[self.restClient searchPath:path forKeyword:query];
}

-(void)restClient:(DBRestClient *)restClient loadedSearchResults:(NSArray *)results forPath:(NSString *)path keyword:(NSString *)keyword {
	
	NSMutableArray *metadatas = [NSMutableArray arrayWithCapacity:[results count]];
	for(DBMetadata *metadata in results) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[metadata dumpToDictionary:dict];
		[metadatas addObject:dict];
	}
	
	NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:path, @"path", keyword, @"keyword", metadatas, @"results", nil];
	
	if(searchSuccesCallback)
		[self _fireEventToListener:@"success" withObject:event listener:searchSuccesCallback thisObject:nil];
}

-(void)restClient:(DBRestClient *)restClient searchFailedWithError:(NSError *)error {
	NSDictionary *event = error.userInfo;
	
	if(searchErrorCallback)
		[self _fireEventToListener:@"error" withObject:event listener:searchErrorCallback thisObject:nil];
}

#define kChunkedUploadFileSuccessCallback @"ChunkedUploadSuccessCallback"
#define kChunkedUploadFileErrorCallback @"ChunkedUploadErrorCallback"
#define kChunkedUploadProgressCallback @"ChunkedUploadProgressCallback"

-(void)uploadChunkedFile:(id)args {
	ENSURE_UI_THREAD_1_ARG(args);
	ENSURE_SINGLE_ARG(args, NSDictionary);
	
	id success = [args objectForKey:@"success"];
	id progress = [args objectForKey:@"progress"];
	id error = [args objectForKey:@"error"];
	
  id file = [args objectForKey:@"file"];
  id path = [args objectForKey:@"path"];
  id fileName = [args objectForKey:@"filename"];
  id parentRev = [args objectForKey:@"parentRev"];
  
  ENSURE_TYPE(file, TiFile);
  ENSURE_TYPE(path, NSString);
  ENSURE_TYPE_OR_NIL(fileName, NSString);
  ENSURE_TYPE_OR_NIL(parentRev, NSString);
	
  if(fileName == nil)
    fileName = [[file path] lastPathComponent];

  NSMutableDictionary *callbacks = [@{
		kChunkedUploadFileSuccessCallback: success,
		kChunkedUploadFileErrorCallback: error,
		kChunkedUploadProgressCallback: progress,
		
		@"path": path,
		@"fileName": fileName,
		@"fileSize": @([(TiFile *)file size]),
	} mutableCopy];
	
	if(parentRev)
		[callbacks setValue:parentRev forKey:@"parentRev"];
	
  [chunkedUploadFileDictionary setValue:callbacks forKey:[file path]];
	
	[self.restClient uploadFileChunk:nil offset:0 fromPath:[file path]];
}

-(void)restClient:(DBRestClient *)client uploadedFileChunk:(NSString *)uploadId newOffset:(unsigned long long)offset fromFile:(NSString *)localPath expires:(NSDate *)expiresDate {
	NSDictionary *metadata = chunkedUploadFileDictionary[localPath];
	NSAssert(metadata != nil, @"Metadata is not null");
	
	// Calculate progress
	double progress = (double)offset / (double)[metadata[@"fileSize"] unsignedLongLongValue];
	if(metadata[kChunkedUploadProgressCallback]) {
		[self _fireEventToListener:@"progress" withObject:@{ @"progress" : @(progress), @"path": metadata[@"path"] } listener:metadata[kChunkedUploadProgressCallback] thisObject:nil];
	}
	
	if(offset >= [metadata[@"fileSize"] unsignedLongLongValue]) {
		// Finalize the upload
		NSLog(@"Finalizing chunk upload ID %@", uploadId);
		
		[chunkedUploadFileDictionary removeObjectForKey:localPath];
		chunkedUploadFileDictionary[uploadId] = metadata;
		
		[self.restClient uploadFile:metadata[@"fileName"] toPath:metadata[@"path"] withParentRev:metadata[@"parentRev"] fromUploadId:uploadId];
	} else {
		NSLog(@"Continuing chunk upload on upload ID %@ offset %lld", uploadId, offset);
		[self.restClient uploadFileChunk:uploadId offset:offset fromPath:localPath];
	}
}

-(void)restClient:(DBRestClient *)client uploadFileChunkFailedWithError:(NSError *)error {
	NSDictionary *metadata = chunkedUploadFileDictionary[error.userInfo[@"fromPath"]];
	
	if(metadata && metadata[kChunkedUploadFileErrorCallback]) {
		[self _fireEventToListener:@"error" withObject:error.userInfo listener:metadata[kChunkedUploadFileErrorCallback] thisObject:nil];
		
		[chunkedUploadFileDictionary removeObjectForKey:error.userInfo[@"fromPath"]];
	}
}

-(void)restClient:(DBRestClient *)client uploadFromUploadIdFailedWithError:(NSError *)error {
	NSDictionary *metadata = chunkedUploadFileDictionary[error.userInfo[@"uploadId"]];
	
	if(metadata[kChunkedUploadFileErrorCallback]) {
		[self _fireEventToListener:@"error" withObject:error.userInfo listener:metadata[kChunkedUploadFileErrorCallback] thisObject:nil];
		
		[chunkedUploadFileDictionary removeObjectForKey:error.userInfo[@"uploadId"]];
	}
}

-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath fromUploadId:(NSString *)uploadId metadata:(DBMetadata *)metadata {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [metadata dumpToDictionary:event];
  [event setValue:destPath forKey:@"path"];
	[event setValue:uploadId forKey:@"uploadID"];
	
	NSDictionary *callbacks = chunkedUploadFileDictionary[uploadId];
	if(callbacks && callbacks[kChunkedUploadFileSuccessCallback]) {
		[self _fireEventToListener:@"success" withObject:event listener:callbacks[kChunkedUploadFileSuccessCallback] thisObject:nil];
	
		[chunkedUploadFileDictionary removeObjectForKey:uploadId];
	}
}

#define kUploadFileSuccessCallback @"UploadFileSuccessCallback"
#define kUploadFileErrorCallback @"UploadFileErrorCallback"
#define kUploadFileProgressCallback @"UploadFileProgressCallback"

-(void)uploadFile:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id progress = [args objectForKey:@"progress"];
  id error = [args objectForKey:@"error"];
  
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

  NSMutableDictionary *callbacks = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      success, kUploadFileSuccessCallback,
                                      error, kUploadFileErrorCallback,
                                      progress, kUploadFileProgressCallback, nil];
  [uploadFileDictionary setValue:callbacks forKey:[file path]];
  
  [self.restClient uploadFile:fileName toPath:path withParentRev:parentRev fromPath:[file path] withOverwrite:overwrite];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString *)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [metadata dumpToDictionary:event];
  [event setValue:destPath forKey:@"path"];
  
  NSMutableDictionary *callbacks = [uploadFileDictionary valueForKey:srcPath];
	if(callbacks) {
		if([callbacks valueForKey:kUploadFileSuccessCallback])
			[self _fireEventToListener:@"success" withObject:event listener:[callbacks valueForKey:kUploadFileSuccessCallback] thisObject:nil];
		
		[uploadFileDictionary removeObjectForKey:srcPath];
	}
}
	
- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress
           forFile:(NSString*)destPath from:(NSString*)srcPath {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [event setValue:NUMFLOAT(progress) forKey:@"progress"];
  [event setValue:destPath forKey:@"path"];
  
  NSMutableDictionary *callbacks = [uploadFileDictionary valueForKey:srcPath];
  
  if([callbacks valueForKey:kUploadFileProgressCallback])
    [self _fireEventToListener:@"progress" withObject:event listener:[callbacks valueForKey:kUploadFileProgressCallback] thisObject:nil];
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
  NSDictionary *event = error.userInfo;
  
  NSString *srcPath = [[error userInfo] valueForKey:@"sourcePath"];
  NSMutableDictionary *callbacks = [uploadFileDictionary valueForKey:srcPath];
  
  if([callbacks valueForKey:kUploadFileErrorCallback])
    [self _fireEventToListener:@"error" withObject:event listener:[callbacks valueForKey:kUploadFileErrorCallback] thisObject:nil];
  [callbacks removeObjectForKey:srcPath];
}

-(void)createCopyRef:(id)args {
	ENSURE_UI_THREAD_1_ARG(args);
	ENSURE_SINGLE_ARG(args, NSDictionary);
	
	id success = [args objectForKey:@"success"];
	id error = [args objectForKey:@"error"];
	
	RELEASE_AND_REPLACE(copyRefSuccessCallback, success);
	RELEASE_AND_REPLACE(copyRefErrorCallback, error);
	
	id path = [args objectForKey:@"path"];
	ENSURE_TYPE(path, NSString);
	
	[self.restClient createCopyRef:path];
}

-(void)restClient:(DBRestClient *)client createdCopyRef:(NSString *)copyRef {
	NSDictionary *event = [NSDictionary dictionaryWithObject:copyRef forKey:@"copyRef"];
	
	if(copyRefSuccessCallback)
		[self _fireEventToListener:@"success" withObject:event listener:copyRefSuccessCallback thisObject:nil];
}

-(void)restClient:(DBRestClient *)client createCopyRefFailedWithError:(NSError *)error {
	NSDictionary *event = error.userInfo;
	
	if(copyRefErrorCallback)
		[self _fireEventToListener:@"error" withObject:event listener:copyRefErrorCallback thisObject:nil];
}

-(void)copyPath:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  id success = [args objectForKey:@"success"];
  id error = [args objectForKey:@"error"];
  
  RELEASE_AND_REPLACE(copyPathSuccessCallback, success);
  RELEASE_AND_REPLACE(copyPathErrorCallback, error);
  
  id fromPath = [args objectForKey:@"fromPath"];
	id fromCopyRef = [args objectForKey:@"fromCopyRef"];
  id toPath = [args objectForKey:@"toPath"];
	
	if(!fromPath && !fromCopyRef)
		[self throwException:@"fromPath or fromCopyRef is required" subreason:@"" location:CODELOCATION];
	
  ENSURE_TYPE(toPath, NSString);
	if(fromPath) {
  	ENSURE_TYPE(fromPath, NSString);
	  [self.restClient copyFrom:fromPath toPath:toPath];
	} else {
  	ENSURE_TYPE(fromCopyRef, NSString);
		[self.restClient copyFromRef:fromCopyRef toPath:toPath];
	}
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

-(void)restClient:(DBRestClient *)client copiedRef:(NSString *)copyRef to:(DBMetadata *)to {
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  [to dumpToDictionary:event];
	
	if(copyPathSuccessCallback)
		[self _fireEventToListener:@"success" withObject:event listener:copyPathSuccessCallback thisObject:nil];
}

-(void)restClient:(DBRestClient *)client copyFromRefFailedWithError:(NSError *)error {
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

-(void)restoreRevision:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  KrollCallback *success; ENSURE_ARG_FOR_KEY(success, args, @"success", KrollCallback);
  KrollCallback *error; ENSURE_ARG_FOR_KEY(error, args, @"error", KrollCallback);
  
  RELEASE_AND_REPLACE(restoreSuccessCallback, success);
  RELEASE_AND_REPLACE(restoreErrorCallback, error);
  
  NSString *path; ENSURE_ARG_FOR_KEY(path, args, @"path", NSString);
  NSString *rev; ENSURE_ARG_FOR_KEY(rev, args, @"revision", NSString);
  
  [self.restClient restoreFile:path toRev:rev];
}

-(void)restClient:(DBRestClient *)client restoredFile:(DBMetadata *)fileMetadata {
  NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
  [fileMetadata dumpToDictionary:metadata];
  
	NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:metadata, @"metadata", nil];
	
	if(restoreSuccessCallback)
		[self _fireEventToListener:@"success" withObject:event listener:restoreSuccessCallback thisObject:nil];
}

-(void)restClient:(DBRestClient *)client restoreFileFailedWithError:(NSError *)error {
	NSDictionary *event = error.userInfo;
	
	if(restoreErrorCallback)
		[self _fireEventToListener:@"error" withObject:event listener:restoreErrorCallback thisObject:nil];
}

-(void)loadRevisions:(id)args {
  ENSURE_UI_THREAD_1_ARG(args);
  ENSURE_SINGLE_ARG(args, NSDictionary);
  
  KrollCallback *success; ENSURE_ARG_FOR_KEY(success, args, @"success", KrollCallback);
  KrollCallback *error; ENSURE_ARG_FOR_KEY(error, args, @"error", KrollCallback);
  
  RELEASE_AND_REPLACE(loadRevisionsSuccessCallback, success);
  RELEASE_AND_REPLACE(loadRevisionsErrorCallback, error);
  
  NSString *path; ENSURE_ARG_FOR_KEY(path, args, @"path", NSString);
  int limit = [TiUtils intValue:@"limit" properties:args def:10];
  
  [self.restClient loadRevisionsForFile:path limit:limit];
}

-(void)restClient:(DBRestClient *)client loadedRevisions:(NSArray *)revisions forFile:(NSString *)path {
  NSMutableArray *metadatas = [NSMutableArray arrayWithCapacity:[revisions count]];
	for(DBMetadata *metadata in revisions) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[metadata dumpToDictionary:dict];
		[metadatas addObject:dict];
	}
	
	NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:path, @"path", metadatas, @"revisions", nil];
	
	if(loadRevisionsSuccessCallback)
		[self _fireEventToListener:@"success" withObject:event listener:loadRevisionsSuccessCallback thisObject:nil];
}

-(void)restClient:(DBRestClient *)client loadRevisionsFailedWithError:(NSError *)error {
	NSDictionary *event = error.userInfo;
	
	if(loadRevisionsErrorCallback)
		[self _fireEventToListener:@"error" withObject:event listener:loadRevisionsErrorCallback thisObject:nil];
}

-(void)loadDelta:(id)args {
	ENSURE_UI_THREAD_1_ARG(args);
	ENSURE_SINGLE_ARG(args, NSDictionary);
	
	KrollCallback *success; ENSURE_ARG_FOR_KEY(success, args, @"success", KrollCallback);
	KrollCallback *error; ENSURE_ARG_FOR_KEY(error, args, @"error", KrollCallback);
	
	RELEASE_AND_REPLACE(deltaSuccessCallback, success);
	RELEASE_AND_REPLACE(deltaErrorCallback, error);
	
	NSString *cursor; ENSURE_ARG_OR_NIL_FOR_KEY(cursor, args, @"cursor", NSString);
	
	[self.restClient loadDelta:cursor];
}

-(void)restClient:(DBRestClient *)client loadedDeltaEntries:(NSArray *)entries reset:(BOOL)shouldReset cursor:(NSString *)cursor hasMore:(BOOL)hasMore {
	
	NSMutableArray *entriesList = [NSMutableArray arrayWithCapacity:[entries count]];
	[entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		DBDeltaEntry *deltaEntry = (DBDeltaEntry *)obj;
		
		NSMutableDictionary *metadata = nil;
		if(deltaEntry.metadata) {
			metadata = [NSMutableDictionary dictionary];
			[deltaEntry.metadata dumpToDictionary:metadata];
		}
		[entriesList addObject:@[deltaEntry.lowercasePath, metadata ? metadata : [NSNull null]]];
	}];
	
	NSDictionary *event = @{
		@"entries"  : entriesList,
		@"reset"    : @(shouldReset),
		@"cursor"   : cursor,
		@"has_more" : @(hasMore)
	};
	
	if(deltaSuccessCallback)
		[self _fireEventToListener:@"success" withObject:event listener:deltaSuccessCallback thisObject:nil];
}

-(void)restClient:(DBRestClient *)client loadDeltaFailedWithError:(NSError *)error {
	NSDictionary *event = error.userInfo;
	
	if(deltaErrorCallback)
		[self _fireEventToListener:@"error" withObject:event listener:deltaErrorCallback thisObject:nil];
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
