//
//  DBRestClient+OverwriteUpload.m
//  dropbox
//
//  Created by Ruben Fonseca on 03/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DBRestClient+OverwriteUpload.h"

@interface DBRestClient (Private)
- (void)uploadFile:(NSString*)filename toPath:(NSString*)path fromPath:(NSString *)sourcePath
            params:(NSDictionary *)params;
@end

@implementation DBRestClient (OverwriteUpload)

- (void)uploadFile:(NSString *)filename toPath:(NSString *)path withParentRev:(NSString *)parentRev
          fromPath:(NSString *)sourcePath withOverwrite:(BOOL)overwrite {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:(overwrite ? @"true" : @"false") forKey:@"overwrite"];
  if (parentRev) {
    [params setObject:parentRev forKey:@"parent_rev"];
  }
  [self uploadFile:filename toPath:path fromPath:sourcePath params:params];
}

@end
