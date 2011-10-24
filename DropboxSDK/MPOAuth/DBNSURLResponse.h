//
//  DBNSURLResponse.h
//  dropbox
//
//  Created by Ruben Fonseca on 24/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBNSURLResponse : NSObject

+ (NSStringEncoding)encoding:(NSURLResponse *)response;

@end
