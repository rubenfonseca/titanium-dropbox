//
//  NSString+Dropbox.m
//  DropboxSDK
//
//  Created by Brian Smith on 7/19/10.
//  Copyright 2010 Dropbox, Inc. All rights reserved.
//

#import "NSString+Dropbox.h"


@implementation DBNSString

+ (NSString*)normalizedDropboxPath:(NSString *)string {
    if ([string isEqual:@"/"]) return @"";
    return [[string lowercaseString] precomposedStringWithCanonicalMapping];
}

+ (BOOL)string:(NSString *)string isEqualToDropboxPath:(NSString*)otherPath {
  return [[DBNSString normalizedDropboxPath:string] isEqualToString:[DBNSString normalizedDropboxPath:otherPath]];
}

@end
