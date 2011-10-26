//
//  DBMetadata+Dumper.h
//  dropbox
//
//  Created by Ruben Fonseca on 26/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBMetadata (Dumper)
-(void)dumpToDictionary:(NSMutableDictionary *)dict;
@end
