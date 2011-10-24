//
//  DBNSURLResponse.m
//  dropbox
//
//  Created by Ruben Fonseca on 24/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DBNSURLResponse.h"

@implementation DBNSURLResponse

+ (NSStringEncoding)encoding:(NSURLResponse *)response {
  NSStringEncoding encoding = NSUTF8StringEncoding;
  
  if([response textEncodingName]) {
    CFStringEncoding cfStringEnding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]);
    if(cfStringEnding != kCFStringEncodingInvalidId) {
      encoding = CFStringConvertEncodingToNSStringEncoding(cfStringEnding);
    }
  }
  
  return encoding;
}

@end
