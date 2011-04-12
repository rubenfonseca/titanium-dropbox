//
//  NSURL+MPEncodingAdditions.h
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBNSURLResponse : NSObject
+ (NSStringEncoding)encoding:(NSURLResponse *)response;
@end
