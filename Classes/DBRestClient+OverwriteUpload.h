//
//  DBRestClient+OverwriteUpload.h
//  dropbox
//
//  Created by Ruben Fonseca on 03/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBRestClient.h"

@interface DBRestClient (OverwriteUpload)
- (void)uploadFile:(NSString *)filename toPath:(NSString *)path withParentRev:(NSString *)parentRev
          fromPath:(NSString *)sourcePath withOverwrite:(BOOL)overwrite;

-(void)loadMetadata:(NSString *)path withParams:(NSDictionary *)params;
@end
