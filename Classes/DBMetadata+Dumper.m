//
//  DBMetadata+Dumper.m
//  dropbox
//
//  Created by Ruben Fonseca on 26/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DBMetadata+Dumper.h"
#import "TiUtils.h"

@implementation DBMetadata (Dumper)

-(void)dumpToDictionary:(NSMutableDictionary *)dict {
  [dict setObject:NUMBOOL(thumbnailExists) forKey:@"thumbnailExists"];
  [dict setObject:NUMINT(totalBytes) forKey:@"totalBytes"];
  [dict setObject:NULL_IF_NIL(lastModifiedDate) forKey:@"lastModifiedDate"];
  [dict setObject:NULL_IF_NIL(path) forKey:@"path"];
  [dict setObject:NUMBOOL(isDirectory) forKey:@"isDirectory"];
	
	if(contents) {
		NSMutableArray *contentsArray = [NSMutableArray array];
		
		for(DBMetadata *m in contents) {
			NSMutableDictionary *d = [NSMutableDictionary dictionary];
			[m dumpToDictionary:d];
			[contentsArray addObject:d];
		}
		
		[dict setObject:contentsArray forKey:@"contents"];
	}
	
  [dict setObject:NULL_IF_NIL(hash) forKey:@"hash"];
  [dict setObject:NULL_IF_NIL(humanReadableSize) forKey:@"humanReadableSize"];
  [dict setObject:NULL_IF_NIL(root) forKey:@"root"];
  [dict setObject:NULL_IF_NIL(icon) forKey:@"icon"];
  [dict setObject:NULL_IF_NIL(rev) forKey:@"rev"];
  [dict setObject:NUMINT(revision) forKey:@"revision"];
  [dict setObject:NUMBOOL(isDeleted) forKey:@"isDeleted"];
}

@end
