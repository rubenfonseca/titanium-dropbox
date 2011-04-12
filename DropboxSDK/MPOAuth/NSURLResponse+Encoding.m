//
//  NSURL+MPEncodingAdditions.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "NSURLResponse+Encoding.h"


@implementation DBNSURLResponse

+ (NSStringEncoding)encoding:(NSURLResponse *)response {
	NSStringEncoding encoding = NSUTF8StringEncoding;
	
	if ([response textEncodingName]) {
		CFStringEncoding cfStringEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]);
		if (cfStringEncoding != kCFStringEncodingInvalidId) {
			encoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding); 
		}
	}
	
	return encoding;
}

@end
